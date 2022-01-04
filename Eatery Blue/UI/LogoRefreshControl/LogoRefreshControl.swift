//
//  LogoRefreshControl.swift
//  Eatery Blue
//
//  Created by William Ma on 1/3/22.
//

import UIKit

protocol LogoRefreshControlDelegate: AnyObject {

    func logoRefreshControlDidBeginRefreshing(_ sender: LogoRefreshControl)
    func logoRefreshControlDidEndRefreshing(_ sender: LogoRefreshControl)

}

class LogoRefreshControl: UIControl {

    let logoView = LogoView()

    private(set) var isRefreshing: Bool = false

    weak var delegate: LogoRefreshControlDelegate? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(logoView)
        logoView.centerXToSuperview()
        logoView.centerYToSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let scale = min(bounds.width / logoView.bounds.width, bounds.height / logoView.bounds.height)
        logoView.transform = CGAffineTransform(scaleX: scale, y: scale)
    }

    func setPullProgress(_ progress: CGFloat) {
        let progress = max(0, min(1, progress))
        logoView.sweepFraction = 0.82 + (1 - 0.82) * progress
        logoView.pin.transform = CGAffineTransform(translationX: 0, y: -progress * logoView.bounds.height / 3)
        logoView.setNeedsDisplay()
    }

    func beginRefreshing() {
        CATransaction.setDisableActions(true)
        let angle: CGFloat = 6 * .pi
        let spin = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
        spin.duration = 2
        spin.valueFunction = CAValueFunction(name: .rotateZ)
        spin.fromValue = 0
        spin.toValue = angle
        spin.repeatCount = .infinity
        spin.timingFunction = CAMediaTimingFunction(controlPoints: 0.7, 0, 0.3, 1)
        logoView.pizza.layer.add(spin, forKey: "refreshAnimation")
        logoView.pizza.layer.transform = CATransform3DMakeRotation(angle, 0, 0, 1)

        isRefreshing = true
        sendActions(for: .valueChanged)

        delegate?.logoRefreshControlDidBeginRefreshing(self)
    }

    func endRefreshing() {
        logoView.pizza.layer.removeAnimation(forKey: "refreshAnimation")
        isRefreshing = false
        
        delegate?.logoRefreshControlDidEndRefreshing(self)
    }

}
