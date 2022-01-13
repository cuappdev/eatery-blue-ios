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
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(layoutMarginsGuide)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.bottom.equalTo(layoutMarginsGuide)
        }

        amountLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
            make.leading.equalTo(subtitleLabel.snp.trailing).offset(8)
            make.top.trailing.bottom.equalTo(layoutMarginsGuide)
        }
        amountLabel.setContentHuggingPriority(.defaultLow + 1, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
    }

}
