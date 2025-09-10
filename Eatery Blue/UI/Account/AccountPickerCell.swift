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

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
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
        titleLabel.textColor = UIColor.Eatery.black
    }

    private func setUpImageView() {
        imageView.tintColor = UIColor.Eatery.black
    }

    private func setUpConstraints() {
        snp.makeConstraints { make in
            make.height.equalTo(62)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.leading.equalTo(layoutMarginsGuide)
        }

        imageView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
            make.centerY.trailing.equalTo(layoutMarginsGuide)
            make.width.height.equalTo(24)
        }

        bottomSeparator.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
