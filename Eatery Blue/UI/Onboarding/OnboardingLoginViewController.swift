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
    private let loginButton = ButtonView(pillContent: UILabel())

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpConstraints()

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
        backButton.content.tintColor = UIColor.Eatery.black
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
    }

    private func setUpLoginButton() {
        loginButton.content.text = "Log in"
        loginButton.content.font = .preferredFont(for: .body, weight: .semibold)
        loginButton.content.textAlignment = .center
        loginButton.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        loginButton.content.textColor = .white
        loginButton.backgroundColor = UIColor.Eatery.blue

        loginButton.buttonPress { [self] _ in
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
        // Override point for a subclass
    }

    private func didTapSkipButton() {
        NotificationCenter.default.post(name: RootModelController.didFinishOnboardingNotification, object: nil)
    }

    func setLoginButtonTitle(_ title: String) {
        loginButton.content.text = title
    }

    func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.didOnboard)
        NotificationCenter.default.post(name: RootModelController.didFinishOnboardingNotification, object: nil)
    }

}
