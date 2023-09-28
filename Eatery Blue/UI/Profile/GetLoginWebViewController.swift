//
//  GetLoginWebViewController.swift
//  Eatery Blue
//
//  Created by Jennifer Gu on 9/28/23.
//

import UIKit
import WebKit


class GetLoginWebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
     
     weak var delegate: GetLoginWebViewControllerDelegate?
     
     var webView: WKWebView!
     
     override func loadView() {
          let configuration = WKWebViewConfiguration()
          webView = WKWebView(frame: .zero, configuration: configuration)
          webView.uiDelegate = self
          webView.navigationDelegate = self
          view = webView
     }
     
     
     override func viewDidLoad() {
          super.viewDidLoad()
          
          let loginURL = URL(string:"https://get.cbord.com/cornell/full/login.php?mobileapp=1")
          let loginRequest = URLRequest(url: loginURL!)
          webView.load(loginRequest)
     }
     
     func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
          print(error.localizedDescription)
     }
     
     func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
          if let url = webView.url, let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), let sessionId = urlComponents.queryItems?.filter({ $0.name == "sessionId" }).first?.value {
               delegate?.setSessionId(sessionId)
               self.dismiss(animated: true)
          }
     }
}

protocol GetLoginWebViewControllerDelegate: AnyObject {

    func setSessionId(_ sessionId: String)

}
