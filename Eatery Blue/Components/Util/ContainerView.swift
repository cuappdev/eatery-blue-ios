//
//  ContainerView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import UIKit

class ContainerView<Content: UIView>: UIView {

    let clippingView = UIView()

    var content: Content {
        willSet {
            content.removeFromSuperview()
        }
        didSet {
            clippingView.addSubview(content)
            content.edges(to: layoutMarginsGuide)
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

    var shadowOpacity: Double = 0 {
        didSet {
            layer.shadowOpacity = Float(shadowOpacity)
        }
    }

    var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }

    private var isPill: Bool = false

    init(content: Content) {
        self.content = content

        super.init(frame: .null)

        self.layoutMargins = .zero

        addSubview(clippingView)
        clippingView.edges(to: self)

        clippingView.addSubview(content)
        content.edges(to: layoutMarginsGuide)
    }

    convenience init(pillContent: Content) {
        self.init(content: pillContent)
        self.isPill = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if isPill {
            cornerRadius = min(clippingView.bounds.width, clippingView.bounds.height) / 2
        }
    }

}
