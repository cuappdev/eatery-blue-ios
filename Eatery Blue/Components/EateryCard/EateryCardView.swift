//
//  EateryCardView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import UIKit

class EateryCardView: UIView {

    let imageView = UIImageView()

    let labelStackView = UIStackView() 
    let titleLabel = UILabel()
    let subtitleLabel1 = UILabel()
    let subtitleLabel2 = UILabel()

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

        addSubview(labelStackView)
        setUpLabelStackView()

        addSubview(favoriteImageView)
        setUpFavoriteImageView()
    }

    private func setUpImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }

    private func setUpLabelStackView() {
        labelStackView.axis = .vertical
        labelStackView.spacing = 4
        labelStackView.distribution = .fill
        labelStackView.alignment = .fill
        
        labelStackView.addArrangedSubview(titleLabel)
        setUpTitleLabel()

        labelStackView.addArrangedSubview(subtitleLabel1)
        setUpSubtitleLabel(subtitleLabel1)

        labelStackView.addArrangedSubview(subtitleLabel2)
        setUpSubtitleLabel(subtitleLabel2)
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .body, weight: .semibold)
        titleLabel.textColor = UIColor(named: "Black")
    }

    private func setUpSubtitleLabel(_ subtitleLabel: UILabel) {
        subtitleLabel.font = .preferredFont(for: .subheadline, weight: .medium)
        subtitleLabel.textColor = UIColor(named: "Gray05")
        subtitleLabel.numberOfLines = 1
    }

    private func setUpFavoriteImageView() {
        favoriteImageView.contentMode = .scaleAspectFill
        favoriteImageView.image = UIImage(named: "FavoriteUnselected")
    }

    private func setUpConstraints() {
        imageView.setContentCompressionResistancePriority(
            titleLabel.contentCompressionResistancePriority(for: .vertical) - 1,
            for: .vertical
        )
        imageView.edgesToSuperview(excluding: .bottom)

        labelStackView.topToBottom(of: imageView, offset: 12)
        labelStackView.leadingToSuperview(offset: 12)
        labelStackView.bottomToSuperview(offset: -12)
        labelStackView.trailingToLeading(of: favoriteImageView, offset: 16)

        favoriteImageView.trailingToSuperview(offset: 12)
        favoriteImageView.height(to: titleLabel)
        favoriteImageView.topToBottom(of: imageView, offset: 12)
        favoriteImageView.height(20)
        favoriteImageView.width(20)
    }

}
