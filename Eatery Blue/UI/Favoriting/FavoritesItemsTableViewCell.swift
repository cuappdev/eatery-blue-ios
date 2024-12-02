//
//  FavoritesItemsTableViewCell.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 11/5/24.
//

import EateryModel
import UIKit

class FavoritesItemsTableViewCell: UITableViewCell {

    // MARK: - Properties (View)

    private let availableLabel = UILabel()
    private let chevronImageView = UIImageView()
    private let container = UIView()
    private let favoriteButton = ButtonView(content: UIView())
    private let favoriteButtonImage = UIImageView()
    private let headerContainer = UIView()
    private let itemNameLabel = UILabel()
    private let stackView = UIStackView()

    // MARK: - Properties (Data)

    private let headerHeight = 92
    static let reuse = "FavoritesItemsTableViewCellReuse"

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setUpSelf()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure

    func configure(item: ItemMetadata, expanded: Bool, itemData: [String: Set<String>]?) {
        itemNameLabel.text = item.itemName
        availableLabel.text = itemData != nil ? "Available Today" : "Not Available"
        availableLabel.textColor = itemData != nil ? .Eatery.green : .Eatery.gray03
        chevronImageView.isHidden = itemData == nil
        setUpFavoriteButton(item)

        stackView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }

        if let itemData {
            let spacer = UIView()
            spacer.backgroundColor = .Eatery.gray01
            stackView.addArrangedSubview(spacer)
            spacer.snp.makeConstraints { make in
                make.height.equalTo(1)
                make.width.equalToSuperview()
            }

            // these categories should appear first if they are available
            let firstKeys = ["Breakfast", "Brunch", "Lunch", "Dinner"]

            for key in firstKeys {
                if let eateries = itemData[key] {
                    addCategory(key, eateries: eateries.sorted())
                }
            }

            for category in itemData.keys {
                if firstKeys.contains(category) { continue }

                addCategory(category, eateries: itemData[category]?.sorted() ?? [])
            }
        }

        if expanded {
            contentView.snp.remakeConstraints { make in
                make.width.equalToSuperview()
                make.height.equalTo(headerHeight + Int(stackView.frame.height))
            }

            chevronImageView.transform = CGAffineTransform(rotationAngle: .pi)
            stackView.isHidden = false
        } else {
            contentView.snp.remakeConstraints { make in
                make.width.equalToSuperview()
                make.height.equalTo(headerHeight)
            }

            chevronImageView.transform = .identity
            stackView.isHidden = true
        }
    }

    func addCategory(_ category: String, eateries: [String]) {
        if eateries.isEmpty { return }

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
            eateryLabel.textColor = .Eatery.gray05
            eateriesStackView.addArrangedSubview(eateryLabel)
        }

        stackView.addArrangedSubview(eateriesStackView)
        stackView.layoutIfNeeded()
    }

    // MARK: - Set Up
    private func setUpSelf() {
        setUpContainer()
        contentView.addSubview(container)

        headerContainer.clipsToBounds = true
        container.addSubview(headerContainer)

        itemNameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        headerContainer.addSubview(itemNameLabel)

        availableLabel.font = .systemFont(ofSize: 13, weight: .medium)
        headerContainer.addSubview(availableLabel)

        headerContainer.addSubview(favoriteButton)
        favoriteButton.addSubview(favoriteButtonImage)

        setUpChevronImageView()
        headerContainer.addSubview(chevronImageView)

        setUpStackView()
        container.addSubview(stackView)

        setUpConstraints()

        // Needs to be called after setting up constraints to prevent overflow
        stackView.layoutIfNeeded()
        stackView.isHidden = true
    }

    private func setUpContainer() {
        container.layer.cornerRadius = 9
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.Eatery.gray01.cgColor
        container.layer.shadowColor = UIColor.lightGray.cgColor
        container.layer.shadowRadius = 6
        container.layer.shadowOpacity = 0.4
        container.layer.shadowOffset = CGSize(width: 0, height: 0)
        container.layer.backgroundColor = UIColor.white.cgColor
        container.layoutMargins = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
    }

    private func setUpFavoriteButton(_ menuItem: ItemMetadata) {
        favoriteButton.content.contentMode = .scaleAspectFill

        if menuItem.isFavorite {
            favoriteButtonImage.image = UIImage(named: "FavoriteSelected")
        } else {
            favoriteButtonImage.image = UIImage(named: "FavoriteUnselected")
        }

        favoriteButton.buttonPress { [weak self] _ in
            guard let self else { return }
            let coreDataStack = AppDelegate.shared.coreDataStack
            menuItem.isFavorite.toggle()
            coreDataStack.save()

            if menuItem.isFavorite {
                favoriteButtonImage.image = UIImage(named: "FavoriteSelected")
            } else {
                favoriteButtonImage.image = UIImage(named: "FavoriteUnselected")
            }

            NotificationCenter.default.post(
                name: NSNotification.Name("favoriteEatery"),
                object: nil
            )
        }
    }

    private func setUpChevronImageView() {
        chevronImageView.image = UIImage(systemName: "chevron.down")
        chevronImageView.tintColor = .Eatery.black
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
            make.edges.equalTo(contentView).inset(12)
        }

        headerContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalTo(container.layoutMarginsGuide)
            make.height.equalTo(headerHeight - 24)
        }

        favoriteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.bottom.equalTo(headerContainer.snp.centerY).inset(2)
            make.size.equalTo(22)
        }

        favoriteButtonImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        chevronImageView.snp.makeConstraints { make in
            make.centerX.equalTo(favoriteButton)
            make.top.equalTo(favoriteButton.snp.bottom).offset(4)
            make.size.equalTo(19)
        }

        itemNameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(favoriteButton.snp.leading)
            make.bottom.equalTo(headerContainer.snp.centerY)
        }

        availableLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(itemNameLabel.snp.bottom).offset(4)
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(headerContainer.snp.bottom)
            make.leading.trailing.equalTo(container.layoutMarginsGuide)
        }
    }

}
