//
//  FavoritesSearchEateryCell.swift
//  Eatery Blue
//
//  Created by Arielle Nudelman on 10/14/26.
//

import EateryModel
import Kingfisher
import UIKit

final class FavoritesSearchEateryCell: UICollectionViewCell {
    // MARK: - Properties (view)

    private let card = UIView()
    private let favoriteButton = ButtonView(content: UIImageView())
    private let imageView = UIImageView()
    private let locationLabel = UILabel()
    private let metaLabel = UILabel()
    private let titleLabel = UILabel()

    // MARK: - Properties (data)

    private var eatery: Eatery?

    static let reuse = "FavoritesSearchEateryCell"

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

    func configure(eatery: Eatery, favorited: Bool) {
        self.eatery = eatery
        titleLabel.text = eatery.name
        locationLabel.text = eatery.location.validated() ?? eatery.location
        favoriteButton.content.image = UIImage(named: favorited ? "FavoriteSelected" : "FavoriteUnselected")

        if let url = URL(string: eatery.imageUrl) {
            imageView.kf.setImage(with: url)
        }

        let walk = eatery.walkTime(userLocation: LocationManager.shared.userLocation)
        let walkText: String
        if let walk {
            walkText = "\(max(1, Int(walk / 60))) min"
        } else {
            walkText = "-- min"
        }

        let statusText: String
        let statusColor: UIColor
        switch eatery.status {
        case let .open(event), let .closingSoon(event):
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            statusText = "Open until \(formatter.string(from: event.endTimestamp))"
            statusColor = .Eatery.green
        default:
            statusText = "Closed"
            statusColor = .Eatery.secondaryText
        }

        let attributed = NSMutableAttributedString(
            string: "\(walkText) · ",
            attributes: [
                .foregroundColor: UIColor.Eatery.secondaryText,
                .font: UIFont.systemFont(ofSize: 13, weight: .medium)
            ]
        )
        attributed.append(NSAttributedString(
            string: statusText,
            attributes: [
                .foregroundColor: statusColor,
                .font: UIFont.systemFont(ofSize: 13, weight: .medium)
            ]
        ))
        metaLabel.attributedText = attributed

        favoriteButton.buttonPress { [weak self] _ in
            guard let self else { return }
            let coreDataStack = AppDelegate.shared.coreDataStack
            let metadata = coreDataStack.metadata(eateryId: eatery.cornellId)
            metadata.isFavorite.toggle()
            coreDataStack.save()
            favoriteButton.content.image = UIImage(
                named: metadata.isFavorite ? "FavoriteSelected" : "FavoriteUnselected"
            )
            NotificationCenter.default.post(
                name: UIViewController.notificationName,
                object: nil,
                userInfo: [UIViewController.notificationUserInfoKey: metadata.isFavorite]
            )
        }
    }

    // MARK: - Set Up

    private func setUp() {
        clipsToBounds = false
        contentView.clipsToBounds = false

        contentView.addSubview(card)
        card.backgroundColor = UIColor.Eatery.default00
        card.layer.cornerRadius = 8
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.Eatery.gray00.cgColor
        card.layer.shadowColor = UIColor.Eatery.gray03.cgColor
        card.layer.shadowOpacity = 0.25
        card.layer.shadowRadius = 16
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.clipsToBounds = false

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        card.addSubview(imageView)

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor.Eatery.primaryText
        titleLabel.numberOfLines = 1
        card.addSubview(titleLabel)

        favoriteButton.content.contentMode = .scaleAspectFit
        card.addSubview(favoriteButton)

        locationLabel.font = .systemFont(ofSize: 13, weight: .medium)
        locationLabel.textColor = UIColor.Eatery.secondaryText
        card.addSubview(locationLabel)

        metaLabel.font = .systemFont(ofSize: 13, weight: .medium)
        metaLabel.numberOfLines = 1
        card.addSubview(metaLabel)

        card.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }

        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(127)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.leading.equalToSuperview().inset(12)
            make.trailing.equalTo(favoriteButton.snp.leading).offset(-8)
        }

        favoriteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(24)
        }

        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        metaLabel.snp.makeConstraints { make in
            make.top.equalTo(locationLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.lessThanOrEqualToSuperview().inset(12)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        card.layer.shadowPath = UIBezierPath(roundedRect: card.bounds, cornerRadius: 8).cgPath
    }
}
