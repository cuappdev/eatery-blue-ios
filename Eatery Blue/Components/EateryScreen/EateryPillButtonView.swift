//
//  EateryPillButtonView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import UIKit

class EateryPillButtonView: UIView {

    private let container = UIView()
    let imageView = UIImageView()
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(container)
        setUpContainer()
    }

    private func setUpContainer() {
        container.addSubview(imageView)
        setUpImageView()

        container.addSubview(titleLabel)
        setUpTitleLabel()
    }

    private func setUpImageView() {
        imageView.contentMode = .scaleAspectFit
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .body, weight: .semibold)
    }

    private func setUpConstraints() {
        container.centerXToSuperview()
        container.leading(to: layoutMarginsGuide, relation: .equalOrGreater)
        container.trailing(to: layoutMarginsGuide, relation: .equalOrLess)
        container.top(to: layoutMarginsGuide)
        container.bottom(to: layoutMarginsGuide)

        imageView.width(24)
        imageView.height(24)
        imageView.centerYToSuperview()
        imageView.leadingToSuperview()
        imageView.topToSuperview(relation: .equalOrGreater)

        titleLabel.leadingToTrailing(of: imageView, offset: 4)
        titleLabel.topToSuperview()
        titleLabel.trailingToSuperview()
        titleLabel.bottomToSuperview()
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }

}
