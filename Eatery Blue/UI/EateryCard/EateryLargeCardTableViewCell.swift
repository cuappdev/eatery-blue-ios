//
//  EateryLargeCardTableViewCell.swift
//  Eatery Blue
//
//  Created by William Ma on 12/29/21.
//

import UIKit

class EateryLargeCardTableViewCell: ClearTableViewCell {

    let cell: EateryLargeCardCell

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.cell = EateryLargeCardCell()

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setUpSelf()
        setUpConstraints()
    }

    init(cardView: EateryLargeCardView) {
        self.cell = EateryLargeCardCell(cardView: cardView)

        super.init(style: .default, reuseIdentifier: nil)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        contentView.addSubview(cell)
    }

    private func setUpConstraints() {
        cell.edgesToSuperview()
    }

}
