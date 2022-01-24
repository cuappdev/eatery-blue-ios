//
//  SettingsMainMenuViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/10/22.
//

import UIKit

class SettingsMainMenuViewController: UIViewController {

    struct SettingsItem {
        let image: UIImage?
        let title: String
        let subtitle: String
        let action: () -> Void
    }

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

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
            .foregroundColor: UIColor(named: "Black") as Any,
            .font: UIFont.eateryNavigationBarTitleFont
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(named: "EateryBlue") as Any,
            .font: UIFont.eateryNavigationBarLargeTitleFont
        ]

        navigationItem.title = "Settings"

        let standardAppearance = appearance.copy()
        standardAppearance.configureWithDefaultBackground()
        navigationItem.standardAppearance = standardAppearance

        let scrollEdgeAppearance = appearance.copy()
        scrollEdgeAppearance.configureWithTransparentBackground()
        navigationItem.scrollEdgeAppearance = scrollEdgeAppearance

        let backButton = UIBarButtonItem(
            image: UIImage(named: "ArrowLeft"),
            style: .plain,
            target: self,
            action: #selector(didTapBackButton)
        )
        backButton.tintColor = UIColor(named: "Black")
        navigationItem.leftBarButtonItem = backButton
    }

    private func setUpView() {
        view.backgroundColor = .white

        view.addSubview(scrollView)
        setUpScrollView()
    }

    private func setUpScrollView() {
        scrollView.alwaysBounceVertical = true

        scrollView.addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
    }

    func setCustomSpacing(_ spacing: CGFloat) {
        if let view = stackView.arrangedSubviews.last {
            stackView.setCustomSpacing(spacing, after: view)
        }
    }

    func addSettingsItem(_ settingsItem: SettingsItem) {
        let cell = SettingsMainMenuCell()
        cell.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        cell.imageView.image = settingsItem.image
        cell.titleLabel.text = settingsItem.title
        cell.subtitleLabel.text = settingsItem.subtitle
        cell.tap { _ in
            settingsItem.action()
        }

        stackView.addArrangedSubview(cell)
    }

    func addSeparator() {
        let separator = ContainerView(content: HDivider())
        separator.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        setCustomSpacing(0)
        stackView.addArrangedSubview(separator)
        setCustomSpacing(0)
    }

    func addLoginStatusView(_ netId: String, logOut: @escaping () -> Void) {
        let loginView = SettingsMainMenuLoginStatusView()
        loginView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        loginView.label.text = "Logged in as \(netId)"
        loginView.logoutButton.tap { _ in
            logOut()
        }

        stackView.addArrangedSubview(loginView)
    }

    private func setUpConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
    }

    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }

}
