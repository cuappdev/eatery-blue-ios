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

}

class ProfileLoginModelController: ProfileLoginViewController {

    private var isLoggingIn: Bool = false

    weak var delegate: ProfileLoginModelControllerDelegate?
    
    private lazy var loginOnLaunch: () = attemptLogin()

    init() {
        super.init(nibName: nil, bundle: nil)
        let _ = loginOnLaunch
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        AppDevAnalytics.shared.logFirebase(AccountLoginPayload())

        Task {
            if let sessionId = KeychainAccess.shared.retrieveToken() {
                delegate?.profileLoginModelController(self, didLogin: sessionId)
            }
            else {
                let vc = GetLoginWebViewController()
                vc.delegate = self
                self.present(vc, animated: true)
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

    func setSessionId(_ sessionId: String, _ completion: (() -> Void)) {
        KeychainAccess.shared.saveToken(sessionId: sessionId)
        if !Networking.default.sessionId.isEmpty {
            delegate?.profileLoginModelController(self, didLogin: sessionId)
            completion()
        }
    }

}
