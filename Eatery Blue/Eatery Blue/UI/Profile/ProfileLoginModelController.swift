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

        if let credentials = try? NetIDKeychainManager.shared.get() {
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
        updateLoginButtonFromState()
    }

    @objc private func passwordTextFieldEditingChanged() {
        updateLoginButtonFromState()
    }

    override func didTapLoginButton() {
        super.didTapLoginButton()

        do {
            let credentials = NetIDKeychainManager.Credentials(netId: netId, password: password)
            try NetIDKeychainManager.shared.save(credentials)

            Task {
                await Networking.default.sessionId.invalidate()
                attemptLogin()
            }

        } catch NetIDKeychainManager.KeychainError.unhandledError(status: let status) {
            logger.error("\(#function): \(SecCopyErrorMessageString(status, nil) ?? "nil" as CFString)")
            updateErrorMessage("Internal error, please try again later")

        } catch {
            logger.error("\(#function): \(error)")
            updateErrorMessage("Internal error, please try again later")
        }
    }

    private func updateLoginButtonFromState() {
        setLoginButtonEnabled(isLoginEnabled)

        if isLoggingIn {
            setLoginButtonTitle("Logging in...")
        } else {
            setLoginButtonTitle("Log in")
        }
    }

    private func attemptLogin() {
        guard isLoginEnabled else {
            return
        }

        isLoggingIn = true
        view.endEditing(true)
        updateErrorMessage(nil)
        updateLoginButtonFromState()

        Task {
            do {
                let sessionId = try await Networking.default.sessionId.fetch(maxStaleness: .infinity)
                delegate?.profileLoginModelController(self, didLogin: sessionId)

            } catch GetAPIError.loginFailed {
                updateErrorMessage("NetID and/or password incorrect, please try again")

            } catch GetAPIError.emptyNetId {
                updateErrorMessage("Please enter a NetID")

            } catch GetAPIError.emptyPassword {
                updateErrorMessage("Please enter a password")

            } catch {
                updateErrorMessage("Internal error, please try again later")
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
