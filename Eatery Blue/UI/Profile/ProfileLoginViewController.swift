//
//  ProfileLoginViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/7/22.
//

import UIKit

class ProfileLoginViewController: UIViewController {

    private let settingsButton = ContainerView(content: UIImageView())
    private let scrollView = UIScrollView()
    private let loginView = LoginView()
    let netIdTextField = UITextField()
    let passwordTextField = UITextField()
    private let errorMessageView = LoginErrorMessageView()
    private let loginButton = ContainerView(pillContent: UILabel())

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpConstraints()

        setLoginButtonEnabled(false)
        updateErrorMessage(nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    private func setUpView() {
        view.backgroundColor = .white

        view.addSubview(settingsButton)
        setUpSettingsButton()

        view.addSubview(scrollView)
        setUpScrollView()

        view.addSubview(loginButton)
        setUpLoginButton()
    }

    private func setUpSettingsButton() {
        settingsButton.content.image = UIImage(named: "Settings")?.withRenderingMode(.alwaysTemplate)
        settingsButton.content.tintColor = UIColor(named: "Black")
        settingsButton.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }

    private func setUpScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isPagingEnabled = true

        scrollView.on(UITapGestureRecognizer()) { [self] _ in
            view.endEditing(true)
        }

        scrollView.addSubview(loginView)
        setUpLoginView()
    }

    private func setUpLoginView() {
        loginView.addTitleLabel("Log in with Eatery")
        loginView.setCustomSpacing(8)
        loginView.addSubtitleLabel("See your meal swipes, BRBs, and more")
        loginView.setCustomSpacing(24)
        loginView.addFieldTitleLabel("NetID")
        loginView.setCustomSpacing(12)
        loginView.addTextField(netIdTextField)
        setUpNetIdTextField()
        loginView.setCustomSpacing(24)
        loginView.addFieldTitleLabel("Password")
        loginView.setCustomSpacing(12)
        loginView.addTextField(passwordTextField)
        setUpPasswordTextField()
        loginView.setCustomSpacing(24)
        loginView.addCustomView(errorMessageView)
    }

    private func setUpNetIdTextField() {
        netIdTextField.font = .preferredFont(for: .footnote, weight: .medium)
    }

    private func setUpPasswordTextField() {
        passwordTextField.font = .preferredFont(for: .footnote, weight: .medium)
    }

    private func setUpLoginButton() {
        loginButton.content.text = "Log in"
        loginButton.content.font = .preferredFont(for: .body, weight: .semibold)
        loginButton.content.textAlignment = .center
        loginButton.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
    }

    private func setUpConstraints() {
        settingsButton.topToSuperview(offset: 12, usingSafeArea: true)
        settingsButton.trailingToSuperview(offset: 16, usingSafeArea: true)
        settingsButton.height(34)

        scrollView.topToBottom(of: settingsButton)
        scrollView.leadingToSuperview()
        scrollView.trailingToSuperview()

        loginView.edgesToSuperview()
        loginView.widthToSuperview()

        loginButton.topToBottom(of: scrollView)
        loginButton.leadingToSuperview(offset: 16, usingSafeArea: true)
        loginButton.trailingToSuperview(offset: 16, usingSafeArea: true)
        loginButton.bottomToSuperview(offset: -12, usingSafeArea: true)
        loginButton.content.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    func didTapLoginButton() {

    }

    private func didTapSkipButton() {
        NotificationCenter.default.post(name: RootModelController.didFinishOnboardingNotification, object: nil)
    }

    @objc private func keyboardWillChangeFrame(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        let keyboardFrameInViewCoordinates = view.convert(keyboardFrame, from: nil)
        let intersection = view.frame.intersection(keyboardFrameInViewCoordinates)

        let delta = intersection.height - view.safeAreaInsets.bottom
        additionalSafeAreaInsets.bottom += delta
        additionalSafeAreaInsets.bottom = max(0, additionalSafeAreaInsets.bottom)
    }

    func setLoginButtonEnabled(_ isEnabled: Bool) {
        if isEnabled {
            loginButton.content.textColor = .white
            loginButton.backgroundColor = UIColor(named: "EateryBlue")
        } else {
            loginButton.content.textColor = UIColor(named: "EateryBlack")
            loginButton.backgroundColor = UIColor(named: "Gray00")
        }
    }

    func updateErrorMessage(_ message: String?) {
        if let message = message {
            errorMessageView.isHidden = false
            errorMessageView.messageLabel.text = message
        } else {
            errorMessageView.isHidden = true
        }
    }

}
