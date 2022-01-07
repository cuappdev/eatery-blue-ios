//
//  OnboardingFeatureView.swift
//  Eatery Blue
//
//  Created by William Ma on 1/4/22.
//

import UIKit

class OnboardingFeatureView: UIView {

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(titleLabel)
        setUpTitleLabel()

        addSubview(subtitleLabel)
        setUpSubtitleLabel()

        addSubview(imageView)
        setUpImageView()
    }

    private func setUpTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = UIColor(named: "EateryBlue")
    }

    private func setUpSubtitleLabel() {
        subtitleLabel.font = .preferredFont(for: .body, weight: .medium)
        subtitleLabel.textColor = UIColor(named: "Gray06")
    }

    private func setUpImageView() {
        imageView.contentMode = .scaleAspectFit
    }

    private func setUpConstraints() {
        titleLabel.edges(to: layoutMarginsGuide, excluding: .bottom)

        subtitleLabel.topToBottom(of: titleLabel, offset: 8)
        subtitleLabel.leading(to: layoutMarginsGuide)
        subtitleLabel.trailing(to: layoutMarginsGuide)

        imageView.topToBottom(of: subtitleLabel, offset: 24)
        imageView.centerXToSuperview()
        imageView.bottom(to: layoutMarginsGuide)
        imageView.aspectRatio(9 / 19.5)
    }

}
