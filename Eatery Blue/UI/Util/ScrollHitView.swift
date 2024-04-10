//
//  ScrollHitView.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 3/27/24.
//

import UIKit

class ScrollHitView: UIView {

    // MARK: - Properties (view)

    let scrollView: UIScrollView

    // MARK: - Init

    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return scrollView
    }

}
