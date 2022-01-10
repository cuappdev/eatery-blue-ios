//
//  CarouselTableViewCell.swift
//  Eatery Blue
//
//  Created by William Ma on 12/29/21.
//

import UIKit

class CarouselTableViewCell: UITableViewCell {

    let carouselView = CarouselView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setUpContentView()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpContentView() {
        contentView.addSubview(carouselView)

        carouselView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        carouselView.scrollView.contentInset = carouselView.layoutMargins
    }

    private func setUpConstraints() {
        carouselView.edgesToSuperview()
    }

}
