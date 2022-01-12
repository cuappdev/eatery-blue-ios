//
//  CarouselMoreEateriesView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import UIKit

class CarouselMoreEateriesView: UIView {

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
        backgroundColor = UIColor(named: "OffWhite")
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor(named: "Gray01")?.cgColor

        addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.distribution = .fill

        stackView.addArrangedSubview(imageView)
        setUpImageView()

        stackView.addArrangedSubview(titleLabel)
        setUpTitleLabel()
    }

    private func setUpImageView() {
        imageView.image = UIImage(named: "ButtonNext")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor(named: "Gray05")
        imageView.contentMode = .scaleAspectFit
    }

    private func setUpTitleLabel() {
        titleLabel.textColor = UIColor(named: "EateryBlue")
        titleLabel.font = .preferredFont(for: .callout, weight: .semibold)
        titleLabel.text = "More eateries"
    }

    private func setUpConstraints() {
        snp.makeConstraints { make in
            make.width.equalTo(186)
        }

        stackView.snp.makeConstraints { make in
            make.leading.trailing.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview()
        }
    }

}
