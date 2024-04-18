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
<<<<<<< HEAD
        
        var answer = scrollView as UIView // if nothing is found we will do the expected

        // find the UIStackView inside, if there is none then we just return the scrollView
        guard let stackView = scrollView.subviews.first(where: { $0 is UIStackView }) else { return answer }

        let adjustedPoint = point.applying(CGAffineTransform(translationX: scrollView.contentOffset.x - (self.frame.width / 2 - scrollView.frame.width / 2), y: 0))
        // Go through the stackView's subviews. If one is within hit point, return that
        stackView.subviews.forEach {
            if $0.frame.contains(adjustedPoint) {
                answer = $0
            }
        }

        // return the answer
        return answer
=======
        // find the UIStackView inside, if there is none then we just return the scrollView
        guard let stackView = scrollView.subviews.first(where: { subview in
            return subview is UIStackView
        }) else { return scrollView }

        let adjustedPoint = point.applying(CGAffineTransform(translationX: scrollView.contentOffset.x - (self.frame.width / 2 - scrollView.frame.width / 2), y: 0))
        // Go through the stackView's subviews. If one is within hit point, return that
        for stackSubView in stackView.subviews {
            if stackSubView.frame.contains(adjustedPoint) {
                print("hit", stackSubView)
                return stackSubView
            }
        }

        // otherwise return the scrollView
        return scrollView
>>>>>>> f700b62 (implement tappable tabs for compare menus)
    }

}
