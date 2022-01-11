//
//  ProfileLoginModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/7/22.
//

import UIKit

protocol ProfileLoginModelControllerDelegate: AnyObject {

    func profileLoginModelController(_ viewController: ProfileLoginModelController, didLogin sessionId: String)

}

class ProfileLoginModelController: ProfileLoginViewController {

    private var netId: String {
        netIdTextField.text ?? ""
    }
    private var password: String {
        passwordTextField.text ?? ""
    }
    private var isLoggingIn: Bool = false

    private var isLoginEnabled: Bool {
        return !isLoggingIn && !netId.isEmpty && !password.isEmpty
    }

    weak var delegate: ProfileLoginModelControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNetIdTextField()
        setUpPasswordTextField()
        setUpSettingsButton()
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)

        if parent != nil, let credentials = try? KeychainManager.shared.get() {
            netIdTextField.text = credentials.netId
            passwordTextField.text = "        "
            attemptLogin()
        }
    }

    private func setUpNetIdTextField() {
        netIdTextField.autocapitalizationType = .none
        netIdTextField.autocorrectionType = .no
        netIdTextField.addTarget(self, action: #selector(netIdTextFieldEditingChanged), for: .editingChanged)
        netIdTextField.delegate = self
    }

    private func setUpPasswordTextField() {
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldEditingChanged), for: .editingChanged)
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self
    }

    @objc private func netIdTextFieldEditingChanged() {
        updateLoginButtonEnabledFromState()
    }

    @objc private func passwordTextFieldEditingChanged() {
        updateLoginButtonEnabledFromState()
    }

    override func didTapLoginButton() {
        super.didTapLoginButton()

        do {
            let credentials = KeychainManager.Credentials(netId: netId, password: password)
            try KeychainManager.shared.save(credentials)

            Task {
                await Networking.default.sessionId.invalidate()
                attemptLogin()
            }

        } catch KeychainManager.KeychainError.unhandledError(status: let status) {
            logger.error("\(SecCopyErrorMessageString(status, nil) ?? "nil" as CFString)")
            updateErrorMessage("Internal error, please try again later")

        } catch {
            updateErrorMessage("Internal error, please try again later")
        }
    }

    private func updateLoginButtonEnabledFromState() {
        setLoginButtonEnabled(isLoginEnabled)
    }

    private func attemptLogin() {
        guard isLoginEnabled else {
            return
        }

        isLoggingIn = true
        view.endEditing(true)
        updateErrorMessage(nil)
        updateLoginButtonEnabledFromState()

        Task {
            do {
                let sessionId = try await Networking.default.sessionId.fetch(maxStaleness: .infinity)
                delegate?.profileLoginModelController(self, didLogin: sessionId)

            } catch GetAccountLogin.LoginError.loginFailed {
                updateErrorMessage("NetID and/or password incorrect, please try again")

            } catch {
                updateErrorMessage("Internal error, please try again later")
            }

            isLoggingIn = false
            updateLoginButtonEnabledFromState()
        }
    }

    private func setUpSettingsButton() {
        settingsButton.on(UITapGestureRecognizer()) { [self] _ in
            let viewController = SettingsMainMenuModelController()
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

}

extension ProfileLoginModelController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == netIdTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            didTapLoginButton()
        }

        return false
    }

}
