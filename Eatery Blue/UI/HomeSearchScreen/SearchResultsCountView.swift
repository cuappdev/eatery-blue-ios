//
//  SearchResultsCountView.swift
//  Eatery Blue
//
//  Created by William Ma on 1/1/22.
//

import UIKit

class SearchResultsCountView: UIView {
    let titleLabel = UILabel()
    let resetButton = ContainerView(pillContent: UILabel())

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
        insetsLayoutMarginsFromSafeArea = false

        addSubview(titleLabel)
        setUpTitleLabel()

        addSubview(resetButton)
        setUpResetButton()
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .body, weight: .semibold)
    }

    private func setUpResetButton() {
        resetButton.layoutMargins = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        resetButton.content.font = .preferredFont(for: .footnote, weight: .semibold)
        resetButton.content.text = "Reset"
        resetButton.content.textColor = UIColor.Eatery.primaryText
        resetButton.backgroundColor = UIColor.Eatery.gray00
    }

    private func setUpConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.centerY.equalTo(layoutMarginsGuide)
            make.top.greaterThanOrEqualTo(layoutMarginsGuide)
        }

        resetButton.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
            make.trailing.equalTo(layoutMarginsGuide)
            make.top.bottom.equalTo(layoutMarginsGuide)
        }
        resetButton.content.setContentHuggingPriority(
            titleLabel.contentHuggingPriority(for: .horizontal) + 1,
            for: .horizontal
        )
    }
}
