//
//  EateryMediumCardContentView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import Combine
import EateryModel
import UIKit

class EateryMediumCardContentView: UIView {

    private let imageView = UIImageView()
    private let imageTintView = UIView()
    private let alertsStackView = UIStackView()

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let favoriteButton = ButtonView(content: UIImageView())

    private let alertView = EateryCardAlertView()

    private var cancellables = Set<AnyCancellable>()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(eatery: Eatery) {
        titleLabel.text = eatery.name
        setupFavoriteButton(eatery: eatery)
        configureImageView(imageUrl: eatery.imageUrl, isOpen: eatery.isOpen)
        configureSubtitleLabels(eatery: eatery)
        configureAlerts(status: eatery.status)
    }

    private func setUpSelf() {
        backgroundColor = UIColor.Eatery.offWhite

        addSubview(imageView)
        setUpImageView()

        addSubview(titleLabel)
        setUpTitleLabel()

        addSubview(subtitleLabel)
        setUpSubtitleLabel()
        
        addSubview(favoriteButton)
    }

    private func setUpImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        addSubview(imageTintView)
        setUpImageTintView()

        addSubview(alertsStackView)
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

    private func setupFavoriteButton(eatery: Eatery) {
        favoriteButton.content.contentMode = .scaleAspectFill

        let metadata = AppDelegate.shared.coreDataStack.metadata(eateryId: eatery.id)
        if metadata.isFavorite {
            favoriteButton.content.image = UIImage(named: "FavoriteSelected")
        } else {
            favoriteButton.content.image = UIImage(named: "FavoriteUnselected")
        }
        
        favoriteButton.buttonPress { [weak self] _ in
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
            make.trailing.equalTo(imageView.snp.trailing).inset(12)
            make.width.height.equalTo(20)
            make.top.equalTo(imageView.snp.bottom).offset(12)
        }
    }

    private func configureImageView(imageUrl: URL?, isOpen: Bool) {
        imageView.kf.setImage(
            with: imageUrl,
            options: [.backgroundDecode]
        )
        imageTintView.alpha = isOpen ? 0 : 0.5
    }
    
    private func configureFavoriteButton(id: Int64) {
        let metadata = AppDelegate.shared.coreDataStack.metadata(eateryId: id)
        if metadata.isFavorite {
            favoriteButton.content.image = UIImage(named: "FavoriteSelected")
        } else {
            favoriteButton.content.image = UIImage(named: "FavoriteUnselected")
        }
        
        favoriteButton.buttonPress { [weak self] _ in
            guard let self else { return }
            
            let coreDataStack = AppDelegate.shared.coreDataStack
            let metadata = coreDataStack.metadata(eateryId: id)
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
