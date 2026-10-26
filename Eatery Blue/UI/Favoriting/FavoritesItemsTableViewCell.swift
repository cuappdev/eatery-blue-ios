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
    private let favoriteButton = ButtonView(content: UIView())
    private let favoriteButtonImage = UIImageView()
    private let headerContainer = UIView()
    private let itemNameLabel = UILabel()
    private let stackView = UIStackView()

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

        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if let itemData {
            let spacer = UIView()
            spacer.backgroundColor = .Eatery.gray01
            stackView.addArrangedSubview(spacer)
            spacer.snp.makeConstraints { make in
                make.height.equalTo(1)
                make.width.equalToSuperview()
            }

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

        if expanded {
            chevronImageView.transform = CGAffineTransform(rotationAngle: .pi)
            stackView.isHidden = false
            headerContainer.snp.remakeConstraints { make in
                make.top.leading.trailing.equalTo(container.layoutMarginsGuide)
            }
            stackView.snp.remakeConstraints { make in
                make.top.equalTo(headerContainer.snp.bottom).offset(12)
                make.leading.trailing.equalTo(container.layoutMarginsGuide)
                make.bottom.equalTo(container.layoutMarginsGuide)
            }
        } else {
            chevronImageView.transform = .identity
            stackView.isHidden = true
            headerContainer.snp.remakeConstraints { make in
                make.top.leading.trailing.bottom.equalTo(container.layoutMarginsGuide)
            }
            stackView.snp.remakeConstraints { make in
                make.top.equalTo(headerContainer.snp.bottom)
                make.leading.trailing.equalTo(container.layoutMarginsGuide)
                make.height.equalTo(0)
            }
        }

        setNeedsLayout()
        layoutIfNeeded()
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
        chevronImageView.transform = .identity
        chevronImageView.isHidden = false
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stackView.isHidden = true
    }

    // MARK: - Set Up

    private func setUpSelf() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        setUpContainer()
        contentView.addSubview(container)

        headerContainer.clipsToBounds = true
        container.addSubview(headerContainer)

        headerContainer.addSubview(favoriteButton)
        favoriteButton.addSubview(favoriteButtonImage)

        itemNameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        itemNameLabel.textColor = UIColor.Eatery.primaryText
        headerContainer.addSubview(itemNameLabel)

        availableLabel.font = .systemFont(ofSize: 12, weight: .medium)
        headerContainer.addSubview(availableLabel)

        setUpChevronImageView()
        headerContainer.addSubview(chevronImageView)

        setUpStackView()
        container.addSubview(stackView)

        setUpConstraints()

        stackView.layoutIfNeeded()
        stackView.isHidden = true
    }

    private func setUpContainer() {
        container.layer.cornerRadius = 8
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.Eatery.gray00.cgColor
        container.layer.shadowColor = UIColor.Eatery.gray03.cgColor
        container.layer.shadowRadius = 16
        container.layer.shadowOpacity = 0.25
        container.layer.shadowOffset = CGSize(width: 0, height: 4)
        container.layer.backgroundColor = UIColor.Eatery.default00.cgColor
        container.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
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
        stackView.addArrangedSubview(categoryLabel)

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

        stackView.addArrangedSubview(eateriesStackView)
    }

    private func setUpChevronImageView() {
        chevronImageView.image = UIImage(systemName: "chevron.down")
        chevronImageView.tintColor = UIColor.Eatery.secondaryText
        chevronImageView.contentMode = .scaleAspectFit
    }

    private func setUpStackView() {
        stackView.clipsToBounds = true
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
    }

    private func setUpConstraints() {
        container.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(UIEdgeInsets(top: 0, left: 16, bottom: 12, right: 16))
        }

        headerContainer.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(container.layoutMarginsGuide)
        }

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

        stackView.snp.makeConstraints { make in
            make.top.equalTo(headerContainer.snp.bottom)
            make.leading.trailing.equalTo(container.layoutMarginsGuide)
            make.height.equalTo(0)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        container.layer.shadowPath = UIBezierPath(roundedRect: container.bounds, cornerRadius: 8).cgPath
    }
}
