//
//  OnboardingLoginModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/6/22.
//

import UIKit
import EateryGetAPI

class OnboardingLoginModelController: OnboardingLoginViewController {
    
    private var isLoggingIn: Bool = false

    override func didTapLoginButton() {
        super.didTapLoginButton()

        attemptLogin()
    }

    private func updateLoginButtonFromState() {
        if isLoggingIn {
            setLoginButtonTitle("Logging in...")
        } else {
            setLoginButtonTitle("Log in")
        }
    }

    private func attemptLogin() {
        isLoggingIn = true
        view.endEditing(true)
        updateLoginButtonFromState()

        Task {
            let vc = GetLoginWebViewController()
            vc.delegate = self
            self.present(vc, animated: true)
            finishOnboarding()

            isLoggingIn = false
            updateLoginButtonFromState()
        }
    }
}

extension OnboardingLoginModelController: GetLoginWebViewControllerDelegate {

    func setSessionId(_ sessionId: String, _ completion: (() -> Void)) {
        KeychainAccess.shared.saveToken(sessionId: sessionId)
        if !Networking.default.sessionId.isEmpty {
            completion()
        }
    }

}
