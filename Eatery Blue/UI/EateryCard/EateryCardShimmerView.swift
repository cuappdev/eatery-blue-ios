//
//  EateryCardShimmerView.swift
//  Eatery Blue
//
//  Created by Jennifer Gu on 4/26/23.
//

import UIKit

class EateryCardShimmerView: UIView {

    enum EateryCardType {
        case Medium
        case Large
    }

    private struct Constants {
        static let mediumCardFrame = CGRect(x: 0, y: 0, width: 307, height: 186)
        static let largeCardFrame = CGRect(x: 0, y: 0, width: 361, height: 228)
    }

    private(set) var cardType : EateryCardType?
    private var gradientColorOne : CGColor = UIColor.Eatery.gray00.cgColor
    private var gradientColorTwo : CGColor = UIColor.Eatery.gray01.cgColor

    func setUpShimmerView(for cardType: EateryCardType) {
        self.cardType = cardType
    }
    
    private func createGradientLayer() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = {
            switch cardType {
            case .Medium:
                return Constants.mediumCardFrame
            case .Large:
                return Constants.largeCardFrame
            case .none:
                return .zero
            }
        }()
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.8)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.colors = [gradientColorOne, gradientColorTwo, gradientColorOne]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        self.layer.addSublayer(gradientLayer)

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

    func startLoadingAnimation() {
        let gradientLayer = createGradientLayer()
        let animation = createAnimation()

        gradientLayer.add(animation, forKey: animation.keyPath)
    }
}
