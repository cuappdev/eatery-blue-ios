//
//  EaterySmallCardView.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 2/11/25.
//  Originally created by William Ma on 12/22/21.
//

import Combine
import EateryModel
import UIKit

class EaterySmallCardView: UICollectionViewCell {

    // MARK: - Properties (View)

    private let imageView = UIImageView()
    private let favoriteButton = ContainerView(pillContent: UIImageView())
    private let titleLabel = UILabel()
    private let stackView = UIStackView()

    // MARK: - Properties (Data)

    private var cancellables = Set<AnyCancellable>()
    private var eatery: Eatery?
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
        self.eatery = eatery
        titleLabel.text = eatery.name
        configureImageView()
        setUpFavoriteButton()
        configureSubtitleLabels()
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

        addSubview(stackView)
        setUpStackView()

        setUpFavNotification()
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

    private func setUpFavoriteButton() {
        guard let eatery else { return }

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

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.spacing = 4
    }

    private func configureImageView() {
        guard let eatery else { return }

        imageView.kf.setImage(with: eatery.imageUrl)
        imageView.hero.id = eatery.imageUrl?.absoluteString
        imageView.alpha = eatery.isOpen ?  1 : 0.5
    }

    private func configureSubtitleLabels() {
        guard let eatery else { return }

        stackView.subviews.forEach { view in
            view.removeFromSuperview()
        }

        let openStatusLabel = UILabel()
        setUpSubtitleLabel(openStatusLabel)

        let walkingTimeLabel = UILabel()
        setUpSubtitleLabel(walkingTimeLabel)

        LocationManager.shared.$userLocation
            .sink { userLocation in
                let subtitle = EateryFormatter.default.formatEatery(
                    eatery,
                    style: .medium,
                    font: .preferredFont(for: .footnote, weight: .medium),
                    userLocation: userLocation,
                    date: Date()
                ).first?.split(seperateBy: " · ")

                openStatusLabel.attributedText = subtitle?.last
                walkingTimeLabel.attributedText = subtitle?.first
            }
            .store(in: &cancellables)
    }

    private func setUpSubtitleLabel(_ subtitleLabel: UILabel) {
        subtitleLabel.font = .preferredFont(for: .subheadline, weight: .medium)
        subtitleLabel.textColor = UIColor.Eatery.gray05
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping

        stackView.addArrangedSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
    }

    private func setUpFavNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshFavorite(_:)),
            name: NSNotification.Name("favoriteEatery"),
            object: nil
        )
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
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().inset(8)
            make.height.equalTo(20)
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(8)
        }
    }

    @objc private func refreshFavorite(_ notification: Notification) {
        setUpFavoriteButton()
    }

}
