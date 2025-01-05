//
//  ProfileLoginModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/7/22.
//

import EateryGetAPI
import GoogleSignIn
import UIKit

protocol ProfileLoginModelControllerDelegate: AnyObject {

    func profileLoginModelController(_ viewController: ProfileLoginModelController, didLogin sessionId: String)

}

class ProfileLoginModelController: ProfileLoginViewController, AttemptLogin {

    private var firstView: Bool = true
    private var isLoggingIn: Bool = false

    weak var delegate: ProfileLoginModelControllerDelegate?
    

    init() {
        super.init(nibName: nil, bundle: nil)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                
            } else {

            }
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

        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] signInResult, error in
            guard let self else { return }
            guard error == nil else { return }
            guard let signInResult = signInResult else { return }

            let user = signInResult.user

            let emailAddress = user.profile?.email

            let fullName = user.profile?.name
            let givenName = user.profile?.givenName
            let familyName = user.profile?.familyName

            let profilePicUrl = user.profile?.imageURL(withDimension: 320)

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
