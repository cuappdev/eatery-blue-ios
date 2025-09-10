//
//  ClearTableViewCell.swift
//  Eatery Blue
//
//  Created by William Ma on 12/29/21.
//

import UIKit

class ClearTableViewCell: UITableViewCell {
    static let reuse = "ClearTableViewCellReuseId"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = nil
        clipsToBounds = false

        backgroundView = UIView()
        backgroundView?.backgroundColor = nil
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(content: UIView) {
        contentView.subviews.forEach { $0.removeFromSuperview() }

        contentView.addSubview(content)
        content.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
}
