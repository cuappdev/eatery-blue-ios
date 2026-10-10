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

//    private let itemNameLabel = UILabel()
//    private let locationLabel = UILabel()
//    private let timeLabel = UILabel()

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
//        itemNameLabel.text = notification.title
//        setupLocationLabelText(notification.body) // double check for locations
        titleLabel.text = notification.title
        bodyLabel.text = notification.body
    }

    // MARK: setup helpers

    private func setupSelf() {
//        setupItemNameLabel()
//        contentView.addSubview(locationLabel)

//        setupTimeLabel()
        selectionStyle = .none
        setupTitleLabel()
        setupBodyLabel()
        setupStarImage()
        setupConstraints()
    }

//    private func setupItemNameLabel() {
//        itemNameLabel.font = .systemFont(ofSize: 14, weight: .bold)
//        itemNameLabel.textColor = .Eatery.black
//
//        contentView.addSubview(itemNameLabel)
//    }

    /*
     private func setupLocationLabelText(_ locations: [String]) {
         var fullText = ""
         if locations.count == 0 {
             // Expected: locations should always have length > 0
             fullText = ""
         } else if locations.count == 1 {
             fullText = "At \(locations[0])."
         } else if locations.count == 2 {
             fullText = "At \(locations[0]) + 1 other eatery."
         } else {
             fullText = "At \(locations[0]) + \(locations.count - 1) other eateries."
         }

         let attributedText = NSMutableAttributedString(
             string: fullText,
             attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .regular), .foregroundColor: UIColor.label]
         )

         let semiboldFont = UIFont.systemFont(ofSize: 16, weight: .semibold)

         if locations.count == 1 {
             if let range = fullText.range(of: "\(locations[0])") {
                 let nsRange = NSRange(range, in: fullText)
                 attributedText.addAttribute(.font, value: semiboldFont, range: nsRange)
             }
         } else if locations.count > 1 {
             if let range = fullText.range(of: "\(locations[0])") {
                 let nsRange = NSRange(range, in: fullText)
                 attributedText.addAttribute(.font, value: semiboldFont, range: nsRange)
             }

             let countString = "+ \(locations.count - 1)"
             if let range2 = fullText.range(of: countString) {
                 let nsRange2 = NSRange(range2, in: fullText)
                 attributedText.addAttribute(.font, value: semiboldFont, range: nsRange2)
             }
         }

         locationLabel.attributedText = attributedText
         locationLabel.textColor = .Eatery.gray05
     }
      */

    /*
     private func setupTimeLabel() {
         timeLabel.text = "Today"
         timeLabel.font = .systemFont(ofSize: 10, weight: .medium)
         timeLabel.textColor = .Eatery.gray05
         contentView.addSubview(timeLabel)
     }
      */

    private func setupTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .Eatery.black
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
    }

    private func setupBodyLabel() {
        bodyLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        bodyLabel.textColor = .Eatery.gray05
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

//        timeLabel.snp.makeConstraints { make in
//            make.leading.equalTo(itemNameLabel.snp.trailing).offset(10)
//            make.centerY.equalTo(itemNameLabel.snp.centerY)
//        }
//
//        locationLabel.snp.makeConstraints { make in
//            make.top.equalTo(itemNameLabel.snp.bottom).offset(2)
//            make.leading.equalTo(itemNameLabel.snp.leading)
//        }
    }
}
