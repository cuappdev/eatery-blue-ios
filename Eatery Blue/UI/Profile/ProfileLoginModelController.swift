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
        _ = loginOnLaunch
    }

    override init(canGoBack: Bool) {
        super.init(canGoBack: canGoBack)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
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
        if KeychainAccess.shared.retrieveToken() != nil {
            attemptLogin()
        } else if firstView, UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasLoggedIn) {
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
                delegate?.profileLoginModelController(self, didLogin: sessionId)
            } else {
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
    func setSessionId(_ sessionId: String, _ completion: () -> Void) {
        KeychainAccess.shared.saveToken(sessionId: sessionId)
        if !Networking.default.sessionId.isEmpty {
            delegate?.profileLoginModelController(self, didLogin: sessionId)
            completion()
        }
    }
}
