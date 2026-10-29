//
//  NotificationTableViewCell.swift
//  Eatery Blue
//
//  Created by Adelynn Wu on 11/5/25.
//

import EateryModel
import Foundation
import UIKit

class NotificationTableViewCell: UITableViewCell {
    // MARK: Properties (view)

    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let starImageView = UIImageView()

    // MARK: Properties (data)

    static let reuse = "NotificationItemTableViewCellReuse"

    // MARK: init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupSelf()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(notification: HubNotification) {
        titleLabel.text = notification.title
        bodyLabel.text = notification.body
    }

    // MARK: setup helpers

    private func setupSelf() {
        selectionStyle = .none
        backgroundColor = UIColor.Eatery.default00
        contentView.backgroundColor = UIColor.Eatery.default00
        setupTitleLabel()
        setupBodyLabel()
        setupStarImage()
        setupConstraints()
    }

    private func setupTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = UIColor.Eatery.primaryText
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
    }

    private func setupBodyLabel() {
        bodyLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        bodyLabel.textColor = UIColor.Eatery.gray05
        bodyLabel.numberOfLines = 0
        contentView.addSubview(bodyLabel)
    }

    private func setupStarImage() {
        starImageView.image = UIImage(named: "CheckedNotif")
        starImageView.contentMode = .scaleAspectFit
        contentView.addSubview(starImageView)
    }

    private func setupConstraints() {
        starImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(19)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(starImageView.snp.trailing).offset(24)
            make.trailing.equalToSuperview().inset(24)
            make.top.equalToSuperview().offset(12)
        }

        bodyLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(24)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
}
