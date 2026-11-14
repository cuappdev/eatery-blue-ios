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
    private let detailStackView = UIStackView()
    private let favoriteButton = ButtonView(content: UIView())
    private let favoriteButtonImage = UIImageView()
    private let headerContainer = UIView()
    private let locationLabel = UILabel()
    private let nameLabel = UILabel()
    private let rootStackView = UIStackView()
    private let spacer = UIView()
    private let statusLabel = UILabel()

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

        locationLabel.text = eatery.location.validated() ?? eatery.location

        if let statusText = statusDetail(for: eatery) {
            statusLabel.text = statusText
            statusLabel.textColor = eatery.isOpen ? .Eatery.green : .Eatery.secondaryText
            statusLabel.isHidden = false
        } else {
            statusLabel.text = nil
            statusLabel.isHidden = true
        }

        toggleChevron(expanded: expanded && availableToday)
        detailStackView.isHidden = !(expanded && availableToday)
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
        locationLabel.text = nil
        statusLabel.text = nil
        chevronImageView.isHidden = false
        toggleChevron(expanded: false)
        detailStackView.isHidden = true
    }

    // MARK: - Set Up

    private func setUpSelf() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        setUpContainer()
        contentView.addSubview(container)

        setUpRootStackView()
        container.addSubview(rootStackView)

        setUpHeaderContainer()
        rootStackView.addArrangedSubview(headerContainer)

        setUpDetailStackView()
        rootStackView.addArrangedSubview(detailStackView)
        detailStackView.isHidden = true

        setUpConstraints()
    }

    private func setUpContainer() {
        container.backgroundColor = UIColor.Eatery.card
        container.layer.cornerRadius = 8
        container.layer.shadowColor = UIColor.Eatery.shadowLight.cgColor
        container.layer.shadowRadius = 6
        container.layer.shadowOpacity = 0.25
        container.layer.shadowOffset = CGSize(width: 0, height: 0.5)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        container.layer.shadowColor = UIColor.Eatery.shadowLight.cgColor
    }

    private func setUpRootStackView() {
        rootStackView.axis = .vertical
        rootStackView.alignment = .fill
        rootStackView.distribution = .fill
        rootStackView.spacing = 12
    }

    private func setUpHeaderContainer() {
        headerContainer.addSubview(favoriteButton)
        favoriteButton.addSubview(favoriteButtonImage)

        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = UIColor.Eatery.primaryText
        headerContainer.addSubview(nameLabel)

        availableLabel.font = .systemFont(ofSize: 12, weight: .medium)
        headerContainer.addSubview(availableLabel)

        chevronImageView.image = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate)
        chevronImageView.tintColor = UIColor.Eatery.secondaryText
        chevronImageView.contentMode = .scaleAspectFit
        headerContainer.addSubview(chevronImageView)

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
    }

    private func setUpDetailStackView() {
        detailStackView.axis = .vertical
        detailStackView.alignment = .fill
        detailStackView.distribution = .fill
        detailStackView.spacing = 10

        spacer.backgroundColor = .Eatery.gray01
        detailStackView.addArrangedSubview(spacer)
        spacer.snp.makeConstraints { make in
            make.height.equalTo(1)
        }

        locationLabel.font = .systemFont(ofSize: 13, weight: .regular)
        locationLabel.textColor = .Eatery.secondaryText
        locationLabel.numberOfLines = 0
        detailStackView.addArrangedSubview(locationLabel)

        statusLabel.font = .systemFont(ofSize: 13, weight: .medium)
        statusLabel.numberOfLines = 0
        detailStackView.addArrangedSubview(statusLabel)
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

    private func toggleChevron(expanded: Bool) {
        let name = expanded ? "chevron.up" : "chevron.down"
        chevronImageView.image = UIImage(systemName: name)?.withRenderingMode(.alwaysTemplate)
    }

    private func setUpConstraints() {
        container.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(UIEdgeInsets(top: 0, left: 16, bottom: 12, right: 16))
        }

        rootStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard container.bounds.width > 0, container.bounds.height > 0 else {
            container.layer.shadowPath = nil
            return
        }
        container.layer.shadowPath = UIBezierPath(roundedRect: container.bounds, cornerRadius: 8).cgPath
    }
}
