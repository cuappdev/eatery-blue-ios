//
//  AccountBalanceTableViewCell.swift
//  Eatery Blue
//
//  Created by William Ma on 1/9/22.
//

import UIKit

class AccountBalanceTableViewCell: UITableViewCell {
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let separator = HDivider()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setUpContentView()
        setUpConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpContentView() {
        contentView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        contentView.addSubview(titleLabel)
        setUpTitleLabel()

        contentView.addSubview(subtitleLabel)
        setUpSubtitleLabel()

        contentView.addSubview(separator)
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .subheadline, weight: .semibold)
        titleLabel.textColor = UIColor.Eatery.black
    }

    private func setUpSubtitleLabel() {
        subtitleLabel.font = .preferredFont(for: .subheadline, weight: .semibold)
        subtitleLabel.textColor = UIColor.Eatery.black
    }

    private func setUpConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView.layoutMarginsGuide)
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
