//
//  CarouselViewCompact.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import UIKit

class CarouselViewCompact: UIView {

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
        buttonImageView.image = UIImage(named: "ForwardButton")
    }

    private func setUpScrollView() {
        scrollView.alwaysBounceHorizontal = true
        scrollView.clipsToBounds = false

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
        titleLabel.top(to: self, self.layoutMarginsGuide.topAnchor)
        titleLabel.leading(to: self, self.layoutMarginsGuide.leadingAnchor)
        titleLabel.trailingToLeading(of: buttonImageView)
        titleLabel.height(to: buttonImageView)

        buttonImageView.top(to: self, self.layoutMarginsGuide.topAnchor)
        buttonImageView.trailing(to: self, self.layoutMarginsGuide.trailingAnchor)
        buttonImageView.height(40)
        buttonImageView.width(40)

        scrollView.topToBottom(of: titleLabel, offset: 12)
        scrollView.leadingToSuperview()
        scrollView.trailingToSuperview()
        scrollView.bottom(to: self, self.layoutMarginsGuide.bottomAnchor)
        scrollView.height(140)

        stackView.edgesToSuperview()
        stackView.height(140)
    }

    func addCardView(_ cardView: CarouselCardViewCompact) {
        stackView.addArrangedSubview(cardView)
    }

}
