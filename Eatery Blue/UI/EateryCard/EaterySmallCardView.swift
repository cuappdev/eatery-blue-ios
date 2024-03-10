//
//  EaterySmallCardView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import EateryModel
import UIKit

class EaterySmallCardView: UIView {

    private let imageView = UIImageView()
    private let favoriteButton = ContainerView(pillContent: UIImageView())
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(eatery: Eatery) {
        imageView.kf.setImage(with: eatery.imageUrl)
        titleLabel.text = eatery.name
        setUpFavoriteButton(eatery: eatery)
    }

    private func setUpSelf() {
        addSubview(imageView)
        setUpImageView()

        addSubview(titleLabel)
        setUpTitleLabel()

        addSubview(favoriteButton)
    }

    private func setUpImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .subheadline, weight: .semibold)
        titleLabel.textColor = UIColor.Eatery.black
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
    }

    private func setUpFavoriteButton(eatery: Eatery) {
        favoriteButton.content.contentMode = .scaleAspectFill
        favoriteButton.content.image = UIImage(named: "FavoriteSelected")
        
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
                object: nil
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
            make.trailing.bottom.equalTo(imageView)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }

}
