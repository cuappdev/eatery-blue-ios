//
//  EateryLargeCardView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import UIKit

class EateryLargeCardView: UIView {

    let imageView = UIImageView()
    let imageTintView = UIView()

    let labelStackView = UIStackView() 
    let titleLabel = UILabel()
    let subtitleLabels = [UILabel(), UILabel()]

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

        imageView.addSubview(imageTintView)
        setUpImageTintView()
    }

    private func setUpImageTintView() {
        imageTintView.backgroundColor = .white
        imageTintView.alpha = 0
    }

    private func setUpLabelStackView() {
        labelStackView.axis = .vertical
        labelStackView.spacing = 4
        labelStackView.distribution = .fill
        labelStackView.alignment = .fill
        
        labelStackView.addArrangedSubview(titleLabel)
        setUpTitleLabel()

        for subtitleLabel in subtitleLabels {
            labelStackView.addArrangedSubview(subtitleLabel)
            setUpSubtitleLabel(subtitleLabel)
        }
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .body, weight: .semibold)
        titleLabel.textColor = UIColor(named: "Black")
    }

    private func setUpSubtitleLabel(_ subtitleLabel: UILabel) {
        subtitleLabel.font = .preferredFont(for: .subheadline, weight: .medium)
        subtitleLabel.textColor = UIColor(named: "Gray05")
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

        imageTintView.edgesToSuperview()

        labelStackView.topToBottom(of: imageView, offset: 12)
        labelStackView.leadingToSuperview(offset: 12)
        labelStackView.bottomToSuperview(offset: -12)
        labelStackView.trailingToLeading(of: favoriteImageView, offset: -16)

        favoriteImageView.trailingToSuperview(offset: 12)
        favoriteImageView.height(to: titleLabel)
        favoriteImageView.topToBottom(of: imageView, offset: 12)
        favoriteImageView.height(20)
        favoriteImageView.width(20)
    }

}
