//
//  ProfileLoginViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/7/22.
//

import UIKit

class ProfileLoginViewController: UIViewController {

    let settingsButton = ContainerView(content: UIImageView())
    private let scrollView = UIScrollView()
    private let loginView = LoginView()
    let netIdTextField = UITextField()
    let passwordTextField = UITextField()
    private let errorMessageView = LoginErrorMessageView()
    private let loginButton = ButtonView(pillContent: UILabel())

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpConstraints()

        setLoginButtonEnabled(false)
        updateErrorMessage(nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        RootViewController.setStatusBarStyle(.darkContent)
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
        settingsButton.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    private func setUpScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isPagingEnabled = true

        scrollView.tap { [self] _ in
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
        netIdTextField.placeholder = "Type your NetID (i.e. abc123)"
    }

    private func setUpPasswordTextField() {
        passwordTextField.font = .preferredFont(for: .footnote, weight: .medium)
        passwordTextField.placeholder = "Type your password..."
    }

    private func setUpLoginButton() {
        loginButton.content.text = "Log in"
        loginButton.content.font = .preferredFont(for: .body, weight: .semibold)
        loginButton.content.textAlignment = .center
        loginButton.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)

        loginButton.buttonPress { [self] _ in
            didTapLoginButton()
        }
    }

    private func setUpConstraints() {
        settingsButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(6)
            make.width.height.equalTo(44)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(settingsButton.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        loginView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        loginButton.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)

            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(12).priority(.high)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(12)

            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-12).priority(.high)
            make.bottom.lessThanOrEqualTo(view.keyboardLayoutGuide.snp.top).offset(-12)
        }
        loginButton.content.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    func didTapLoginButton() {
    }

    private func didTapSkipButton() {
        NotificationCenter.default.post(name: RootModelController.didFinishOnboardingNotification, object: nil)
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

    func setLoginButtonTitle(_ title: String) {
        loginButton.content.text = title
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
