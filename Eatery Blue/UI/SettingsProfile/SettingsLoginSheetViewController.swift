//
//  SettingsLoginSheetViewController.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 1/5/25.
//

import UIKit
import GoogleSignIn

class SettingsLoginSheetViewController: SheetViewController {

    // MARK: - Properties (view)

    private let descriptionLabel = UILabel()
    private let featuresStackView = UIStackView()
    private let loginButton = ButtonView(content: PillButtonView())

    // MARK: - Properties (data)

    private var loggingIn = false
    private var successCallback: ((UIViewController) -> Void)?

    // MARK: - Init

    init() {
        super.init(nibName: nil, bundle: nil)

        setUpSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup

    private func setUpSelf() {
        super.viewDidLoad()

        stackView.addArrangedSubview(descriptionLabel)
        setUpDescriptionLabel()

        stackView.addArrangedSubview(featuresStackView)
        setUpFeaturesStackView()

        stackView.addArrangedSubview(loginButton)
        setUpLoginButton()

        setUpConstraints()
    }

    private func setUpDescriptionLabel() {
        descriptionLabel.text = "Log in to Eatery to..."
        descriptionLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        descriptionLabel.textColor = .black
        descriptionLabel.numberOfLines = 0
    }

    private func setUpFeaturesStackView() {
        featuresStackView.axis = .vertical
        featuresStackView.spacing = 8
        featuresStackView.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

        addFeatureItem("Save your favorites")
        addFeatureItem("Get meal recommendations")
        addFeatureItem("More coming soon...")
    }

    private func setUpLoginButton() {
        loginButton.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
        let pillView = loginButton.content
        pillView.titleLabel.text = "Log in with Google"
        pillView.titleLabel.textColor = .white
        pillView.backgroundColor = UIColor.Eatery.blue
        pillView.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        loginButton.buttonPress { [weak self] _ in
            guard let self else { return }

            if loggingIn { return }

            loggingIn = true
            updateLoginButtonFromState()

            GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] signInResult, error in
                guard let self else { return }

                loggingIn = false
                updateLoginButtonFromState()
                guard error == nil else { return }
                guard let signInResult = signInResult else { return }

                successCallback?(self)
            }
        }
    }

    private func setUpConstraints() {
        loginButton.snp.makeConstraints { make in
            make.height.equalTo(64)
        }

        featuresStackView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(12)
        }

        loginButton.content.titleLabel.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func updateLoginButtonFromState() {
        if loggingIn {
            loginButton.content.titleLabel.text = "Logging in..."
            loginButton.content.titleLabel.textColor = UIColor.Eatery.gray03
            loginButton.content.backgroundColor = UIColor.Eatery.gray01
        } else {
            loginButton.content.titleLabel.text = "Log in with Google"
            loginButton.content.titleLabel.textColor = .white
            loginButton.content.backgroundColor = UIColor.Eatery.blue
        }
    }

    private func addFeatureItem(_ text: String) {
        let container = UIView()
        let imageView = UIImageView()
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 18, weight: .regular)
        titleLabel.text = text
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.Eatery.blue

        container.addSubview(imageView)
        container.addSubview(titleLabel)

        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(18)
            make.leading.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(8)
            make.top.trailing.bottom.equalToSuperview()
        }

        featuresStackView.addArrangedSubview(container)
    }

    func onSuccess(_ callback: @escaping (UIViewController) -> Void) {
        successCallback = callback
    }

}
