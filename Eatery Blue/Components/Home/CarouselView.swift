//
//  CarouselView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import UIKit

class CarouselView: UIView {

    let titleLabel = UILabel()
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    let buttonImageView = UIImageView()

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

        addSubview(buttonImageView)
        setUpButtonImageView()

        addSubview(scrollView)
        setUpScrollView()
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .title2, weight: .semibold)
    }

    private func setUpButtonImageView() {
        buttonImageView.isUserInteractionEnabled = true
        buttonImageView.image = UIImage(named: "ButtonArrowForward")
    }

    private func setUpScrollView() {
        scrollView.alwaysBounceHorizontal = true
        scrollView.clipsToBounds = false
        scrollView.showsHorizontalScrollIndicator = false

        scrollView.addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fill
    }

    private func setUpConstraints() {
        titleLabel.top(to: layoutMarginsGuide)
        titleLabel.leading(to: layoutMarginsGuide)
        titleLabel.trailingToLeading(of: buttonImageView)
        titleLabel.height(to: buttonImageView)

        buttonImageView.top(to: layoutMarginsGuide)
        buttonImageView.trailing(to: layoutMarginsGuide)
        buttonImageView.height(40)
        buttonImageView.width(40)

        scrollView.topToBottom(of: titleLabel, offset: 12)
        scrollView.leadingToSuperview()
        scrollView.trailingToSuperview()
        scrollView.bottom(to: self, self.layoutMarginsGuide.bottomAnchor)
        scrollView.height(186)

        stackView.edgesToSuperview()
        stackView.height(186)
    }

    func addCardView(_ cardView: CarouselCardView) {
        let container = ContainerView(content: cardView)
        container.cornerRadius = 8
        container.shadowRadius = 4
        container.shadowOffset = CGSize(width: 0, height: 4)
        container.shadowColor = UIColor(named: "ShadowLight")
        container.shadowOpacity = 0.25
        container.width(295)
        stackView.addArrangedSubview(container)
    }

}
