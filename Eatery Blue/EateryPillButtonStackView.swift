//
//  EateryPillButtonStackView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import UIKit

class EateryPillButtonStackView: UIView {

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
        addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 12
    }

    private func setUpConstraints() {
        stackView.edges(to: layoutMarginsGuide)
    }

    func addPillButton(_ view: EateryPillButtonView) {
        stackView.addArrangedSubview(view)
    }

}
