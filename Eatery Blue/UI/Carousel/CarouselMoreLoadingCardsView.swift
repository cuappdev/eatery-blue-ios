//
//  CarouselMoreLoadingCardsView.swift
//  Eatery Blue
//
//  Created by Antoinette Marie Torres on 4/25/23.
//

import UIKit

class CarouselMoreLoadingCardsView: UIView {

    private let stackView = UIStackView()
    private let imageView = UIView()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.Eatery.gray00
        layer.cornerRadius = 8

        addSubview(stackView)
        setUpStackView()
        setUpImageView()
        setUpTitleLabel()
        
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.distribution = .fill

        stackView.addArrangedSubview(imageView)

        stackView.addArrangedSubview(titleLabel)
    }

    private func setUpImageView() {
        imageView.backgroundColor = UIColor.Eatery.gray00
    }

    private func setUpTitleLabel() {
        titleLabel.backgroundColor = UIColor.Eatery.gray00
    }

    private func setUpConstraints() {
        super.snp.makeConstraints { make in
            make.width.equalTo(186)
        }

        stackView.snp.makeConstraints { make in
            make.leading.trailing.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview()
        }
    }
}
