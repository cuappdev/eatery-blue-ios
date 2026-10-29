//
//  FavoritesEateryTableViewCell.swift
//  Eatery Blue
//
//  Created by Arielle Nudelman on 10/14/26.
//

import EateryModel
import UIKit

class FavoritesEateryTableViewCell: UITableViewCell {
    // MARK: - Properties (view)

    private let availableLabel = UILabel()
    private let chevronImageView = UIImageView()
    private let container = UIView()
    private let favoriteButton = ButtonView(content: UIView())
    private let favoriteButtonImage = UIImageView()
    private let headerContainer = UIView()
    private let nameLabel = UILabel()
    private let stackView = UIStackView()

    // MARK: - Properties (data)

    private var eatery: Eatery?
    var onUnfavorite: (() -> Void)?

    static let reuse = "FavoritesEateryTableViewCellReuse"

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setUpSelf()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure

    func configure(eatery: Eatery, expanded: Bool) {
        self.eatery = eatery
        nameLabel.text = eatery.name

        let availableToday = eatery.events.contains { $0.canonicalDay == Day() }
        availableLabel.text = availableToday ? "Available today" : "Not available today"
        availableLabel.textColor = availableToday ? .Eatery.green : .Eatery.secondaryText
        chevronImageView.isHidden = !availableToday
        setUpFavoriteButton(eatery)

        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if availableToday {
            let spacer = UIView()
            spacer.backgroundColor = .Eatery.gray01
            stackView.addArrangedSubview(spacer)
            spacer.snp.makeConstraints { make in
                make.height.equalTo(1)
                make.width.equalToSuperview()
            }

            let locationLabel = UILabel()
            locationLabel.text = eatery.location.validated() ?? eatery.location
            locationLabel.font = .systemFont(ofSize: 13, weight: .regular)
            locationLabel.textColor = .Eatery.secondaryText
            locationLabel.numberOfLines = 0
            stackView.addArrangedSubview(locationLabel)

            if let statusText = statusDetail(for: eatery) {
                let statusLabel = UILabel()
                statusLabel.text = statusText
                statusLabel.font = .systemFont(ofSize: 13, weight: .medium)
                statusLabel.textColor = eatery.isOpen ? .Eatery.green : .Eatery.secondaryText
                stackView.addArrangedSubview(statusLabel)
            }
        }

        if expanded, availableToday {
            chevronImageView.transform = CGAffineTransform(rotationAngle: .pi)
            stackView.isHidden = false
            headerContainer.snp.remakeConstraints { make in
                make.top.leading.trailing.equalTo(container.layoutMarginsGuide)
            }
            stackView.snp.remakeConstraints { make in
                make.top.equalTo(headerContainer.snp.bottom).offset(12)
                make.leading.trailing.equalTo(container.layoutMarginsGuide)
                make.bottom.equalTo(container.layoutMarginsGuide)
            }
        } else {
            chevronImageView.transform = .identity
            stackView.isHidden = true
            headerContainer.snp.remakeConstraints { make in
                make.top.leading.trailing.bottom.equalTo(container.layoutMarginsGuide)
            }
            stackView.snp.remakeConstraints { make in
                make.top.equalTo(headerContainer.snp.bottom)
                make.leading.trailing.equalTo(container.layoutMarginsGuide)
                make.height.equalTo(0)
            }
        }

        setNeedsLayout()
        layoutIfNeeded()
    }

    func performUnfavorite() {
        guard let eatery else { return }
        unfavorite(eatery)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        eatery = nil
        onUnfavorite = nil
        favoriteButton.buttonPress(nil)
        favoriteButtonImage.image = nil
        nameLabel.text = nil
        availableLabel.text = nil
        chevronImageView.transform = .identity
        chevronImageView.isHidden = false
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stackView.isHidden = true
    }

    // MARK: - Set Up

    private func setUpSelf() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        setUpContainer()
        contentView.addSubview(container)

        headerContainer.clipsToBounds = true
        container.addSubview(headerContainer)

        headerContainer.addSubview(favoriteButton)
        favoriteButton.addSubview(favoriteButtonImage)

        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = UIColor.Eatery.primaryText
        headerContainer.addSubview(nameLabel)

        availableLabel.font = .systemFont(ofSize: 12, weight: .medium)
        headerContainer.addSubview(availableLabel)

        setUpChevronImageView()
        headerContainer.addSubview(chevronImageView)

        setUpStackView()
        container.addSubview(stackView)

        setUpConstraints()

        stackView.layoutIfNeeded()
        stackView.isHidden = true
    }

    private func setUpContainer() {
        container.backgroundColor = UIColor.Eatery.card
        container.layer.cornerRadius = 8
        container.layer.shadowColor = UIColor.Eatery.shadowLight.cgColor
        container.layer.shadowRadius = 6
        container.layer.shadowOpacity = 0.25
        container.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        container.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        container.layer.shadowColor = UIColor.Eatery.shadowLight.cgColor
    }

    private func setUpFavoriteButton(_ eatery: Eatery) {
        favoriteButton.content.contentMode = .scaleAspectFill
        favoriteButtonImage.image = UIImage(named: "FavoriteSelected")

        favoriteButton.buttonPress { [weak self] _ in
            guard let self else { return }
            unfavorite(eatery)
        }
    }

    private func unfavorite(_ eatery: Eatery) {
        FavoritesStore.setEateryFavorite(false, eateryId: eatery.cornellId)

        favoriteButtonImage.image = UIImage(named: "FavoriteUnselected")

        NotificationCenter.default.post(
            name: UIViewController.notificationName,
            object: nil,
            userInfo: [UIViewController.notificationUserInfoKey: false]
        )

        onUnfavorite?()
    }

    private func statusDetail(for eatery: Eatery) -> String? {
        switch eatery.status {
        case let .open(event):
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Open until \(formatter.string(from: event.endTimestamp))"
        case let .closingSoon(event):
            let minutes = Int(round(event.endTimestamp.timeIntervalSince(Date()) / 60))
            return "Closing in \(minutes) min"
        case let .openingSoon(event):
            let minutes = Int(round(event.startTimestamp.timeIntervalSince(Date()) / 60))
            return "Opening in \(minutes) min"
        case .closed:
            return "Closed"
        }
    }

    private func setUpChevronImageView() {
        chevronImageView.image = UIImage(systemName: "chevron.down")
        chevronImageView.tintColor = UIColor.Eatery.secondaryText
        chevronImageView.contentMode = .scaleAspectFit
    }

    private func setUpStackView() {
        stackView.clipsToBounds = true
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
    }

    private func setUpConstraints() {
        container.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(UIEdgeInsets(top: 0, left: 16, bottom: 12, right: 16))
        }

        headerContainer.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(container.layoutMarginsGuide)
        }

        favoriteButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }

        favoriteButtonImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        chevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(favoriteButton)
            make.size.equalTo(24)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(favoriteButton.snp.trailing).offset(24)
            make.trailing.lessThanOrEqualTo(chevronImageView.snp.leading).offset(-8)
            make.top.equalToSuperview()
        }

        availableLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.trailing.lessThanOrEqualTo(chevronImageView.snp.leading).offset(-8)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(headerContainer.snp.bottom)
            make.leading.trailing.equalTo(container.layoutMarginsGuide)
            make.height.equalTo(0)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        container.layer.shadowPath = UIBezierPath(roundedRect: container.bounds, cornerRadius: 8).cgPath
    }
}
