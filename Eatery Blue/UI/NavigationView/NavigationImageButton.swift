//
//  NavigationImageButton.swift
//  Eatery Blue
//
//  Created by William Ma on 1/8/22.
//

import UIKit

class NavigationImageButton: UIView {

    let imageView = UIImageView()

    var image: UIImage? {
        get {
            imageView.image
        }
        set {
            imageView.image = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(imageView)
    }

    private func setUpConstraints() {
        imageView.width(24)
        imageView.height(24)
        imageView.centerXToSuperview()
        imageView.centerYToSuperview()

        width(to: imageView, relation: .equal)
    }

}
