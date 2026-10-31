//
//  FavoritesItemsTableViewCell.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 11/5/24.
//

import EateryModel
import UIKit

class FavoritesItemsTableViewCell: UITableViewCell {
    // MARK: - Properties (view)

    private let availableLabel = UILabel()
    private let chevronImageView = UIImageView()
    private let container = UIView()
    private let detailStackView = UIStackView()
    private let favoriteButton = ButtonView(content: UIView())
    private let favoriteButtonImage = UIImageView()
    private let headerContainer = UIView()
    private let itemNameLabel = UILabel()
    private let rootStackView = UIStackView()
    private let spacer = UIView()

    // MARK: - Properties (data)

    private var menuItem: ItemMetadata?
    var onUnfavorite: (() -> Void)?

    static let reuse = "FavoritesItemsTableViewCellReuse"

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setUpSelf()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure

    func configure(item: ItemMetadata, expanded: Bool, itemData: [EventType: Set<String>]?) {
        menuItem = item
        itemNameLabel.text = item.itemName
        let isAvailable = itemData != nil
        availableLabel.text = isAvailable ? "Available today" : "Not available today"
        availableLabel.textColor = isAvailable ? .Eatery.green : .Eatery.secondaryText
        chevronImageView.isHidden = !isAvailable
        setUpFavoriteButton(item)

        detailStackView.arrangedSubviews
            .filter { $0 !== spacer }
            .forEach { view in
                detailStackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }

        if let itemData {
            let firstKeys: [EventType] = EventType.mealTypes

            for category in firstKeys {
                if let eateries = itemData[category] {
                    addCategory(category.description, eateries: eateries.sorted())
                }
            }

            for category in itemData.keys {
                if firstKeys.contains(category) {
                    continue
                }

                if let eateries = itemData[category] {
                    addCategory(category.description, eateries: eateries.sorted())
                }
            }
        }

        toggleChevron(expanded: expanded && isAvailable)
        detailStackView.isHidden = !(expanded && isAvailable)
    }

    func performUnfavorite() {
        guard let menuItem else { return }
        unfavorite(menuItem)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        menuItem = nil
        onUnfavorite = nil
        favoriteButton.buttonPress(nil)
        favoriteButtonImage.image = nil
        itemNameLabel.text = nil
        availableLabel.text = nil
        chevronImageView.isHidden = false
        toggleChevron(expanded: false)
        detailStackView.arrangedSubviews
            .filter { $0 !== spacer }
            .forEach { view in
                detailStackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
        detailStackView.isHidden = true
    }

    // MARK: - Set Up

    private func setUpSelf() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        setUpContainer()
        contentView.addSubview(container)

        setUpRootStackView()
        container.addSubview(rootStackView)

        setUpHeaderContainer()
        rootStackView.addArrangedSubview(headerContainer)

        setUpDetailStackView()
        rootStackView.addArrangedSubview(detailStackView)
        detailStackView.isHidden = true

        setUpConstraints()
    }

    private func setUpContainer() {
        container.backgroundColor = UIColor.Eatery.card
        container.layer.cornerRadius = 8
        container.layer.shadowColor = UIColor.Eatery.shadowLight.cgColor
        container.layer.shadowRadius = 6
        container.layer.shadowOpacity = 0.25
        container.layer.shadowOffset = CGSize(width: 0, height: 0.5)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        container.layer.shadowColor = UIColor.Eatery.shadowLight.cgColor
    }

    private func setUpRootStackView() {
        rootStackView.axis = .vertical
        rootStackView.alignment = .fill
        rootStackView.distribution = .fill
        rootStackView.spacing = 12
    }

    private func setUpHeaderContainer() {
        headerContainer.addSubview(favoriteButton)
        favoriteButton.addSubview(favoriteButtonImage)

        itemNameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        itemNameLabel.textColor = UIColor.Eatery.primaryText
        headerContainer.addSubview(itemNameLabel)

        availableLabel.font = .systemFont(ofSize: 12, weight: .medium)
        headerContainer.addSubview(availableLabel)

        chevronImageView.image = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate)
        chevronImageView.tintColor = UIColor.Eatery.secondaryText
        chevronImageView.contentMode = .scaleAspectFit
        headerContainer.addSubview(chevronImageView)

        favoriteButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }

        favoriteButtonImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        chevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(favoriteButton)
            make.size.equalTo(24)
        }

        itemNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(favoriteButton.snp.trailing).offset(24)
            make.trailing.lessThanOrEqualTo(chevronImageView.snp.leading).offset(-8)
            make.top.equalToSuperview()
        }

        availableLabel.snp.makeConstraints { make in
            make.leading.equalTo(itemNameLabel)
            make.trailing.lessThanOrEqualTo(chevronImageView.snp.leading).offset(-8)
            make.top.equalTo(itemNameLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview()
        }
    }

    private func setUpDetailStackView() {
        detailStackView.axis = .vertical
        detailStackView.alignment = .fill
        detailStackView.distribution = .fill
        detailStackView.spacing = 10

        spacer.backgroundColor = .Eatery.gray01
        detailStackView.addArrangedSubview(spacer)
        spacer.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
    }

    private func setUpFavoriteButton(_ menuItem: ItemMetadata) {
        favoriteButton.content.contentMode = .scaleAspectFill
        favoriteButtonImage.image = UIImage(named: menuItem.isFavorite ? "FavoriteSelected" : "FavoriteUnselected")

        favoriteButton.buttonPress { [weak self] _ in
            guard let self else { return }
            unfavorite(menuItem)
        }
    }

    private func unfavorite(_ menuItem: ItemMetadata) {
        FavoritesStore.setItemFavorite(false, item: menuItem)

        favoriteButtonImage.image = UIImage(named: "FavoriteUnselected")

        NotificationCenter.default.post(
            name: UIViewController.notificationName,
            object: nil,
            userInfo: [UIViewController.notificationUserInfoKey: false]
        )

        onUnfavorite?()
    }

    private func addCategory(_ category: String, eateries: [String]) {
        guard !eateries.isEmpty else { return }

        let categoryLabel = UILabel()
        categoryLabel.text = category
        categoryLabel.font = .systemFont(ofSize: 16, weight: .medium)
        categoryLabel.textColor = UIColor.Eatery.primaryText
        detailStackView.addArrangedSubview(categoryLabel)

        let eateriesStackView = UIStackView()
        eateriesStackView.axis = .vertical
        eateriesStackView.distribution = .fill
        eateriesStackView.alignment = .fill
        eateriesStackView.spacing = 4

        for eatery in eateries {
            let eateryLabel = UILabel()
            eateryLabel.text = eatery
            eateryLabel.font = .systemFont(ofSize: 13, weight: .light)
            eateryLabel.textColor = .Eatery.secondaryText
            eateriesStackView.addArrangedSubview(eateryLabel)
        }

        detailStackView.addArrangedSubview(eateriesStackView)
    }

    private func toggleChevron(expanded: Bool) {
        let name = expanded ? "chevron.up" : "chevron.down"
        chevronImageView.image = UIImage(systemName: name)?.withRenderingMode(.alwaysTemplate)
    }

    private func setUpConstraints() {
        container.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(UIEdgeInsets(top: 0, left: 16, bottom: 12, right: 16))
        }

        rootStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard container.bounds.width > 0, container.bounds.height > 0 else {
            container.layer.shadowPath = nil
            return
        }
        container.layer.shadowPath = UIBezierPath(roundedRect: container.bounds, cornerRadius: 8).cgPath
    }
}
