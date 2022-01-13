//
//  AccountBalanceTableViewCell.swift
//  Eatery Blue
//
//  Created by William Ma on 1/9/22.
//

import UIKit

class AccountBalanceTableViewCell: UITableViewCell {

    let iconView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let separator = HDivider()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setUpContentView()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpContentView() {
        contentView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        contentView.addSubview(iconView)
        setUpIconView()

        contentView.addSubview(titleLabel)
        setUpTitleLabel()

        contentView.addSubview(subtitleLabel)
        setUpSubtitleLabel()

        contentView.addSubview(separator)
    }

    private func setUpIconView() {
        iconView.tintColor = UIColor(named: "Gray05")
        iconView.contentMode = .scaleAspectFit
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .footnote, weight: .semibold)
        titleLabel.textColor = UIColor(named: "Black")
    }

    private func setUpSubtitleLabel() {
        subtitleLabel.font = .preferredFont(for: .footnote, weight: .semibold)
        subtitleLabel.textColor = UIColor(named: "Black")
    }

    private func setUpConstraints() {
        iconView.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.layoutMarginsGuide)
            make.width.height.equalTo(16)
            make.leading.equalTo(contentView.layoutMarginsGuide)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(8)
            make.top.bottom.equalTo(contentView.layoutMarginsGuide)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
            make.top.trailing.bottom.equalTo(layoutMarginsGuide)
        }
        subtitleLabel.setContentHuggingPriority(
            titleLabel.contentHuggingPriority(for: .horizontal) + 1,
            for: .horizontal
        )
        subtitleLabel.setContentCompressionResistancePriority(
            titleLabel.contentCompressionResistancePriority(for: .horizontal) + 1,
            for: .horizontal
        )

        separator.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalTo(contentView.layoutMarginsGuide)
        }
    }

}
