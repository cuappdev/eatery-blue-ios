//
//  EateryCardTableViewCell.swift
//  Eatery Blue
//
//  Created by William Ma on 12/29/21.
//

import UIKit

class EateryCardTableViewCell: ClearTableViewCell {

    let cell: EateryCardCell

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.cell = EateryCardCell()

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setUpSelf()
        setUpConstraints()
    }

    init(cardView: EateryCardView) {
        self.cell = EateryCardCell(cardView: cardView)

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
