//
//  NotificationTableViewCell.swift
//  Eatery Blue
//
//  Created by Adelynn Wu on 11/5/25.
//

import Foundation
import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    // MARK: Properties (view)
    private let itemNameLabel = UILabel()
    private let locationLabel = UILabel()
    private let timeLabel = UILabel()
    private let starImageView = UIImageView()
    private let arrowButton = UIButton()
    
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
    
    func configure(notification: Notification) {
        itemNameLabel.text = notification.itemName
        
        setupLocationLabelText(notification.eateries)
        
        starImageView.image = UIImage(named: notification.checked ? "CheckedNotif" : "UncheckedNotif")
    }
    
    // MARK: setup helpers
    private func setupSelf() {
        setupItemNameLabel()

        contentView.addSubview(locationLabel)
        
        setupTimeLabel()
        setupStarImage()
        setupArrowButton()
        setupConstraints()
    }
    
    private func setupItemNameLabel() {
        itemNameLabel.font = .systemFont(ofSize: 14, weight: .bold)
        itemNameLabel.textColor = .Eatery.black
        
        contentView.addSubview(itemNameLabel)
    }
    
    private func setupLocationLabelText(_ locations: [String]) {
        var fullText = ""
        if (locations.count == 0) {
            fullText = "" // TODO: locations should always has length > 0
        } else if (locations.count == 1) {
            fullText = "At \(locations[0])."
        } else {
            fullText = "At \(locations[0]) + \(locations.count - 1) other eateries."
        }
        
        let attributedText = NSMutableAttributedString(
            string: fullText,
            attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .regular), .foregroundColor: UIColor.label]
        )
       
        if (locations.count == 1) {
            if let range = fullText.range(of: "\(locations[0])") {
                let nsRange = NSRange(range, in: fullText)
                attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .semibold), range: nsRange)
            }
        } else if (locations.count > 1) {
            if let range = fullText.range(of: "\(locations[0])") {
                let nsRange = NSRange(range, in: fullText)
                attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .semibold), range: nsRange)
            }
            
            let countString = "+ \(locations.count - 1)"
           if let range2 = fullText.range(of: countString) {
               let nsRange2 = NSRange(range2, in: fullText)
               attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .semibold), range: nsRange2)
           }
        }
        
        contentView.addSubview(locationLabel)
    }
    
    private func setupTimeLabel() {
        timeLabel.text = "Today"
        timeLabel.font = .systemFont(ofSize: 10, weight: .medium)
        timeLabel.textColor = .Eatery.gray05
        contentView.addSubview(timeLabel)
    }
    
    private func setupStarImage() {
        starImageView.image = UIImage(named: "UncheckedNotif")
        starImageView.contentMode = .scaleAspectFit
        contentView.addSubview(starImageView)
    }
    
    private func setupArrowButton() {
        let arrowImage = UIImage(systemName: "arrow.right")
        
        let circleSize: CGFloat = 40
        let circle = UIView(frame: CGRect(x: 0, y: 0, width: circleSize, height: circleSize))
        circle.backgroundColor = .Eatery.gray03
        circle.layer.cornerRadius = circleSize / 2

        let imageView = UIImageView(image: arrowImage)
        imageView.tintColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        circle.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: circle.centerYAnchor)
        ])
        
        arrowButton.addSubview(circle)
        
        // TODO: push detailed page
        // arrowButton.addTarget(<#T##target: Any?##Any?#>, action: <#T##Selector#>, for: <#T##UIControl.Event#>)
        
        contentView.addSubview(arrowButton)
    }

    private func setupConstraints() {
        starImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview();
            make.top.equalToSuperview();
            make.height.equalTo(22);
            make.width.equalTo(22)
        }
        
        itemNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(starImageView.snp.trailing);
            make.top.equalToSuperview();
        }
        
        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(itemNameLabel.snp.trailing);
            make.centerY.equalTo(itemNameLabel.snp.centerY);
        }
        
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(itemNameLabel.snp.bottom);
            make.leading.equalTo(itemNameLabel.snp.leading);
        }
    }
}
