//
//  EateryMediumCardContentView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import Combine
import EateryModel
import UIKit

class EateryMediumCardView: UICollectionViewCell {

    // MARK: - Properties (view)

    private let imageView = UIImageView()
    private let imageTintView = UIView()
    private let alertsStackView = UIStackView()

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let favoriteButton = ButtonView(content: UIView())
    private let favoriteButtonImage = UIImageView()

    private let alertView = EateryCardAlertView()

    // MARK: - Properties (data)

    private var cancellables = Set<AnyCancellable>()

    static let reuse = "EateryMediumCardContentViewReuseId"

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(eatery: Eatery, favorited: Bool) {
        titleLabel.text = eatery.name
        configureFavoriteButton(eatery: eatery, favorited: favorited)
        configureImageView(imageUrl: eatery.imageUrl, isOpen: eatery.isOpen)
        configureSubtitleLabels(eatery: eatery)
        configureAlerts(status: eatery.status)
    }

    private func setUpSelf() {
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8
        contentView.backgroundColor = .white
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowColor = UIColor.Eatery.shadowLight.cgColor
        layer.shadowOpacity = 0.25

        contentView.addSubview(imageView)
        setUpImageView()

        contentView.addSubview(titleLabel)
        setUpTitleLabel()

        contentView.addSubview(subtitleLabel)
        setUpSubtitleLabel()
        
        contentView.addSubview(favoriteButton)
        setUpFavoriteButton()

        setUpConstraints()

    }

    private func setUpImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        contentView.addSubview(imageTintView)
        setUpImageTintView()

        contentView.addSubview(alertsStackView)
        setUpAlertsStackView()
        
        alertsStackView.addArrangedSubview(alertView)
        alertView.isHidden = true
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
        titleLabel.textColor = UIColor.Eatery.black
    }

    private func setUpSubtitleLabel() {
        subtitleLabel.font = .preferredFont(for: .subheadline, weight: .medium)
        subtitleLabel.textColor = UIColor.Eatery.gray05
    }

    private func setUpFavoriteButton() {
        favoriteButton.content.contentMode = .scaleAspectFill
        favoriteButton.addSubview(favoriteButtonImage)
    }

    private func configureFavoriteButton(eatery: Eatery, favorited: Bool) {
        favoriteButtonImage.image = UIImage(named: "Favorite\(favorited ? "Selected" : "Unselected")")

        favoriteButton.buttonPress { [weak self] _ in
            guard self != nil else { return }

            let coreDataStack = AppDelegate.shared.coreDataStack
            let metadata = coreDataStack.metadata(eateryId: eatery.id)
            metadata.isFavorite.toggle()
            coreDataStack.save()
            
            NotificationCenter.default.post(
                name: UIViewController.notificationName,
                object: nil,
                userInfo: [ UIViewController.notificationUserInfoKey : metadata.isFavorite ]
            )
        }
    }

    private func setUpConstraints() {
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
            make.trailing.equalTo(favoriteButton.snp.leading)
            make.top.equalTo(imageView.snp.bottom).offset(12)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().inset(12)
        }
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        favoriteButton.snp.makeConstraints { make in
            make.leading.equalTo(subtitleLabel.snp.trailing).offset(4)
            make.trailing.equalTo(imageView.snp.trailing)
            make.size.equalTo(44)
            make.top.equalTo(imageView.snp.bottom)
        }

        favoriteButtonImage.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.center.equalToSuperview()
        }
    }

    private func configureImageView(imageUrl: URL?, isOpen: Bool) {
        imageView.kf.setImage(
            with: imageUrl,
            options: [.backgroundDecode]
        )
        imageTintView.alpha = isOpen ? 0 : 0.5
    }
    
    private func configureSubtitleLabels(eatery: Eatery) {
        LocationManager.shared.$userLocation
            .sink { userLocation in
                self.subtitleLabel.attributedText = EateryFormatter.default.formatEatery(
                    eatery,
                    style: .medium,
                    font: .preferredFont(for: .footnote, weight: .medium),
                    userLocation: userLocation,
                    date: Date()
                ).first
            }
            .store(in: &cancellables)
    }
    
    private func configureAlerts(status: EateryStatus) {
        let now = Date()
        switch status {
        case .closingSoon(let event):
            let minutesUntilClosed = Int(round(event.endDate.timeIntervalSince(now) / 60))
            alertView.titleLabel.text = "Closing in \(minutesUntilClosed) min"
            alertView.isHidden = false

        case .openingSoon(let event):
            let minutesUntilOpen = Int(round(event.startDate.timeIntervalSince(now) / 60))
            alertView.titleLabel.text = "Opening in \(minutesUntilOpen) min"
            alertView.isHidden = false
            
        default:
            alertView.isHidden = true
            break
        }
    }
    
    func addAlertView(_ view: UIView) {
        alertsStackView.addArrangedSubview(view)
    }

}
