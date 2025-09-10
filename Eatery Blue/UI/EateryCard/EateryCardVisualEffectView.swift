//
//  EateryCardVisualEffectView.swift
//  Eatery Blue
//
//  Created by William Ma on 1/11/22.
//

import UIKit

class EateryCardVisualEffectView<Content: UIView>: UIView {
    let content: Content
    private lazy var container = ContainerView(content: content)

    override init(frame: CGRect) {
        content = Content()

        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    init(content: Content) {
        self.content = content

        super.init(frame: .zero)

        setUpSelf()
        setUpConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        insetsLayoutMarginsFromSafeArea = false
        layoutMargins = .zero

        container.cornerRadius = 8
        container.shadowRadius = 4
        container.shadowOffset = CGSize(width: 0, height: 4)
        container.shadowColor = UIColor.Eatery.shadowLight
        container.shadowOpacity = 0.25
        addSubview(container)
    }

    private func setUpConstraints() {
        container.snp.makeConstraints { make in
            make.edges.equalTo(layoutMarginsGuide)
        }
    }
}
