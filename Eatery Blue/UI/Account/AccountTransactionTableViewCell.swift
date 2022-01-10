//
//  AccountTransactionTableViewCell.swift
//  Eatery Blue
//
//  Created by William Ma on 1/9/22.
//

import UIKit

class AccountTransactionTableViewCell: UITableViewCell {

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let amountLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setUpContentView()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpContentView() {
        addSubview(titleLabel)
        setUpTitleLabel()

        addSubview(subtitleLabel)
        setUpSubtitleLabel()

        addSubview(amountLabel)
        setUpAmountLabel()
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .footnote, weight: .semibold)
        titleLabel.textColor = UIColor(named: "EateryBlack")
    }

    private func setUpSubtitleLabel() {
        subtitleLabel.font = .preferredFont(for: .caption1, weight: .medium)
        subtitleLabel.textColor = UIColor(named: "Gray05")
    }

    private func setUpAmountLabel() {
        amountLabel.font = .preferredFont(for: .footnote, weight: .semibold)
        amountLabel.textColor = UIColor(named: "EateryBlack")
    }

    private func setUpConstraints() {
        titleLabel.top(to: layoutMarginsGuide)
        titleLabel.leading(to: layoutMarginsGuide)
        titleLabel.trailing(to: amountLabel)

        subtitleLabel.topToBottom(of: titleLabel)
        subtitleLabel.leading(to: layoutMarginsGuide)
        subtitleLabel.bottom(to: layoutMarginsGuide)
        subtitleLabel.trailing(to: amountLabel)

        amountLabel.top(to: layoutMarginsGuide)
        amountLabel.bottom(to: layoutMarginsGuide)
        amountLabel.trailing(to: layoutMarginsGuide)

        amountLabel.setContentHuggingPriority(.defaultLow + 1, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
    }

}
