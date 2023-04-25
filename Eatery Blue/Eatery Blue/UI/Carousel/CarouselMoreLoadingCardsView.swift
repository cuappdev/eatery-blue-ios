//
//  CarouselMoreLoadingCardsView.swift
//  Eatery Blue
//
//  Created by Antoinette Marie Torres on 4/25/23.
//

import UIKit

class CarouselMoreLoadingCardsView: UIView {

    let stackView = UIStackView()
    let imageView = UIView()
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
        backgroundColor = UIColor.Eatery.gray00
        layer.cornerRadius = 8

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
        imageView.backgroundColor = UIColor.Eatery.gray00
    }

    private func setUpTitleLabel() {
        titleLabel.backgroundColor = UIColor.Eatery.gray00
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
