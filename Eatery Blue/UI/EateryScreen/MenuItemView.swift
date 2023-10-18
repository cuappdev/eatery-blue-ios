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
        titleLabel.font = .preferredFont(for: .subheadline, weight: .medium)
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
