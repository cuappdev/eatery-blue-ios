//
//  MenuItemView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import EateryModel
import UIKit

class MenuItemView: UIView {
    // MARK: - Properties (view)

    private let allergensLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let dietaryInfoStack = UIStackView()
    private let favoriteButton = ButtonView(content: UIView())
    private let favoriteButtonImage = UIImageView()
    private let priceLabel = UILabel()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()

    // MARK: - Properties (data)

    /// item to display
    var item: MenuItem? {
        didSet {
            setUpTitleLabel()
            setUpPriceLabel()
            setUpDescriptionLabel()
            setUpFavoriteButton()
            setUpAllergensLabel(item?.allergens ?? [])
            setUpDietaryInfoStack(item?.dietaryPreferences ?? [])
        }
    }

    // MARK: - Init

    init() {
        super.init(frame: .zero)

        setUpSelf()
        setUpConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        insetsLayoutMarginsFromSafeArea = false

        addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        for view in stackView.subviews {
            view.removeFromSuperview()
        }

        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 8

        let titlePriceContainer = UIView()
        stackView.addArrangedSubview(titlePriceContainer)

        titlePriceContainer.addSubview(titleLabel)
        setUpTitleLabel()

        titlePriceContainer.addSubview(dietaryInfoStack)
        setUpDietaryInfoStack([])

        titlePriceContainer.addSubview(priceLabel)
        setUpPriceLabel()

        titlePriceContainer.addSubview(favoriteButton)
        favoriteButton.addSubview(favoriteButtonImage)
        setUpFavoriteButton()

        stackView.addArrangedSubview(descriptionLabel)
        setUpDescriptionLabel()

        stackView.addArrangedSubview(allergensLabel)
        setUpAllergensLabel([])
    }

    private func setUpTitleLabel() {
        titleLabel.text = item?.name ?? ""
        titleLabel.font = .preferredFont(for: .subheadline, weight: .medium)
        titleLabel.textColor = UIColor.Eatery.primaryText
    }

    private func setUpPriceLabel() {
        if let price = item?.price {
            priceLabel.text = EateryViewController
                .priceNumberFormatter
                .string(from: NSNumber(value: Double(price) / 100))
        } else {
            priceLabel.text = ""
        }

        priceLabel.font = .preferredFont(for: .subheadline, weight: .regular)
        priceLabel.textColor = UIColor.Eatery.secondaryText
    }

    private func setUpDescriptionLabel() {
        if let description = item?.description {
            descriptionLabel.isHidden = false
            descriptionLabel.text = description
        } else {
            descriptionLabel.isHidden = true
        }

        descriptionLabel.font = .preferredFont(for: .footnote, weight: .regular)
        descriptionLabel.textColor = UIColor.Eatery.secondaryText
        descriptionLabel.isHidden = true
        descriptionLabel.numberOfLines = 0
    }

    private func setUpFavoriteButton() {
        guard let item = item else { return }

        let itemdata = AppDelegate.shared.coreDataStack.metadata(itemName: item.name)
        let isFavorite = itemdata.isFavorite

        favoriteButtonImage.image = UIImage(named: isFavorite ? "FavoriteSelected" : "FavoriteUnselected")

        favoriteButton.buttonPress { [weak self] _ in
            guard let self else { return }

            let coreDataStack = AppDelegate.shared.coreDataStack
            let metadata = coreDataStack.metadata(itemName: item.name)
            metadata.isFavorite.toggle()
            coreDataStack.save()

            favoriteButtonImage.image = UIImage(named: metadata.isFavorite ? "FavoriteSelected" : "FavoriteUnselected")
        }
    }

    private func setUpAllergensLabel(_ allergens: [String]) {
        if allergens.isEmpty {
            allergensLabel.isHidden = true
            return
        } else {
            allergensLabel.isHidden = false
        }

        allergensLabel.text = "Contains: \(allergens.joined(separator: ", "))"
        allergensLabel.font = .systemFont(ofSize: 10)
        allergensLabel.textColor = UIColor.Eatery.red
    }

    private func setUpDietaryInfoStack(_ dietaryInfos: [String]) {
        dietaryInfoStack.axis = .horizontal
        dietaryInfoStack.spacing = 8

        if dietaryInfos.isEmpty {
            dietaryInfoStack.isHidden = true
            return
        } else {
            dietaryInfoStack.isHidden = false
        }

        for view in dietaryInfoStack.subviews {
            dietaryInfoStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        for dietaryInfo in dietaryInfos {
            let dietaryInfoView = UIImageView()
            // see if the dietaryInfo image exists
            if let image = UIImage(named: dietaryInfo) {
                dietaryInfoView.image = image
                dietaryInfoStack.addArrangedSubview(dietaryInfoView)
                dietaryInfoView.snp.makeConstraints { make in
                    make.size.equalTo(22)
                }
            }
        }
    }

    private func setUpConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
        }

        dietaryInfoStack.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(4)
            make.centerY.equalTo(titleLabel)
        }

        favoriteButton.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.size.equalTo(24)
        }

        favoriteButtonImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        priceLabel.snp.makeConstraints { make in
            make.leading.equalTo(dietaryInfoStack.snp.trailing).offset(8)
            make.trailing.equalTo(favoriteButton.snp.leading).offset(-4)
            make.centerY.equalToSuperview()
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

        allergensLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
    }
}
