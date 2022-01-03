//
//  MenuItemView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import UIKit

class MenuItemView: UIView {

    let stackView = UIStackView()
    let titleLabel = UILabel()
    let priceLabel = UILabel()
    let descriptionLabel = UILabel()

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
        
        addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 8

        let titlePriceContainer = UIView()
        stackView.addArrangedSubview(titlePriceContainer)

        titlePriceContainer.addSubview(titleLabel)
        setUpTitleLabel()

        titlePriceContainer.addSubview(priceLabel)
        setUpPriceLabel()

        stackView.addArrangedSubview(descriptionLabel)
        setUpDescriptionLabel()
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .subheadline, weight: .semibold)
        titleLabel.textColor = UIColor(named: "Black")
    }

    private func setUpPriceLabel() {
        priceLabel.font = .preferredFont(for: .subheadline, weight: .regular)
        priceLabel.textColor = UIColor(named: "Gray05")
    }

    private func setUpDescriptionLabel() {
        descriptionLabel.font = .preferredFont(for: .footnote, weight: .regular)
        descriptionLabel.textColor = UIColor(named: "Gray05")
        descriptionLabel.isHidden = true
        descriptionLabel.numberOfLines = 0
    }

    private func setUpConstraints() {
        titleLabel.topToSuperview()
        titleLabel.leadingToSuperview()
        titleLabel.bottomToSuperview()

        priceLabel.setContentHuggingPriority(
            titleLabel.contentHuggingPriority(for: .horizontal) + 1,
            for: .horizontal
        )
        priceLabel.setContentCompressionResistancePriority(
            titleLabel.contentCompressionResistancePriority(for: .horizontal) + 1,
            for: .horizontal
        )
        priceLabel.leadingToTrailing(of: titleLabel)
        priceLabel.topToSuperview()
        priceLabel.trailingToSuperview()
        priceLabel.bottomToSuperview()

        stackView.edges(to: layoutMarginsGuide)
    }

}
