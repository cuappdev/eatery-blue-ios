//
//  VDivider.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import UIKit

class VDivider: UIView {
    init(width: CGFloat = 1) {
        super.init(frame: .zero)

        backgroundColor = UIColor.Eatery.gray00
        snp.makeConstraints { make in
            make.width.equalTo(width)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
