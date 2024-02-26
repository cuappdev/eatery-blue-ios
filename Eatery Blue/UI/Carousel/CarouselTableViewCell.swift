//
//  CarouselTableViewCell.swift
//  Eatery Blue
//
//  Created by William Ma on 12/29/21.
//

import UIKit

// NOTE FROM PETER: CLASS IS UNUSED. REMOVE?
class CarouselTableViewCell: UITableViewCell {

    let carouselView = CarouselView(allItems: [], carouselItems: [], navigationController: nil, shouldTruncate: false)

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
//        carouselView.scrollView.contentInset = carouselView.layoutMargins
    }

    private func setUpConstraints() {
        carouselView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}
