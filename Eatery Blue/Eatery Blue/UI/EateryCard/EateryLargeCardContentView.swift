//
//  EateryLargeCardContentView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import UIKit

class EateryLargeCardContentView: UIView {

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
        insetsLayoutMarginsFromSafeArea = false
        layoutMargins = .zero
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
        snp.makeConstraints { make in
            make.width.equalTo(snp.height).multipliedBy(343.0 / 216.0).priority(.required.advanced(by: -1))
        }

        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        imageView.setContentCompressionResistancePriority(
            titleLabel.contentCompressionResistancePriority(for: .vertical) - 1,
            for: .vertical
        )

        imageTintView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        labelStackView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.leading.bottom.equalToSuperview().inset(12)
        }

        favoriteImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.leading.equalTo(labelStackView.snp.trailing).offset(16)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
    }

}
