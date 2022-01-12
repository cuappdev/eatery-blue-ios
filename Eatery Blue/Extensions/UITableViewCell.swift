//
//  UITableViewCell.swift
//  Eatery Blue
//
//  Created by William Ma on 1/9/22.
//

import UIKit

extension UITableViewCell {

    convenience init(content: UIView) {
        self.init(style: .default, reuseIdentifier: nil)

        contentView.addSubview(content)
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}
