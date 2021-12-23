//
//  VDivider.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import UIKit

class VDivider: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        width(1)
        backgroundColor = UIColor(named: "Gray00")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
