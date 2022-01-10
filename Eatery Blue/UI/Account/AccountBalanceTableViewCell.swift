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
        iconView.centerYToSuperview()
        iconView.width(16)
        iconView.height(16)
        iconView.leading(to: contentView.layoutMarginsGuide)

        titleLabel.leadingToTrailing(of: iconView, offset: 8)
        titleLabel.top(to: contentView.layoutMarginsGuide)
        titleLabel.bottom(to: contentView.layoutMarginsGuide)

        subtitleLabel.leadingToTrailing(of: titleLabel, offset: 8)
        subtitleLabel.top(to: contentView.layoutMarginsGuide)
        subtitleLabel.bottom(to: contentView.layoutMarginsGuide)
        subtitleLabel.trailing(to: contentView.layoutMarginsGuide)
        subtitleLabel.setContentHuggingPriority(
            titleLabel.contentHuggingPriority(for: .horizontal) + 1,
            for: .horizontal
        )
        subtitleLabel.setContentCompressionResistancePriority(
            titleLabel.contentCompressionResistancePriority(for: .horizontal) + 1,
            for: .horizontal
        )

        separator.bottomToSuperview()
        separator.leading(to: contentView.layoutMarginsGuide)
        separator.trailing(to: contentView.layoutMarginsGuide)
    }

}
