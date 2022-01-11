//
//  SettingsMainMenuCell.swift
//  Eatery Blue
//
//  Created by William Ma on 1/11/22.
//

import UIKit

class SettingsMainMenuCell: UIView {

    let imageView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let chevronImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        setUpImageView()

        addSubview(titleLabel)
        setUpTitleLabel()

        addSubview(subtitleLabel)
        setUpSubtitleLabel()

        addSubview(chevronImageView)
        setUpChevronImageView()
    }

    private func setUpImageView() {
        imageView.tintColor = UIColor(named: "Gray05")
        imageView.contentMode = .scaleAspectFit
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .body, weight: .semibold)
        titleLabel.textColor = UIColor(named: "Black")
    }

    private func setUpSubtitleLabel() {
        subtitleLabel.font = .preferredFont(for: .caption1, weight: .semibold)
        subtitleLabel.textColor = UIColor(named: "Gray05")
    }

    private func setUpChevronImageView() {
        chevronImageView.tintColor = UIColor(named: "EateryBlue")
        chevronImageView.image = UIImage(named: "ChevronRight")?.withRenderingMode(.alwaysTemplate)
    }

    private func setUpConstraints() {
        imageView.centerY(to: layoutMarginsGuide)
        imageView.leading(to: layoutMarginsGuide)
        imageView.width(24)
        imageView.height(24)

        titleLabel.top(to: layoutMarginsGuide)
        titleLabel.leadingToTrailing(of: imageView, offset: 8)
        titleLabel.trailingToLeading(of: chevronImageView, offset: -12)

        subtitleLabel.topToBottom(of: titleLabel, offset: 4)
        subtitleLabel.leadingToTrailing(of: imageView, offset: 8)
        subtitleLabel.bottom(to: layoutMarginsGuide)
        subtitleLabel.trailingToLeading(of: chevronImageView, offset: -12)

        chevronImageView.centerY(to: layoutMarginsGuide)
        chevronImageView.trailing(to: layoutMarginsGuide)
        chevronImageView.width(16)
        chevronImageView.height(16)
    }

}
