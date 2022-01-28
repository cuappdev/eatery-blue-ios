//
//  AlertMessageView.swift
//  Eatery Blue
//
//  Created by William Ma on 1/28/22.
//

import UIKit

class AlertMessageView: UIView {

    private let stackView = UIStackView()
    let imageView = UIImageView()
    let messageLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()

        setStyleError()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        insetsLayoutMarginsFromSafeArea = false
        layoutMargins = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)

        layer.cornerRadius = 8
        backgroundColor = UIColor(named: "EateryRedLight")

        addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.spacing = 4
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center

        stackView.addArrangedSubview(imageView)
        setUpImageView()

        stackView.addArrangedSubview(messageLabel)
        setUpMessageLabel()
    }

    private func setUpImageView() {
        imageView.contentMode = .scaleAspectFit
    }

    private func setUpMessageLabel() {
        messageLabel.font = .preferredFont(for: .caption1, weight: .semibold)
        messageLabel.numberOfLines = 0
    }

    private func setUpConstraints() {
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(layoutMarginsGuide)
        }

        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(12)
        }
    }

    func setStyleError() {
        backgroundColor = UIColor(named: "EateryRedLight")
        imageView.image = UIImage(named: "Error")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor(named: "EateryRed")
        messageLabel.textColor = UIColor(named: "EateryRed")
    }

    func setStyleInfo() {
        backgroundColor = UIColor(named: "EateryBlueLight")
        imageView.image = UIImage(named: "Info")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor(named: "EateryBlue")
        messageLabel.textColor = UIColor(named: "EateryBlue")
    }

}
