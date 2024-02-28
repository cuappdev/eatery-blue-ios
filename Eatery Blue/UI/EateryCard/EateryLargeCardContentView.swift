//
//  EateryLargeCardContentView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import UIKit
import EateryModel

class EateryLargeCardContentView: UIView {

    // MARK: - Properties (view)
    
    let imageView = UIImageView()
    let imageTintView = UIView()
    let alertsStackView = UIStackView()

    let labelStackView = UIStackView() 
    let titleLabel = UILabel()
    let subtitleLabels = [UILabel(), UILabel()]

    private var favoriteButton = ButtonView(content: UIImageView())
    
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
        setUpFavoriteButton(eatery: eatery)
        configureImageView(imageUrl: eatery.imageUrl, isOpen: eatery.isOpen)
        configureSubtitleLabels(eatery: eatery)
        configureAlerts(status: eatery.status)
    }

    private func setUpSelf() {
        insetsLayoutMarginsFromSafeArea = false
        layoutMargins = .zero
        backgroundColor = UIColor.Eatery.offWhite

        addSubview(imageView)
        setUpImageView()

        addSubview(labelStackView)
        setUpLabelStackView()

        addSubview(favoriteButton)
    }

    private func setUpImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        imageView.addSubview(imageTintView)
        setUpImageTintView()

        imageView.addSubview(alertsStackView)
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
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.font = .preferredFont(for: .body, weight: .semibold)
        titleLabel.textColor = UIColor.Eatery.black
    }

    private func setUpSubtitleLabel(_ subtitleLabel: UILabel) {
        subtitleLabel.font = .preferredFont(for: .subheadline, weight: .medium)
        subtitleLabel.textColor = UIColor.Eatery.gray05
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping
    }

    private func setUpFavoriteButton(eatery: Eatery) {
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
    
    private func configureImageView(imageUrl: URL?, isOpen: Bool) {
        imageView.image = UIImage()
        imageView.kf.setImage(with: imageUrl)
        imageTintView.alpha = isOpen ? 0 : 0.5
        imageView.hero.id = imageUrl?.absoluteString
    }
    
    private func configureSubtitleLabels(eatery: Eatery) {
        subtitleLabels[0].text = eatery.locationDescription
        subtitleLabels[1].attributedText = EateryFormatter.default.eateryCardFormatter(eatery, date: Date())
    }
    
    private func configureAlerts(status: EateryStatus) {
        let now = Date()
        switch status {
        case .closingSoon(let event):
            let alert = EateryCardAlertView()
            let minutesUntilClosed = Int(round(event.endDate.timeIntervalSince(now) / 60))
            alert.titleLabel.text = "Closing in \(minutesUntilClosed) min"
            addAlertView(alert)

        case .openingSoon(let event):
            let alert = EateryCardAlertView()
            let minutesUntilOpen = Int(round(event.startDate.timeIntervalSince(now) / 60))
            alert.titleLabel.text = "Opening in \(minutesUntilOpen) min"
            addAlertView(alert)

        default:
            break
        }
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

        alertsStackView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(12)
        }

        labelStackView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.leading.bottom.equalToSuperview().inset(12)
        }

        favoriteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.leading.equalTo(labelStackView.snp.trailing).offset(16)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
    }

    func addAlertView(_ view: UIView) {
        alertsStackView.addArrangedSubview(view)
    }

}
