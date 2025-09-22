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
    private let nextButton = ButtonView(pillContent: UILabel())
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
        eateryLogoView.tintColor = UIColor.Eatery.blue
    }

    private func setUpTitleLabel() {
        titleLabel.text = "Eatery"
        titleLabel.textColor = UIColor.Eatery.blue
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
        nextButton.shadowColor = UIColor.Eatery.shadowLight
        nextButton.shadowOpacity = 0.25
        nextButton.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)

        nextButton.buttonPress { [self] _ in
            let viewController = OnboardingFeaturesViewController()
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    private func setUpAppDevLogoView() {
        appDevLogoView.image = UIImage(named: "AppDev")?.withRenderingMode(.alwaysTemplate)
        appDevLogoView.tintColor = UIColor.Eatery.gray03
        appDevLogoView.contentMode = .scaleAspectFit
    }

    private func setUpConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.centerY)
            make.centerX.equalToSuperview()
        }

        eateryLogoView.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.height.equalTo(96)
            make.bottom.equalTo(titleLabel.snp.top)
        }

        nextButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(48)
        }

        appDevLogoView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(12)
            make.height.equalTo(16)
            make.centerX.equalToSuperview()
        }
    }
}
