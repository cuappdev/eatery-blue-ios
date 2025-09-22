//
//  HDivider.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import UIKit

class HDivider: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.Eatery.gray00
        snp.makeConstraints { make in
            make.height.equalTo(1)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
