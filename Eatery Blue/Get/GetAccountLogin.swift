//
//  GetAccountLogin.swift
//  Eatery Blue
//
//  Created by William Ma on 1/5/22.
//

import Alamofire
import Combine
import Foundation
import Logging
import SwiftSoup
import WebKit

class GetAccountLogin: NSObject, WKNavigationDelegate {

    typealias SessionID = String

    enum LoginError: Error {
        case invalidLoginUrl
        case loginFailed
        case internalError
    }

    enum Stage {
        case loginScreen
        case transition
        case loginFailed
        case samlResponse
    }

    private let webView: WKWebView

    private var evaluateJavaScriptContinuation: CheckedContinuation<Any?, Error>?
    private var loadUrlContinuation: CheckedContinuation<Void, Error>?
    private var loginAttempts: Int = 0

    private let netId: String
    private let password: String

    convenience init(credentials: KeychainManager.Credentials) {
        self.init(netId: credentials.netId, password: credentials.password)
    }

    init(netId: String, password: String) {
        self.netId = netId
        self.password = password

        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = false

        super.init()

        webView.navigationDelegate = self

        if Get.debugAttachAccountLoginWebViewToWindow,
            let delegate = UIApplication.shared.connectedScenes.first!.delegate as? SceneDelegate {
            delegate.window?.addSubview(webView)
            webView.edgesToSuperview()
        }
    }

    deinit {
        webView.removeFromSuperview()
    }

    @MainActor func sessionId() async throws -> SessionID {
        guard let loginUrl = URL(string: "https://get.cbord.com/cornell/full/login.php?mobileapp=1") else {
            throw LoginError.invalidLoginUrl
        }

        loginAttempts = 0
        try await loadUrl(loginUrl)

        for _ in 1...100 {
            let stage = try await stage()

            Get.logger.debug("\(#function): \(stage)")

            switch stage {
            case .loginScreen:
                if loginAttempts == 0 {
                    try await webLogIn()
                    loginAttempts += 1
                } else {
                    throw LoginError.loginFailed
                }

            case .transition:
                try await Task.sleep(nanoseconds: 1_000_000_000)

            case .loginFailed:
                throw LoginError.loginFailed

            case .samlResponse:
                return try await handleSamlForm()
            }
        }

        throw LoginError.internalError
    }

    @MainActor private func html() async throws -> String? {
        let script = """
        document.documentElement.outerHTML.toString()
        """

        return try await evaluateJavaScript(script) as? String
    }

    @MainActor private func stage() async throws -> Stage {
        guard let html = try await html() else {
            return .loginFailed
        }

        if loginAttempts > 1 {
            return .loginFailed

        } else if html.contains("<title>Cornell University Web Login</title>") {
            return .loginScreen

        } else if html.contains("SAMLResponse") {
            return .samlResponse

        } else {
            return .transition
        }
    }

    @MainActor private func webLogIn() async throws {
        let script = """
        document.getElementsByName('j_username')[0].value = '\(netId)';
        document.getElementsByName('j_password')[0].value = '\(password)';
        document.getElementsByName('_eventId_proceed')[0].click();
        """

        _ = try await evaluateJavaScript(script, awaitNavigation: true)
    }

    @MainActor private func loadUrl(_ url: URL) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            loadUrlContinuation = continuation
            webView.load(URLRequest(url: url))
        }
    }

    @MainActor private func evaluateJavaScript(_ script: String, awaitNavigation: Bool = false) async throws -> Any? {
        try await withCheckedThrowingContinuation { continuation in
            // As of 1/5/22, WKWebView.evaluateJavaScript may return nil for both result and error. Swift's Obj-C
            // async/await conversion assumes at least one will be non-nil and causes a crash, so we must manually
            // convert for now.

            webView.evaluateJavaScript(script) { [self] result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    if awaitNavigation {
                        evaluateJavaScriptContinuation = continuation
                    } else {
                        continuation.resume(returning: result)
                    }
                }
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation?) {
        if let loadUrlContinuation = loadUrlContinuation {
            loadUrlContinuation.resume()
            self.loadUrlContinuation = nil
        }

        if let evaluateJavaScriptContinuation = evaluateJavaScriptContinuation {
            evaluateJavaScriptContinuation.resume(returning: nil)
            self.evaluateJavaScriptContinuation = nil
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation?, withError error: Error) {
        if let loadUrlContinuation = loadUrlContinuation {
            loadUrlContinuation.resume(throwing: error)
            self.loadUrlContinuation = nil
        }

        if let evaluateJavaScriptContinuation = evaluateJavaScriptContinuation {
            evaluateJavaScriptContinuation.resume(throwing: error)
            self.evaluateJavaScriptContinuation = nil
        }
    }

    @MainActor func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction
    ) async -> WKNavigationActionPolicy {
        Get.logger.debug("\(#function): \(navigationAction.request)")
        return .allow
    }

    @MainActor private func handleSamlForm() async throws -> SessionID {
        guard let html = try await html() else {
            throw LoginError.internalError
        }

        Get.logger.trace("\(html)")

        let document: Document = try SwiftSoup.parse(html)
        guard let form = try document.select("form").first() else {
            throw LoginError.internalError
        }

        var samlResponse: String?

        let elements = try form.select("[name]")
        for element in elements {
            guard let name = try? element.attr("name"),
                  let value = try? element.attr("value")
            else {
                continue
            }

            switch name {
            case "SAMLResponse": samlResponse = value
            default: break
            }
        }

        guard let samlResponse = samlResponse else {
            throw LoginError.internalError
        }

        return try await makeSamlRequest(samlResponse: samlResponse)
    }

    // The string that is sent as the body of an HTTP request when submitting an HTML form
    private func httpBodyFormString(_ params: [String: String]) throws -> String {
        var encoded: [String] = []
        for (key, value) in params {
            guard let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .alphanumerics),
                  let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            else {
                throw LoginError.internalError
            }

            encoded.append("\(encodedKey)=\(encodedValue)")
        }

        return encoded.joined(separator: "&")
    }

    @MainActor private func makeSamlRequest(samlResponse: String) async throws -> SessionID {
        let parameters = [
            "RelayState": "https://get.cbord.com/cornell/full/login.php?mobileapp=1",
            "SAMLResponse": samlResponse
        ]

        let dataTask = AF.request(
            "https://get.cbord.com/cornell/Shibboleth.sso/SAML2/POST",
            method: .post,
            parameters: parameters,
            encoder: URLEncodedFormParameterEncoder(destination: .httpBody)
        )

        let response = await dataTask.serializingString().response
        Get.logger.trace("\(String(describing: response))")

        guard let url = response.response?.url,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let sessionId = components.queryItems?.first(where: { $0.name == "sessionId" })?.value
        else {
            throw LoginError.internalError
        }

        return sessionId
    }

}
