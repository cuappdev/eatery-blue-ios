//
//  SettingsAboutViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/26/22.
//

import UIKit

class SettingsAboutViewController: UIViewController {
    private let subtitleLabel = UILabel()

    private let headerView = SettingsAboutAppDevHeaderView()

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    private let websiteButton = ButtonView(content: PillButtonView())

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        scrollView.flashScrollIndicators()
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

        navigationItem.title = "About Eatery"

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
        backButton.tintColor = UIColor.Eatery.black
        navigationItem.leftBarButtonItem = backButton
    }

    private func setUpView() {
        view.backgroundColor = .white

        view.addSubview(subtitleLabel)
        setUpSubtitleLabel()

        view.addSubview(headerView)
        setUpHeaderView()

        view.addSubview(scrollView)
        setUpScrollView()

        view.addSubview(websiteButton)
        setUpWebsiteButton()
    }

    private func setUpSubtitleLabel() {
        subtitleLabel.text = "Learn more about Cornell AppDev"
        subtitleLabel.textColor = UIColor.Eatery.gray06
        subtitleLabel.font = .preferredFont(for: .body, weight: .medium)
    }

    private func setUpHeaderView() {}

    private func setUpScrollView() {
        scrollView.addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.axis = .vertical
    }

    private func setUpWebsiteButton() {
        let pillView = websiteButton.content
        pillView.titleLabel.text = "Visit our website"
        pillView.imageView.image = UIImage(named: "Globe")?.withRenderingMode(.alwaysTemplate)
        pillView.tintColor = UIColor.Eatery.black
        pillView.backgroundColor = UIColor.Eatery.gray00
        pillView.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        websiteButton.buttonPress { _ in
            if let url = URL(string: "https://www.cornellappdev.com/") {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }

    private func setUpConstraints() {
        subtitleLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(view.layoutMarginsGuide)
        }

        headerView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalTo(view.layoutMarginsGuide)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(websiteButton.snp.top).offset(-24)
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        websiteButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.layoutMarginsGuide)
            make.bottom.equalTo(view.layoutMarginsGuide).inset(16)
        }
    }

    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }

    func addCarouselView(_ configure: (SettingsAboutMembersCarouselView) -> Void) {
        let carouselView = SettingsAboutMembersCarouselView()
        configure(carouselView)
        stackView.addArrangedSubview(carouselView)
    }
}
