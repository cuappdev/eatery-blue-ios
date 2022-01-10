//
//  AccountPickerCell.swift
//  Eatery Blue
//
//  Created by William Ma on 1/9/22.
//

import UIKit

class AccountPickerCell: UIView {

    let titleLabel = UILabel()
    let imageView = UIImageView()
    let bottomSeparator = HDivider()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(titleLabel)
        setUpTitleLabel()

        addSubview(imageView)
        setUpImageView()

        addSubview(bottomSeparator)
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .body, weight: .semibold)
        titleLabel.textColor = UIColor(named: "Black")
    }

    private func setUpImageView() {
        imageView.tintColor = UIColor(named: "Black")
    }

    private func setUpConstraints() {
        height(62)

        titleLabel.leading(to: layoutMarginsGuide)
        titleLabel.centerY(to: layoutMarginsGuide)
        titleLabel.trailingToLeading(of: imageView, offset: 8)

        imageView.trailing(to: layoutMarginsGuide)
        imageView.centerY(to: layoutMarginsGuide)
        imageView.width(24)
        imageView.height(24)

        bottomSeparator.edges(to: layoutMarginsGuide, excluding: .top)
    }

}
