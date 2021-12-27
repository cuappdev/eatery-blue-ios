//
//  CardStackView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import UIKit

class CardStackView: UIView {

    let titleLabel = UILabel()
    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(titleLabel)
        setUpTitleLabel()

        addSubview(stackView)
        setUpStackView()
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .title2, weight: .semibold)
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.spacing = 12
    }

    private func setUpConstraints() {
        titleLabel.edges(to: layoutMarginsGuide, excluding: .bottom)

        stackView.topToBottom(of: titleLabel, offset: 12)
        stackView.edges(to: layoutMarginsGuide, excluding: .top)
    }

    func addCardView(_ cardView: CardView) {
        let container = ContainerView(content: cardView)
        container.cornerRadius = 8
        container.shadowRadius = 4
        container.shadowOffset = CGSize(width: 0, height: 4)
        container.shadowColor = UIColor(named: "ShadowLight")
        container.shadowOpacity = 0.25
        container.height(216)
        stackView.addArrangedSubview(container)
    }

}
