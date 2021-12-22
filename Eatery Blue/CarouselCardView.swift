//
//  CarouselCardView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import UIKit

class CarouselCardView: UIView {

    let imageView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let favoriteImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        backgroundColor = UIColor(named: "OffWhite")

        addSubview(imageView)
        setUpImageView()

        addSubview(titleLabel)
        setUpTitleLabel()

        addSubview(subtitleLabel)
        setUpSubtitleLabel()

        addSubview(favoriteImageView)
        setUpFavoriteImageView()
    }

    private func setUpImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .body, weight: .semibold)
        titleLabel.textColor = UIColor(named: "Black")
    }

    private func setUpSubtitleLabel() {
        subtitleLabel.font = .preferredFont(for: .subheadline, weight: .medium)
        subtitleLabel.textColor = UIColor(named: "Gray05")
    }

    private func setUpFavoriteImageView() {
        favoriteImageView.contentMode = .scaleAspectFill
        favoriteImageView.image = UIImage(named: "FavoriteUnselected")
    }

    private func setUpConstraints() {
        imageView.edgesToSuperview(excluding: .bottom)

        titleLabel.leadingToSuperview(offset: 12)
        titleLabel.topToBottom(of: imageView, offset: 12)
        titleLabel.trailingToLeading(of: favoriteImageView, offset: 4)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        subtitleLabel.leadingToSuperview(offset: 12)
        subtitleLabel.topToBottom(of: titleLabel, offset: 4)
        subtitleLabel.bottomToSuperview(offset: -12)
        subtitleLabel.trailingToLeading(of: favoriteImageView, offset: 4)
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        favoriteImageView.trailingToSuperview(offset: 12)
        favoriteImageView.height(to: titleLabel)
        favoriteImageView.topToBottom(of: imageView, offset: 12)
        favoriteImageView.height(20)
        favoriteImageView.width(20)
    }

}
