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

        self.width(width)
        self.backgroundColor = UIColor(named: "Gray00")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
