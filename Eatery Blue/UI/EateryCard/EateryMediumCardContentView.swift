//
//  EateryMediumCardContentView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import UIKit
import EateryModel
import Combine

class EateryMediumCardContentView: UIView {

    let imageView = UIImageView()
    let imageTintView = UIView()
    let alertsStackView = UIStackView()

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let favoriteButton = ButtonView(content: UIImageView())
    
    let alertView = EateryCardAlertView()
    
    private var cancellables: Set<AnyCancellable> = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(eatery: Eatery) {
        imageView.kf.setImage(
            with: eatery.imageUrl,
            options: [.backgroundDecode]
        )
        imageTintView.alpha = eatery.isOpen ? 0 : 0.5
        titleLabel.text = eatery.name
        
        self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }

        setupFavoriteButton(eatery: eatery)
        
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

        let now = Date()
        switch eatery.status {
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
        
        favoriteButton.buttonPress { _ in
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

    func addAlertView(_ view: UIView) {
        alertsStackView.addArrangedSubview(view)
    }

}
