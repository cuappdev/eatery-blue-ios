//
//  LoginErrorMessageView.swift
//  Eatery Blue
//
//  Created by William Ma on 1/7/22.
//

import UIKit

class LoginErrorMessageView: UIView {

    let imageView = UIImageView()
    let messageLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        layer.cornerRadius = 8
        backgroundColor = UIColor(named: "EateryRedLight")

        addSubview(imageView)
        setUpImageView()

        addSubview(messageLabel)
        setUpMessageLabel()
    }

    private func setUpImageView() {
        imageView.image = UIImage(named: "Error")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor(named: "EateryRed")
    }

    private func setUpMessageLabel() {
        messageLabel.textColor = UIColor(named: "EateryRed")
        messageLabel.font = .preferredFont(for: .caption1, weight: .semibold)
        messageLabel.numberOfLines = 0
    }

    private func setUpConstraints() {
        imageView.snp.makeConstraints { make in
            make.leading.centerY.equalTo(layoutMarginsGuide)
            make.width.height.equalTo(12)
        }

        messageLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(4)
            make.top.trailing.bottom.equalTo(layoutMarginsGuide)
        }
    }

}
