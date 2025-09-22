//
//  ProfileLoginViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/7/22.
//

import UIKit

class ProfileLoginViewController: UIViewController {
    // MARK: - Properties (view)

    private let backButton = ButtonView(content: UIImageView())
    private let eateryLogo = UIImageView()
    private let loginView = LoginView()
    private lazy var loginButton: ButtonView<UILabel> = ButtonView(pillContent: UILabel(), longPressDuration: 10)

    // MARK: - Properties (data)

    private var canGoBack = false

    // MARK: - Init

    init(canGoBack: Bool) {
        self.canGoBack = canGoBack
        super.init(nibName: nil, bundle: nil)
    }

    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationItem()
        setUpView()
        setUpConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        RootViewController.setStatusBarStyle(.darkContent)
    }

    private func setUpNavigationItem() {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.Eatery.black as Any,
            .font: UIFont.eateryNavigationBarTitleFont
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.Eatery.blue as Any,
            .font: UIFont.eateryNavigationBarLargeTitleFont
        ]

        navigationItem.title = ""

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
        settingsItem.tintColor = UIColor.Eatery.black
        navigationItem.rightBarButtonItem = settingsItem
    }

    private func setUpView() {
        view.backgroundColor = .white

        view.addSubview(loginView)
        setUpLoginView()

        view.addSubview(loginButton)
        setUpLoginButton()

        view.addSubview(eateryLogo)
        setUpLogo()

        if canGoBack {
            view.addSubview(backButton)
            setUpBackButton()
        }
    }

    private func setUpLogo() {
        eateryLogo.image = UIImage(named: "Eatery")
        eateryLogo.alpha = 0.4

        view.addSubview(eateryLogo)
    }

    private func setUpLoginView() {
        loginView.setCustomSpacing(8)
        loginView.addTitleLabel("Log in with Eatery")
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

        loginButton.buttonLongPress { [self] _ in
            didLongPressLoginButton()
        }
    }

    private func setUpBackButton() {
        backButton.content.image = UIImage(named: "ArrowLeft")
        backButton.shadowColor = UIColor.Eatery.black
        backButton.shadowOffset = CGSize(width: 0, height: 4)
        backButton.backgroundColor = .white
        backButton.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        backButton.buttonPress { [weak self] _ in
            guard let self else { return }

            navigationController?.popViewController(animated: true)
        }
    }

    private func setUpConstraints() {
        loginView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(96)
        }

        loginButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)

            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(12).priority(.high)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(12)
        }
        loginButton.content.setContentCompressionResistancePriority(.required, for: .vertical)

        eateryLogo.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(view.frame.width - 124)
        }

        if canGoBack {
            backButton.snp.makeConstraints { make in
                make.leading.equalToSuperview().inset(12)
                make.top.equalTo(view.layoutMarginsGuide.snp.top)
                make.width.height.equalTo(40)
            }
        }
    }

    func didTapLoginButton() {
        // Override point for a sublcass
    }

    func didLongPressLoginButton() {
        // Override point for a sublcass
    }

    @objc func didTapSettingsButton() {
        // Override point for a sublcass
    }

    func setLoginButtonTitle(_ title: String) {
        loginButton.content.text = title
    }
}
