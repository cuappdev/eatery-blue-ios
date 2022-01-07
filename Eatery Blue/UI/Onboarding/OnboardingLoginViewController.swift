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
    private let stackView = UIStackView()
    let netIdTextField = UITextField()
    let passwordTextField = UITextField()
    private let errorMessageView = ContainerView(content: UILabel())
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

        backButton.on(UITapGestureRecognizer()) { [self] _ in
            navigationController?.popViewController(animated: true)
        }
    }

    private func setUpSkipButton() {
        skipButton.content.font = .preferredFont(for: .body, weight: .semibold)
        skipButton.content.text = "Skip"

        skipButton.on(UITapGestureRecognizer()) { [self] _ in
            didTapSkipButton()
        }
    }

    private func setUpScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self

        scrollView.on(UITapGestureRecognizer()) { [self] _ in
            view.endEditing(true)
        }

        scrollView.addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill

        addTitleLabel()
        setCustomSpacing(8)
        addSubtitleLabel()
        setCustomSpacing(24)
        addFieldTitleLabel("NetID")
        setCustomSpacing(12)
        addTextField(netIdTextField)
        setCustomSpacing(24)
        addFieldTitleLabel("Password")
        setCustomSpacing(12)
        addTextField(passwordTextField)
        setCustomSpacing(24)
        addErrorMessageView()
    }

    private func setCustomSpacing(_ spacing: CGFloat) {
        if let last = stackView.arrangedSubviews.last {
            stackView.setCustomSpacing(spacing, after: last)
        }
    }

    private func addTitleLabel() {
        let titleLabel = UILabel()
        titleLabel.text = "Log in with Eatery"
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = UIColor(named: "EateryBlue")

        let container = ContainerView(content: titleLabel)
        container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.addArrangedSubview(container)
    }

    private func addSubtitleLabel() {
        let subtitleLabel = UILabel()
        subtitleLabel.text = "See your meal swipes, BRBs, and more"
        subtitleLabel.font = .preferredFont(for: .body, weight: .medium)
        subtitleLabel.textColor = UIColor(named: "Gray06")

        let container = ContainerView(content: subtitleLabel)
        container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.addArrangedSubview(container)
    }

    private func addFieldTitleLabel(_ title: String) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(for: .body, weight: .semibold)
        titleLabel.textColor = UIColor(named: "Black")

        let container = ContainerView(content: titleLabel)
        container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.addArrangedSubview(container)
    }

    private func addTextField(_ textField: UITextField) {
        textField.font = .preferredFont(for: .footnote, weight: .medium)

        let background = ContainerView(content: textField)
        background.backgroundColor = UIColor(named: "Gray00")
        background.cornerRadius = 8
        background.layoutMargins = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        background.on(UITapGestureRecognizer()) { _ in
            textField.becomeFirstResponder()
        }

        let container = ContainerView(content: background)
        container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.addArrangedSubview(container)
    }

    private func addErrorMessageView() {
        errorMessageView.content.textColor = UIColor(named: "EateryRed")
        errorMessageView.content.font = .preferredFont(for: .caption1, weight: .semibold)
        errorMessageView.layoutMargins = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        errorMessageView.cornerRadius = 8
        errorMessageView.backgroundColor = UIColor(named: "EateryRedLight")

        let container = ContainerView(content: errorMessageView)
        container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.addArrangedSubview(container)
    }

    private func setUpLoginButton() {
        loginButton.content.text = "Log in"
        loginButton.content.font = .preferredFont(for: .body, weight: .semibold)
        loginButton.content.textAlignment = .center
        loginButton.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)

        loginButton.on(UITapGestureRecognizer()) { [self] _ in
            didTapLoginButton()
        }
    }

    private func setUpConstraints() {
        backButton.topToSuperview(offset: 12, usingSafeArea: true)
        backButton.leadingToSuperview(offset: 16, usingSafeArea: true)
        backButton.width(34)
        backButton.height(34)

        skipButton.topToSuperview(offset: 12, usingSafeArea: true)
        skipButton.trailingToSuperview(offset: 16, usingSafeArea: true)
        skipButton.height(34)

        scrollView.topToBottom(of: backButton)
        scrollView.leadingToSuperview()
        scrollView.trailingToSuperview()

        stackView.edgesToSuperview()
        stackView.widthToSuperview()

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

            let attributedText = NSMutableAttributedString()
            attributedText.append(NSAttributedString(attachment: NSTextAttachment(
                image: UIImage(named: "Error")?.withRenderingMode(.alwaysTemplate),
                scaledToMatch: .preferredFont(for: .caption1, weight: .semibold)
            )))
            attributedText.append(NSAttributedString(string: " \(message)"))
            errorMessageView.content.attributedText = attributedText
        } else {
            errorMessageView.isHidden = true
        }
    }

    func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: "didOnboard")
        NotificationCenter.default.post(name: RootModelController.didFinishOnboardingNotification, object: nil)
    }

}

extension OnboardingLoginViewController: UIScrollViewDelegate {

}
