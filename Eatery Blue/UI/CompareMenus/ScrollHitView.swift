//
//  ScrollHitView.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 3/27/24.
//

import UIKit

class ScrollHitView: UIView {

    let scrollView: UIScrollView

    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return scrollView
    }

}
