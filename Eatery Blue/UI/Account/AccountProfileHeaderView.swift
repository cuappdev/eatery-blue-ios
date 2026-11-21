//
//  AccountProfileHeaderView.swift
//  Eatery Blue
//
//  Created by Amy Yang on 11/18/26.
//

import UIKit

class AccountProfileHeaderView: UIView {
    private let cardView = UIView()

    private let avatarContainer = ContainerView(pillContent: UIImageView())
    let nameLabel = UILabel()
    let emailLabel = UILabel()
    let showBarcodeButton = ButtonView(content: UIView())
    private let barcodeContainer = UIView()
    private let barcodeIconView = UIImageView()
    private let barcodeTitleLabel = UILabel()

    private static let avatarDiameter = 70

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 14, right: 0)
        addSubview(cardView)
        cardView.backgroundColor = UIColor.Eatery.blue
        cardView.layer.cornerRadius = 8
        cardView.layoutMargins = UIEdgeInsets(top: 16, left: 15, bottom: 16, right: 15)
        setUpAvatar()
        setUpNameLabel()
        setUpEmailLabel()
        setUpBarcodeButton()
    }

    private func setUpAvatar() {
        avatarContainer.backgroundColor = UIColor.Eatery.default00.withAlphaComponent(0.25)
        avatarContainer.layoutMargins = UIEdgeInsets(top: 16, left: 15, bottom: 19, right: 12)
        avatarContainer.content.image = UIImage(systemName: "person.fill")
        avatarContainer.content.tintColor = UIColor.Eatery.default00
        avatarContainer.content.contentMode = .scaleAspectFit

        cardView.addSubview(avatarContainer)
    }

    private func setUpNameLabel() {
        nameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        nameLabel.textColor = UIColor.Eatery.default00
        nameLabel.text = "Cornell Student" // placeholder
        cardView.addSubview(nameLabel)
    }

    private func setUpEmailLabel() {
        emailLabel.font = .systemFont(ofSize: 14, weight: .medium)
        emailLabel.textColor = UIColor.Eatery.default00
        emailLabel.text = "netid@cornell.edu" // placholder
        cardView.addSubview(emailLabel)
    }

    private func setUpBarcodeButton() {
        showBarcodeButton.cornerRadius = 8
        showBarcodeButton.cornerRadiusView.backgroundColor = UIColor.Eatery.default00
        showBarcodeButton.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)

        let content = showBarcodeButton.content
        content.addSubview(barcodeContainer)
        barcodeContainer.addSubview(barcodeIconView)
        barcodeContainer.addSubview(barcodeTitleLabel)

        barcodeIconView.image = UIImage(systemName: "barcode.viewfinder")
        barcodeIconView.tintColor = UIColor.Eatery.primaryText
        barcodeIconView.contentMode = .scaleAspectFit

        barcodeTitleLabel.font = .preferredFont(for: .body, weight: .semibold)
        barcodeTitleLabel.textColor = UIColor.Eatery.primaryText
        barcodeTitleLabel.text = "Barcode"

        barcodeContainer.snp.makeConstraints { make in
            make.centerX.top.bottom.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }

        barcodeIconView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview()
            make.width.height.equalTo(15)
        }

        barcodeTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(barcodeIconView.snp.trailing).offset(8)
            make.top.trailing.bottom.equalToSuperview()
        }

        cardView.addSubview(showBarcodeButton)
    }

    private func setUpConstraints() {
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(24)
        }

        avatarContainer.snp.makeConstraints { make in
            make.top.leading.equalTo(cardView.layoutMarginsGuide)
            make.width.height.equalTo(Self.avatarDiameter)
        }

        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(avatarContainer).offset(-9)
            make.leading.equalTo(avatarContainer.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(cardView.layoutMarginsGuide)
        }

        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.leading.equalTo(nameLabel)
            make.trailing.lessThanOrEqualTo(cardView.layoutMarginsGuide)
        }

        showBarcodeButton.snp.makeConstraints { make in
            make.top.equalTo(avatarContainer.snp.bottom).offset(19)
            make.leading.trailing.bottom.equalTo(cardView.layoutMarginsGuide)
        }
    }

    func updateProfile(name: String?, email: String?, image: UIImage?) {
        nameLabel.text = name ?? "Cornell Student"
        emailLabel.text = email ?? "netid@cornell.edu"

        if let image {
            avatarContainer.backgroundColor = .clear
            avatarContainer.content.contentMode = .scaleAspectFill
            avatarContainer.content.image = image
        } else {
            avatarContainer.backgroundColor = UIColor.Eatery.default00.withAlphaComponent(0.25)
            avatarContainer.content.contentMode = .scaleAspectFit
            avatarContainer.content.image = UIImage(systemName: "person.fill")
        }
    }
}
