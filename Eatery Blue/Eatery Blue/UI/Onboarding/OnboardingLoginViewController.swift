//
//  OnboardingLoginViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/4/22.
//

import UIKit

class OnboardingLoginViewController: UIViewController {

    private let backButton = ContainerView(content: UIImageView())
    private let skipButton = ContainerView(content: UILabel())
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

        // Since the loginButton is tracking the keyboard, layout the view beforehand so the keyboard animation doesn't
        // also animate every other subview.
        view.layoutIfNeeded()
    }

    private func setUpView() {
        view.backgroundColor = .white

        view.addSubview(backButton)
        setUpBackButton()

        view.addSubview(skipButton)
        setUpSkipButton()

        view.addSubview(scrollView)
        setUpScrollView()

        view.addSubview(loginButton)
        setUpLoginButton()
    }

    private func setUpBackButton() {
        backButton.content.image = UIImage(named: "ArrowLeft")?.withRenderingMode(.alwaysTemplate)
        backButton.content.tintColor = UIColor(named: "Black")
        backButton.content.contentMode = .scaleAspectFit
        backButton.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)

        backButton.tap { [self] _ in
            navigationController?.popViewController(animated: true)
        }
    }

    private func setUpSkipButton() {
        skipButton.content.font = .preferredFont(for: .body, weight: .semibold)
        skipButton.content.text = "Skip"

        skipButton.tap { [self] _ in
            didTapSkipButton()
        }
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

        loginButton.tap { [self] _ in
            didTapLoginButton()
        }
    }

    private func setUpConstraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(12)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.width.height.equalTo(34)
        }

        skipButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(12)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(34)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        loginView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        loginButton.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(12)
            make.bottom.lessThanOrEqualTo(view.keyboardLayoutGuide.snp.top).offset(-12)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(12).priority(.high)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-12).priority(.high)
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

    func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: "didOnboard")
        NotificationCenter.default.post(name: RootModelController.didFinishOnboardingNotification, object: nil)
    }

}
