//
//  OnboardingStartViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/3/22.
//

import UIKit

class OnboardingStartViewController: UIViewController {

    private let eateryLogoView = UIImageView()
    private let titleLabel = UILabel()
    private let nextButton = ContainerView(pillContent: UILabel())
    private let appDevLogoView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpConstraints()
    }

    private func setUpView() {
        view.backgroundColor = .white

        view.addSubview(eateryLogoView)
        setUpEateryLogoView()

        view.addSubview(titleLabel)
        setUpTitleLabel()

        view.addSubview(nextButton)
        setUpNextButton()

        view.addSubview(appDevLogoView)
        setUpAppDevLogoView()
    }

    private func setUpEateryLogoView() {
        eateryLogoView.image = UIImage(named: "Eatery")?.withRenderingMode(.alwaysTemplate)
        eateryLogoView.tintColor = UIColor(named: "EateryBlue")
    }

    private func setUpTitleLabel() {
        titleLabel.text = "Eatery"
        titleLabel.textColor = UIColor(named: "EateryBlue")
        titleLabel.font = .systemFont(ofSize: 48, weight: .bold)
    }

    private func setUpNextButton() {
        nextButton.content.text = "Get started"
        nextButton.content.font = .preferredFont(for: .body, weight: .semibold)
        nextButton.content.textAlignment = .center

        nextButton.backgroundColor = .white
        nextButton.shadowOffset = CGSize(width: 0, height: 4)
        nextButton.cornerRadius = 8
        nextButton.shadowRadius = 4
        nextButton.shadowOffset = CGSize(width: 0, height: 4)
        nextButton.shadowColor = UIColor(named: "ShadowLight")
        nextButton.shadowOpacity = 0.25
        nextButton.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)

        nextButton.on(UITapGestureRecognizer()) { [self] _ in
            let viewController = OnboardingFeaturesViewController()
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    private func setUpAppDevLogoView() {
        appDevLogoView.image = UIImage(named: "AppDev")?.withRenderingMode(.alwaysTemplate)
        appDevLogoView.tintColor = UIColor(named: "Gray03")
    }

    private func setUpConstraints() {
        titleLabel.bottom(to: view, view.layoutMarginsGuide.centerYAnchor)
        titleLabel.centerXToSuperview()

        eateryLogoView.centerXToSuperview()
        eateryLogoView.width(96)
        eateryLogoView.height(96)
        eateryLogoView.bottomToTop(of: titleLabel)

        nextButton.topToBottom(of: titleLabel, offset: 24)
        nextButton.leadingToSuperview(offset: 48)
        nextButton.trailingToSuperview(offset: 48)

        appDevLogoView.bottom(to: view.layoutMarginsGuide, offset: -12)
        appDevLogoView.height(16)
        appDevLogoView.centerXToSuperview()
    }

}
