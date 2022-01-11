//
//  SettingsLogoutPillButton.swift
//  Eatery Blue
//
//  Created by William Ma on 1/11/22.
//

import UIKit

class SettingsLogoutPillButton: UIView {

    let imageView = UIImageView()
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        backgroundColor = UIColor(named: "Gray00")

        addSubview(imageView)
        setUpImageView()

        addSubview(titleLabel)
        setUpTitleLabel()
    }

    private func setUpImageView() {
        imageView.image = UIImage(named: "Exit")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor(named: "Black")
    }

    private func setUpTitleLabel() {
        titleLabel.text = "Log out"
        titleLabel.font = .preferredFont(for: .caption1, weight: .semibold)
        titleLabel.tintColor = UIColor(named: "Black")
    }

    private func setUpConstraints() {
        imageView.width(16)
        imageView.height(16)
        imageView.leadingToSuperview(offset: 10)
        imageView.centerYToSuperview()

        titleLabel.leadingToTrailing(of: imageView, offset: 4)
        titleLabel.topToSuperview(offset: 8)
        titleLabel.bottomToSuperview(offset: -8)
        titleLabel.trailingToSuperview(offset: 10)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }

}
