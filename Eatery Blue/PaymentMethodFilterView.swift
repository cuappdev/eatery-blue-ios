//
//  PaymentMethodFilterView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/24/21.
//

import UIKit

class PaymentMethodFilterView: UIView {

    let imageView = UIImageView()
    let label = UILabel()

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
        setUpImageView()

        addSubview(label)
        setUpLabel()
    }

    private func setUpImageView() {
    }

    private func setUpLabel() {
        label.font = .preferredFont(for: .caption1, weight: .semibold)
        label.textAlignment = .center
    }

    private func setUpConstraints() {
        imageView.width(64)
        imageView.height(64)
        imageView.top(to: layoutMarginsGuide)
        imageView.centerXToSuperview()

        label.topToBottom(of: imageView, offset: 8)
        label.edges(to: layoutMarginsGuide, excluding: .top)
    }

}
