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
        backgroundColor = UIColor.Eatery.gray00

        addSubview(imageView)
        setUpImageView()

        addSubview(titleLabel)
        setUpTitleLabel()
    }

    private func setUpImageView() {
        imageView.image = UIImage(named: "Exit")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor.Eatery.black
    }

    private func setUpTitleLabel() {
        titleLabel.text = "Log out"
        titleLabel.font = .preferredFont(for: .caption1, weight: .semibold)
        titleLabel.tintColor = UIColor.Eatery.black
    }

    private func setUpConstraints() {
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.leading.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(4)
            make.top.bottom.equalToSuperview().inset(8)
            make.trailing.equalToSuperview().inset(10)
        }
        titleLabel.setContentHuggingPriority(
            imageView.contentHuggingPriority(for: .horizontal) + 1,
            for: .horizontal
        )
        titleLabel.setContentHuggingPriority(
            imageView.contentHuggingPriority(for: .vertical) + 1,
            for: .vertical
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }

}
