//
//  ProfileLoginViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/7/22.
//

import UIKit

class ProfileLoginViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let loginView = LoginView()
    let netIdTextField = UITextField()
    let passwordTextField = UITextField()
    private let errorMessageView = AlertMessageView()
    private let loginButton = ButtonView(pillContent: UILabel())

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationItem()
        setUpView()
        setUpConstraints()

        setLoginButtonEnabled(false)
        updateErrorMessage(nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        RootViewController.setStatusBarStyle(.darkContent)
    }

    private func setUpNavigationItem() {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(named: "Black") as Any,
            .font: UIFont.eateryNavigationBarTitleFont
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(named: "EateryBlue") as Any,
            .font: UIFont.eateryNavigationBarLargeTitleFont
        ]

        navigationItem.title = "Log in with Eatery"

        let standardAppearance = appearance.copy()
        standardAppearance.configureWithDefaultBackground()
        navigationItem.standardAppearance = standardAppearance

        let scrollEdgeAppearance = appearance.copy()
        scrollEdgeAppearance.configureWithTransparentBackground()
        navigationItem.scrollEdgeAppearance = scrollEdgeAppearance

        let settingsItem = UIBarButtonItem(
            image: UIImage(named: "Settings"),
            style: .plain,
            target: self,
            action: #selector(didTapSettingsButton)
        )
        settingsItem.tintColor = UIColor(named: "Black")
        navigationItem.rightBarButtonItem = settingsItem
    }

    private func setUpView() {
        view.backgroundColor = .white

        view.addSubview(scrollView)
        setUpScrollView()

        view.addSubview(loginButton)
        setUpLoginButton()
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
        setUpErrorMessageView()
    }

    private func setUpNetIdTextField() {
        netIdTextField.font = .preferredFont(for: .footnote, weight: .medium)
        netIdTextField.placeholder = "Type your NetID (i.e. abc123)"
    }

    private func setUpPasswordTextField() {
        passwordTextField.font = .preferredFont(for: .footnote, weight: .medium)
        passwordTextField.placeholder = "Type your password..."
    }

    private func setUpErrorMessageView() {
        errorMessageView.setStyleError()
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
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
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
        // Override point for a sublcass
    }

    @objc func didTapSettingsButton() {
        // Override point for a sublcass
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
