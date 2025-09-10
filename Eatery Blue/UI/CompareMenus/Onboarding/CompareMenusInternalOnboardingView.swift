//
//  CompareMenusInternalOnboardingView.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 4/9/24.
//

import EateryModel
import UIKit

class CompareMenusInternalOnboardingView: UIView {
    // MARK: - Properties (view)

    private let actionLabel = UILabel()
    private let fingerSwipeImage = UIImageView()
    private let dismissLabel = UILabel()

    // MARK: - Init

    init() {
        super.init(frame: .zero)

        setUpSelf()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setUpSelf() {
        backgroundColor = .black.withAlphaComponent(0.75)
        tap { [weak self] _ in
            guard let self else { return }
            dismiss()
        }

        setUpDismissLabel()
        addSubview(dismissLabel)

        setUpActionLabel()
        addSubview(actionLabel)

        setUpFingerSwipeImage()
        addSubview(fingerSwipeImage)

        setUpConstraints()
    }

    func dismiss() {
        layer.opacity = 1
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.didInternallyOnboardCompareMenus)
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
        actionLabel.text = "Swipe to compare menus"
        actionLabel.font = .systemFont(ofSize: 40, weight: .semibold)
        actionLabel.textColor = .white
        actionLabel.lineBreakMode = .byWordWrapping
        actionLabel.numberOfLines = 0
    }

    private func setUpFingerSwipeImage() {
        fingerSwipeImage.image = UIImage(named: "FingerSwipe")
        fingerSwipeImage.contentMode = .scaleAspectFill
    }

    private func setUpConstraints() {
        fingerSwipeImage.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.leading.equalTo(self.snp.centerX).inset(10)
            make.bottom.equalToSuperview().inset(235)
        }

        actionLabel.snp.makeConstraints { make in
            make.bottom.equalTo(fingerSwipeImage.snp.bottom)
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalTo(self.snp.centerX).inset(10)
        }

        dismissLabel.snp.makeConstraints { make in
            make.leading.equalTo(actionLabel.snp.leading)
            make.bottom.equalTo(actionLabel.snp.top).inset(-8)
        }
    }
}
