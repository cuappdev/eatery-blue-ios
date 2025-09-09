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

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        insetsLayoutMarginsFromSafeArea = false
        layoutMargins = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)

        layer.cornerRadius = 8
        backgroundColor = UIColor.Eatery.redLight

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
        backgroundColor = UIColor.Eatery.redLight
        imageView.image = UIImage(named: "Error")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor.Eatery.red
        messageLabel.textColor = UIColor.Eatery.red
    }

    func setStyleInfo() {
        backgroundColor = UIColor.Eatery.blueLight
        imageView.image = UIImage(named: "Info")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor.Eatery.blue
        messageLabel.textColor = UIColor.Eatery.blue
    }
}
