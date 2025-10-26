//
//  ProfileLoginModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/7/22.
//

import EateryGetAPI
import UIKit

protocol ProfileLoginModelControllerDelegate: AnyObject {

    func profileLoginModelController(_ viewController: ProfileLoginModelController, didLogin sessionId: String)

    func demoModeDidLogin(_ viewController: ProfileLoginModelController)

}

class ProfileLoginModelController: ProfileLoginViewController, AttemptLogin {

    private var firstView: Bool = true
    private var isLoggingIn: Bool = false

    weak var delegate: ProfileLoginModelControllerDelegate?
    
    private lazy var loginOnLaunch: () = attemptLogin()

    init() {
        super.init(nibName: nil, bundle: nil)
        let _ = loginOnLaunch
    }

    override init(canGoBack: Bool) {
        super.init(canGoBack: canGoBack)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didTapLoginButton() {
        super.didTapLoginButton()
        attemptLogin()
    }

    override func didLongPressLoginButton() {
        super.didLongPressLoginButton()
        delegate?.demoModeDidLogin(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = KeychainAccess.shared.retrieveToken() {
            attemptLogin()
        } else if firstView && UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasLoggedIn) {
            firstView = false
            let stayloginSheet = StayLoggedInSheet()
            stayloginSheet.setUpSheetPresentation()
            stayloginSheet.setUp(delegate: self)
            tabBarController?.present(stayloginSheet, animated: true)
        }
    }

    private func updateLoginButtonFromState() {
        if isLoggingIn {
            setLoginButtonTitle("Logging in...")
        } else {
            setLoginButtonTitle("Log in")
        }
    }

    func attemptLogin() {
        isLoggingIn = true
        view.endEditing(true)
        updateLoginButtonFromState()
        AppDevAnalytics.shared.logFirebase(AccountLoginPayload())

        Task {
            if let sessionId = KeychainAccess.shared.retrieveToken() {
                // if the session id exists, log in directly
                delegate?.profileLoginModelController(self, didLogin: sessionId)
            } else {
                // otherwise, prompt user to log in through Cornell
                let vc = GetLoginWebViewController()
                vc.delegate = self
                self.tabBarController?.present(vc, animated: true)
            }

            isLoggingIn = false
            updateLoginButtonFromState()
        }
    }

    override func didTapSettingsButton() {
        let viewController = SettingsMainMenuModelController()
        navigationController?.pushViewController(viewController, animated: true)
    }

}

extension ProfileLoginModelController: GetLoginWebViewControllerDelegate {

    func setSessionId(_ sessionId: String, _ completion: @escaping (() -> Void)) {
        KeychainAccess.shared.saveToken(sessionId: sessionId)
        
        if !Networking.default.sessionId.isEmpty {
            Task {
                defer {
                    // Always dismiss the WebView at the end of this async block
                    self.tabBarController?.dismiss(animated: true)
                    
                }
                
                do {
                    print("Setting session id")
                    try await Networking.default.authorize(sessionId: sessionId)
                    delegate?.profileLoginModelController(self, didLogin: sessionId)
                    completion()
                } catch {
                    print("Authorization failed: \(error)")
                }
            }
        }
    }

}
