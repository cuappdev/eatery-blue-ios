//
//  EateryCardShimmerCollectionViewCell.swift
//  Eatery Blue
//
//  Created by Jennifer Gu on 4/26/23.
//

import UIKit

class EateryCardShimmerCollectionViewCell: UICollectionViewCell {
    static let reuse = "EateryCardShimmerCollectionViewCellReuseId"

    enum EateryCardType {
        case Medium
        case Large
    }

    private(set) var cardType : EateryCardType?
    private var gradientColorOne : CGColor = UIColor.Eatery.gray00.cgColor
    private var gradientColorTwo : CGColor = UIColor.Eatery.gray01.cgColor

    override func layoutSubviews() {
        super.layoutSubviews()
        configure()
    }

    private func createGradientLayer() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame.size = contentView.frame.size
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.8)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.colors = [gradientColorOne, gradientColorTwo, gradientColorOne]
        gradientLayer.cornerRadius = 8
        gradientLayer.locations = [0.0, 0.5, 1.0]
        self.contentView.layer.addSublayer(gradientLayer)

        return gradientLayer
    }

    private func createAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = 1

        return animation
    }

    func configure() {
        let gradientLayer = createGradientLayer()
        let animation = createAnimation()

        gradientLayer.add(animation, forKey: animation.keyPath)
    }
}
