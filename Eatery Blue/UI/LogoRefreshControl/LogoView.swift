//
//  LogoView.swift
//  Eatery Blue
//
//  Created by William Ma on 1/3/22.
//

import UIKit

class LogoView: UIView {
    let pin = UIImageView()
    let pizza = UIImageView()

    var sweepFraction: CGFloat = 0.82

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        isOpaque = false
        backgroundColor = .clear

        addSubview(pin)
        pin.image = UIImage(named: "Pin")?.withRenderingMode(.alwaysTemplate)
        pin.tintColor = .white

        addSubview(pizza)
        pizza.image = UIImage(named: "Pizza")?.withRenderingMode(.alwaysTemplate)
        pizza.tintColor = .white

        pin.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(2.5)
            make.height.equalTo(17.39)
            make.width.equalTo(14)
        }

        pizza.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(14.5)
            make.width.height.equalTo(27)
        }

        snp.makeConstraints { make in
            make.width.height.equalTo(48)
        }
    }

    override func draw(_: CGRect) {
        let lineWidth: CGFloat = 2
        let startAngle: CGFloat = .pi * (0.5 - sweepFraction)

        let bezierPath = UIBezierPath(
            arcCenter: CGPoint(x: 24, y: 28),
            radius: (35 - lineWidth) / 2,
            startAngle: startAngle,
            endAngle: startAngle + 2 * .pi * sweepFraction,
            clockwise: true
        )

        UIColor.white.setStroke()
        bezierPath.lineWidth = lineWidth
        bezierPath.lineCapStyle = .round
        bezierPath.stroke()
    }
}
