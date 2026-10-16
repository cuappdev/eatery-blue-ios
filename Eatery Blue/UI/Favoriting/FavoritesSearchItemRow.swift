//
//  FavoritesSearchItemRow.swift
//  Eatery Blue
//
//  Created by Arielle Nudelman on 10/14/26.
//

import EateryModel
import UIKit

final class FavoritesSearchItemRow: UIView {
    // MARK: - Properties (view)

    private let card = UIView()
    private let favoriteButton = ButtonView(content: UIImageView())
    private let sourceLabel = UILabel()
    private let titleLabel = UILabel()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure

    func configure(item: MenuItem, eatery: Eatery) {
        titleLabel.text = item.name

        if let location = eatery.location.validated() {
            sourceLabel.text = "\(eatery.name) · \(location)"
        } else {
            sourceLabel.text = eatery.name
        }

        bindFavorite(isFavorite: AppDelegate.shared.coreDataStack.metadata(itemName: item.name).isFavorite) {
            let coreDataStack = AppDelegate.shared.coreDataStack
            let metadata = coreDataStack.metadata(itemName: item.name)
            metadata.isFavorite.toggle()
            coreDataStack.save()
            let isFavorite = metadata.isFavorite
            let itemName = item.name
            Task {
                await FavoriteItemSyncCoordinator.shared.setFavorite(isFavorite, itemName: itemName)
            }
            return isFavorite
        }
    }

    func configure(eatery: Eatery) {
        titleLabel.text = eatery.name
        sourceLabel.text = eatery.location.validated() ?? eatery.location

        bindFavorite(isFavorite: AppDelegate.shared.coreDataStack.metadata(eateryId: eatery.cornellId).isFavorite) {
            let coreDataStack = AppDelegate.shared.coreDataStack
            let metadata = coreDataStack.metadata(eateryId: eatery.cornellId)
            metadata.isFavorite.toggle()
            coreDataStack.save()
            return metadata.isFavorite
        }
    }

    // MARK: - Set Up

    private func setUp() {
        backgroundColor = .clear
        addSubview(card)

        card.backgroundColor = UIColor.Eatery.default00
        card.layer.cornerRadius = 8
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.Eatery.gray00.cgColor
        card.layer.shadowColor = UIColor.Eatery.gray03.cgColor
        card.layer.shadowOpacity = 0.25
        card.layer.shadowRadius = 16
        card.layer.shadowOffset = CGSize(width: 0, height: 4)

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor.Eatery.primaryText
        card.addSubview(titleLabel)

        sourceLabel.font = .systemFont(ofSize: 13, weight: .medium)
        sourceLabel.textColor = UIColor.Eatery.blue
        sourceLabel.numberOfLines = 2
        card.addSubview(sourceLabel)

        favoriteButton.content.contentMode = .scaleAspectFit
        card.addSubview(favoriteButton)

        card.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
            make.trailing.equalTo(favoriteButton.snp.leading).offset(-8)
        }

        sourceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalTo(favoriteButton.snp.leading).offset(-8)
            make.bottom.equalToSuperview().inset(16)
        }

        favoriteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }

        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(74)
        }
    }

    private func bindFavorite(isFavorite: Bool, toggle: @escaping () -> Bool) {
        favoriteButton.content.image = UIImage(
            named: isFavorite ? "FavoriteSelected" : "FavoriteUnselected"
        )

        favoriteButton.buttonPress { [weak self] _ in
            guard let self else { return }
            let favorited = toggle()
            favoriteButton.content.image = UIImage(
                named: favorited ? "FavoriteSelected" : "FavoriteUnselected"
            )
            NotificationCenter.default.post(
                name: UIViewController.notificationName,
                object: nil,
                userInfo: [UIViewController.notificationUserInfoKey: favorited]
            )
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        card.layer.shadowPath = UIBezierPath(roundedRect: card.bounds, cornerRadius: 8).cgPath
    }
}
