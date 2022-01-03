//
//  EaterySmallCardView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import UIKit

class EaterySmallCardView: UIView {

    let imageView = UIImageView()
    let favoriteImageView = UIImageView()
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(imageView)
        setUpImageView()

        addSubview(titleLabel)
        setUpTitleLabel()

        addSubview(favoriteImageView)
        setUpFavoriteImageView()
    }

    private func setUpImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .subheadline, weight: .semibold)
        titleLabel.textColor = UIColor(named: "Black")
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
    }

    private func setUpFavoriteImageView() {
        favoriteImageView.contentMode = .scaleAspectFill
        favoriteImageView.image = UIImage(named: "FavoriteSelected")
    }

    private func setUpConstraints() {
        imageView.edgesToSuperview(excluding: .bottom)
        imageView.width(96)
        imageView.height(96)

        favoriteImageView.width(24)
        favoriteImageView.height(24)
        favoriteImageView.trailing(to: imageView)
        favoriteImageView.bottom(to: imageView)

        titleLabel.topToBottom(of: imageView, offset: 8)
        titleLabel.leadingToSuperview()
        titleLabel.trailingToSuperview()
        titleLabel.bottomToSuperview(relation: .equalOrLess)
    }

}
