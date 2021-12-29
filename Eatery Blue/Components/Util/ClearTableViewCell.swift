//
//  ClearTableViewCell.swift
//  Eatery Blue
//
//  Created by William Ma on 12/29/21.
//

import UIKit

class ClearTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = nil
        clipsToBounds = false

        backgroundView = UIView()
        backgroundView?.backgroundColor = nil
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
