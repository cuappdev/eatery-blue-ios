//
//  OnboardingLoginModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/6/22.
//

import UIKit
import EateryGetAPI

class OnboardingLoginModelController: OnboardingLoginViewController {

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

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNetIdTextField()
        setUpPasswordTextField()

        netIdTextField.becomeFirstResponder()
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

        attemptLogin()
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
                let credentials = GetKeychainManager.Credentials(netId: netId, password: password)
                try GetKeychainManager.shared.save(credentials)
                _ = try await Networking.default.sessionId.fetch(maxStaleness: 0)
                finishOnboarding()

            } catch GetAPIError.loginFailed {
                updateErrorMessage("NetID and/or password incorrect, please try again")
                
            } catch GetKeychainManager.KeychainError.unhandledError(status: let status) {
                logger.error("\(SecCopyErrorMessageString(status, nil) ?? "nil" as CFString)")
                updateErrorMessage("Internal error, please try again later")

            } catch {
                updateErrorMessage("Internal error, please try again later")
            }

            isLoggingIn = false
            updateLoginButtonEnabledFromState()
        }
    }

}

extension OnboardingLoginModelController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == netIdTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            attemptLogin()
        }

        return false
    }

}
