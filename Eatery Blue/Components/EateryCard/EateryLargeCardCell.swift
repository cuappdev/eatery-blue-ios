//
//  EateryLargeCardCell.swift
//  Eatery Blue
//
//  Created by William Ma on 12/29/21.
//

import UIKit

class EateryLargeCardCell: UIView {

    let cardView: EateryLargeCardView
    private lazy var container = ContainerView(content: cardView)

    override init(frame: CGRect) {
        self.cardView = EateryLargeCardView()

        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    init(cardView: EateryLargeCardView) {
        self.cardView = cardView

        super.init(frame: .zero)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        insetsLayoutMarginsFromSafeArea = false

        container.cornerRadius = 8
        container.shadowRadius = 4
        container.shadowOffset = CGSize(width: 0, height: 4)
        container.shadowColor = UIColor(named: "ShadowLight")
        container.shadowOpacity = 0.25
        addSubview(container)
    }

    private func setUpConstraints() {
        container.edges(to: layoutMarginsGuide)
    }

}