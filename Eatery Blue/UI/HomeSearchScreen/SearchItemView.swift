//
//  SearchItemView.swift
//  Eatery Blue
//
//  Created by William Ma on 1/1/22.
//

import UIKit

class SearchItemView: UIView {
    let stackView = UIStackView()
    let titleLabel = UILabel()
    let priceLabel = UILabel()
    let descriptionLabel = UILabel()
    let sourceLabel = UILabel()

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

        backgroundColor = .white

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

        stackView.addArrangedSubview(sourceLabel)
        setUpSourceLabel()
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .subheadline, weight: .semibold)
        titleLabel.textColor = UIColor.Eatery.black
    }

    private func setUpPriceLabel() {
        priceLabel.font = .preferredFont(for: .subheadline, weight: .regular)
        priceLabel.textColor = UIColor.Eatery.gray05
    }

    private func setUpDescriptionLabel() {
        descriptionLabel.font = .preferredFont(for: .footnote, weight: .regular)
        descriptionLabel.textColor = UIColor.Eatery.gray05
        descriptionLabel.isHidden = true
        descriptionLabel.numberOfLines = 0
    }

    private func setUpSourceLabel() {
        sourceLabel.font = .preferredFont(for: .caption1, weight: .medium)
        sourceLabel.textColor = UIColor.Eatery.blue
    }

    private func setUpConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
        }

        priceLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing)
            make.top.trailing.bottom.equalToSuperview()
        }
        priceLabel.setContentHuggingPriority(
            titleLabel.contentHuggingPriority(for: .horizontal) + 1,
            for: .horizontal
        )
        priceLabel.setContentCompressionResistancePriority(
            titleLabel.contentCompressionResistancePriority(for: .horizontal) + 1,
            for: .horizontal
        )

        stackView.snp.makeConstraints { make in
            make.edges.equalTo(layoutMarginsGuide)
        }
    }
}
