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

    required init?(coder: NSCoder) {
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
        resetButton.content.textColor = UIColor(named: "Black")
        resetButton.backgroundColor = UIColor(named: "Gray00")
    }

    private func setUpConstraints() {
        titleLabel.leading(to: layoutMarginsGuide)
        titleLabel.centerY(to: layoutMarginsGuide)
        titleLabel.top(to: layoutMarginsGuide, relation: .equalOrGreater)

        resetButton.content.setContentHuggingPriority(
            titleLabel.contentHuggingPriority(for: .horizontal) + 1,
            for: .horizontal
        )
        resetButton.leadingToTrailing(of: titleLabel, offset: 8)
        resetButton.trailing(to: layoutMarginsGuide)
        resetButton.topToSuperview()
        resetButton.bottomToSuperview()
    }

}
