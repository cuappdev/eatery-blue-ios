//
//  NotificationItemCell.swift
//  Eatery Blue
//
//  Created by Angelina Chen on 3/11/26.
//

import UIKit

class NotificationItemCell: UITableViewCell {
    static let reuse = "NotificationItemCell"

    let itemLabel = UILabel()
    let subtitleLabel = UILabel()
    let arrowButton = UIButton()

    var onArrowTap: (() -> Void)?

    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setUpViews()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    func configure(item: ItemMetadata) {
        itemLabel.text = item.itemName
        subtitleLabel.text = "Available today"
    }

    private func setUpViews() {
        arrowButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)

        contentView.addSubview(itemLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(arrowButton)

        arrowButton.addTarget(self,
                              action: #selector(didTapArrow),
                              for: .touchUpInside)

        itemLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(itemLabel)
            make.top.equalTo(itemLabel.snp.bottom).offset(4)
        }

        arrowButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
        }
    }

    @objc
    private func didTapArrow() {
        onArrowTap?()
    }
}
