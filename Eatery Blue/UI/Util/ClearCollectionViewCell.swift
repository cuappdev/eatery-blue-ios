//
//  ClearCollectionViewCell.swift
//  Eatery Blue
//
//  Created by William Ma on 12/29/21.
//

import UIKit

class ClearCollectionViewCell: UICollectionViewCell {
    static let reuse = "ClearCollectionViewCellReuseId"

    override init(frame: CGRect) {
        super.init(frame: frame)

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
            make.edges.equalToSuperview()
        }
    }
}
