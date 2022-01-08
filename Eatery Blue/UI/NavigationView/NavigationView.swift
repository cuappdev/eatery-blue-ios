//
//  NavigationView.swift
//  Eatery Blue
//
//  Created by William Ma on 1/8/22.
//

import UIKit

class NavigationView: UIView {

    let normalNavigationBar = UIView()
    let leftButtons = UIStackView()
    let titleLabel = UILabel()
    let rightButtons = UIStackView()

    let largeTitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(normalNavigationBar)
        setUpNormalNavigationBar()

        addSubview(largeTitleLabel)
        setUpLargeTitleLabel()
    }

    private func setUpNormalNavigationBar() {
        normalNavigationBar.addSubview(leftButtons)
        setUpLeftButtons()

        normalNavigationBar.addSubview(titleLabel)
        setUpTitleLabel()

        normalNavigationBar.addSubview(rightButtons)
        setUpRightButtons()
    }

    private func setUpLeftButtons() {
        leftButtons.axis = .horizontal
        leftButtons.alignment = .fill
        leftButtons.distribution = .fillEqually
        leftButtons.spacing = 8
    }

    private func setUpRightButtons() {
        rightButtons.axis = .horizontal
        rightButtons.alignment = .fill
        rightButtons.distribution = .fillEqually
        rightButtons.spacing = 8
    }

    private func setUpTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
    }

    private func setUpLargeTitleLabel() {
        largeTitleLabel.font = .systemFont(ofSize: 34, weight: .bold)
    }

    private func setUpConstraints() {
        normalNavigationBar.height(44)
        normalNavigationBar.edges(to: layoutMarginsGuide, excluding: .bottom)
        normalNavigationBar.bottomToSuperview(relation: .equalOrLess)

        leftButtons.topToSuperview()
        leftButtons.leadingToSuperview()
        leftButtons.bottomToSuperview()

        titleLabel.leadingToTrailing(of: leftButtons, offset: 8, relation: .equalOrGreater)
        titleLabel.topToSuperview()
        titleLabel.bottomToSuperview()
        titleLabel.centerXToSuperview()
        titleLabel.trailingToLeading(of: rightButtons, offset: 8, relation: .equalOrLess)
        titleLabel.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh - 1, for: .horizontal)

        rightButtons.topToSuperview()
        rightButtons.trailingToSuperview()
        rightButtons.bottomToSuperview()

        largeTitleLabel.setCompressionResistance(.required, for: .vertical)
        largeTitleLabel.edges(to: layoutMarginsGuide, excluding: .top)
    }

    func computeExpandedHeight() -> CGFloat {
        let temporaryConstraint = largeTitleLabel.topToBottom(
            of: normalNavigationBar,
            offset: 0
        )

        defer {
            temporaryConstraint.isActive = false
        }

        return systemLayoutSizeFitting(
            CGSize(width: bounds.width, height: 0),
            withHorizontalFittingPriority: .defaultLow,
            verticalFittingPriority: .defaultHigh
        ).height
    }

    func computeNormalHeight() -> CGFloat {
        return systemLayoutSizeFitting(
            CGSize(width: bounds.width, height: 0),
            withHorizontalFittingPriority: .defaultLow,
            verticalFittingPriority: .defaultHigh
        ).height
    }

    func setLeftButtons(_ buttons: [UIView]) {
        for view in leftButtons.arrangedSubviews {
            view.removeFromSuperview()
        }

        for button in buttons {
            leftButtons.addArrangedSubview(button)
        }
    }

    func setRightButtons(_ buttons: [UIView]) {
        for view in rightButtons.arrangedSubviews {
            view.removeFromSuperview()
        }

        for button in buttons {
            rightButtons.addArrangedSubview(button)
        }
    }

}
