//
//  EaterySmallCardView.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 2/11/25.
//  Originally created by William Ma on 12/22/21.
//

import EateryModel
import UIKit

class EaterySmallCardView: UICollectionViewCell {

    // MARK: - Properties (View)

    private let imageView = UIImageView()
    private let favoriteButton = ContainerView(pillContent: UIImageView())
    private let titleLabel = UILabel()

    // MARK: - Properties (Data)

    static let reuse = "EaterySmallCardViewReuseId"

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(eatery: Eatery) {
        imageView.kf.setImage(with: eatery.imageUrl)
        imageView.hero.id = eatery.imageUrl?.absoluteString
        titleLabel.text = eatery.name
        setUpFavoriteButton(eatery: eatery)
    }

    private func setUpSelf() {
        contentView.backgroundColor = .white
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowColor = UIColor.Eatery.shadowLight.cgColor
        layer.shadowOpacity = 0.25

        addSubview(imageView)
        setUpImageView()

        addSubview(titleLabel)
        setUpTitleLabel()

        addSubview(favoriteButton)

        setUpConstraints()
    }

    private func setUpImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .headline, weight: .semibold)
        titleLabel.textColor = UIColor.Eatery.black
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .left
    }

    private func setUpFavoriteButton(eatery: Eatery) {
        let coreDataStack = AppDelegate.shared.coreDataStack
        let metadata = coreDataStack.metadata(eateryId: eatery.id)
        if metadata.isFavorite {
            self.favoriteButton.content.image = UIImage(named: "FavoriteSelected")
        } else {
            self.favoriteButton.content.image = UIImage(named: "FavoriteUnselected")
        }

        favoriteButton.shadowColor = UIColor.Eatery.black
        favoriteButton.shadowOffset = CGSize(width: 0, height: 4)
        favoriteButton.backgroundColor = .white
        favoriteButton.layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        favoriteButton.tap { [weak self] _ in
            guard let self else { return }
            
            let coreDataStack = AppDelegate.shared.coreDataStack
            let metadata = coreDataStack.metadata(eateryId: eatery.id)
            metadata.isFavorite.toggle()
            coreDataStack.save()
            
            if metadata.isFavorite {
                self.favoriteButton.content.image = UIImage(named: "FavoriteSelected")
            } else {
                self.favoriteButton.content.image = UIImage(named: "FavoriteUnselected")
            }

            NotificationCenter.default.post(
                name: NSNotification.Name("favoriteEatery"),
                object: nil,
                userInfo: ["favorited": metadata.isFavorite]
            )
        }
    }

    private func setUpConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.width.height.equalTo(96)
        }

        favoriteButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.trailing.bottom.equalTo(imageView).inset(6)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().inset(10)
            make.bottom.lessThanOrEqualToSuperview().offset(8)
        }
    }

}
