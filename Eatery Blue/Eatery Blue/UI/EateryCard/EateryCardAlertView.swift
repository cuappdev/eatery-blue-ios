//
//  EateryCardAlertView.swift
//  Eatery Blue
//
//  Created by William Ma on 1/21/22.
//

import UIKit

class EateryCardAlertView: UIView {

    let stackView = UIStackView()
    let imageView = UIImageView()
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        insetsLayoutMarginsFromSafeArea = false
        layoutMargins = UIEdgeInsets(top: 2, left: 12, bottom: 2, right: 12)
        tintColor = UIColor.Eatery.orange
        backgroundColor = .white

        addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.spacing = 3
        stackView.axis = .horizontal

        stackView.addArrangedSubview(imageView)
        setUpImageView()

        stackView.addArrangedSubview(titleLabel)
        setUpTitleLabel()
    }

    private func setUpImageView() {
        imageView.image = UIImage(named: "Warning")?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .caption1, weight: .semibold)
    }

    private func setUpConstraints() {
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(layoutMarginsGuide)
        }

        imageView.snp.makeConstraints { make in
            make.width.equalTo(12)
            make.height.greaterThanOrEqualTo(12)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()

        imageView.tintColor = tintColor
        titleLabel.textColor = tintColor
    }

}
