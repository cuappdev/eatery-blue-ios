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

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
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
        imageView.tintColor = UIColor.Eatery.secondaryText
        imageView.contentMode = .scaleAspectFit
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .body, weight: .semibold)
        titleLabel.textColor = UIColor.Eatery.primaryText
    }

    private func setUpSubtitleLabel() {
        subtitleLabel.font = .preferredFont(for: .caption1, weight: .semibold)
        subtitleLabel.textColor = UIColor.Eatery.secondaryText
    }

    private func setUpChevronImageView() {
        chevronImageView.tintColor = UIColor.Eatery.blue
        chevronImageView.image = UIImage(named: "ChevronRight")?.withRenderingMode(.alwaysTemplate)
    }

    private func setUpConstraints() {
        imageView.snp.makeConstraints { make in
            make.leading.centerY.equalTo(layoutMarginsGuide)
            make.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(layoutMarginsGuide)
            make.leading.equalTo(imageView.snp.trailing).offset(8)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(imageView.snp.trailing).offset(8)
            make.bottom.equalTo(layoutMarginsGuide)
        }

        chevronImageView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(12)
            make.leading.equalTo(subtitleLabel.snp.trailing).offset(12)
            make.centerY.trailing.equalTo(layoutMarginsGuide)
            make.width.height.equalTo(16)
        }
    }
}
