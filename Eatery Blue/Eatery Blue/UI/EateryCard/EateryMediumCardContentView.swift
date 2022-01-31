//
//  EateryMediumCardContentView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import UIKit

class EateryMediumCardContentView: UIView {

    let imageView = UIImageView()
    let imageTintView = UIView()
    let alertsStackView = UIStackView()

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    private let favoriteImageView = UIImageView()

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

        addSubview(imageTintView)
        setUpImageTintView()

        addSubview(alertsStackView)
        setUpAlertsStackView()
    }

    private func setUpImageTintView() {
        imageTintView.backgroundColor = .white
        imageTintView.alpha = 0
    }

    private func setUpAlertsStackView() {
        alertsStackView.spacing = 8
        alertsStackView.axis = .vertical
        alertsStackView.alignment = .trailing
        alertsStackView.distribution = .equalSpacing
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
        snp.makeConstraints { make in
            make.width.equalTo(snp.height).multipliedBy(295.0 / 186.0).priority(.required.advanced(by: -1))
        }

        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        imageTintView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        alertsStackView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(12)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.top.equalTo(imageView.snp.bottom).offset(12)
        }
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().inset(12)
        }
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        favoriteImageView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(4)
            make.leading.equalTo(subtitleLabel.snp.trailing).offset(4)
            make.trailing.equalToSuperview().inset(12)
            make.width.height.equalTo(titleLabel.snp.height)
            make.top.equalTo(imageView.snp.bottom).offset(12)
        }
    }

    func addAlertView(_ view: UIView) {
        alertsStackView.addArrangedSubview(view)
    }

    func setFavoriteImage(_ isFavorite: Bool) {
        if isFavorite {
            favoriteImageView.image = UIImage(named: "FavoriteSelected")
        } else {
            favoriteImageView.image = UIImage(named: "FavoriteUnselected")
        }
    }

}
