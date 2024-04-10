//
//  CompareMenusExternalOnboardingView.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 3/31/24.
//

import EateryModel
import UIKit

class CompareMenusExternalOnboardingView: UIView {

    // MARK: - Properties (view)

    private let actionLabel = UILabel()
    private let arrowImage = UIImageView()
    let compareMenusButton = UIView()
    private let compareMenusImage = UIImageView()
    private let dismissLabel = UILabel()

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        
        setUpSelf()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setUpSelf() {
        backgroundColor = .black.withAlphaComponent(0.75)
        self.tap { [weak self] _ in
            guard let self else { return }
            dismiss()
        }

        setUpDismissLabel()
        addSubview(dismissLabel)

        setUpActionLabel()
        addSubview(actionLabel)

        setUpArrowImage()
        addSubview(arrowImage)

        setUpCompareMenusButton()
        compareMenusButton.addSubview(compareMenusImage)
        addSubview(compareMenusButton)

        setUpConstraints()
    }

    func dismiss() {
        self.layer.opacity = 1
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.didExternallyOnboardCompareMenus)
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self else { return }
            self.layer.opacity = 0.01
        } completion: { [weak self] _ in
            guard let self else { return }
            removeFromSuperview()
        }
    }

    private func setUpDismissLabel() {
        dismissLabel.text = "Tap to dismiss"
        dismissLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        dismissLabel.textColor = .white
    }

    private func setUpActionLabel() {
        actionLabel.text = "Compare dining menus easily"
        actionLabel.font = .systemFont(ofSize: 40, weight: .semibold)
        actionLabel.textColor = .white
        actionLabel.lineBreakMode = .byWordWrapping
        actionLabel.numberOfLines = 0
    }

    private func setUpArrowImage() {
        arrowImage.image = UIImage(named: "Arrow")
    }

    private func setUpCompareMenusButton() {
        compareMenusButton.backgroundColor = UIColor.Eatery.blue
        compareMenusButton.layer.cornerRadius = 56 / 2
        compareMenusImage.image = UIImage(named: "CompareMenus")
    }

    private func setUpConstraints() {
        compareMenusButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(108)
            make.size.equalTo(56)
        }

        compareMenusImage.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.center.equalToSuperview()
        }

        arrowImage.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(70)
            make.bottom.equalTo(compareMenusButton.snp.top)
        }

        actionLabel.snp.makeConstraints { make in
            make.bottom.equalTo(arrowImage.snp.bottom).inset(30)
            make.leading.equalToSuperview().inset(16)
            make.width.equalTo(250)
            make.height.equalTo(144)
        }

        dismissLabel.snp.makeConstraints { make in
            make.leading.equalTo(actionLabel.snp.leading)
            make.bottom.equalTo(actionLabel.snp.top).inset(-8)
        }
    }

}
