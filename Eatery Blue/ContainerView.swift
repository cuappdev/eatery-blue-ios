//
//  ContainerView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import UIKit

class ContainerView<Content: UIView>: UIView {

    let clippingView = UIView()

    var content: Content? {
        willSet {
            if let content = content {
                content.removeFromSuperview()
            }
        }
        didSet {
            if let content = content {
                clippingView.addSubview(content)
                content.edges(to: layoutMarginsGuide)
            }
        }
    }

    var cornerRadius: CGFloat = 0 {
        didSet {
            clippingView.clipsToBounds = true
            clippingView.layer.cornerRadius = cornerRadius
        }
    }

    var shadowColor: UIColor? {
        didSet {
            layer.shadowColor = shadowColor?.cgColor
        }
    }

    var shadowOffset: CGSize = .zero {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }

    var shadowOpacity: Float = 0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }

    var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }

    convenience init(content: Content?) {
        self.init()

        self.layoutMargins = .zero

        addSubview(clippingView)
        clippingView.edges(to: self)

        self.content = content

        if let content = content {
            clippingView.addSubview(content)
            content.edges(to: layoutMarginsGuide)
        }
    }

}
