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

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    override func hitTest(_ point: CGPoint, with _: UIEvent?) -> UIView? {
        var answer = scrollView as UIView // if nothing is found we will do the expected

        // find the UIStackView inside, if there is none then we just return the scrollView
        guard let stackView = scrollView.subviews.first(where: { $0 is UIStackView }) else { return answer }

        let adjustedPoint = point.applying(CGAffineTransform(
            translationX: scrollView.contentOffset.x - (frame.width / 2 - scrollView.frame.width / 2),
            y: 0
        ))
        // Go through the stackView's subviews. If one is within hit point, return that
        answer = stackView.subviews.first { $0.frame.contains(adjustedPoint) } ?? answer

        // return the answer
        return answer
    }
}
