//
//  PillView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import UIKit

class PillView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }

}
