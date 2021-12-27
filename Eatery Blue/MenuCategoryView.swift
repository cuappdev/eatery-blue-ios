//
//  CafeMenuCategoryView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import UIKit

class MenuCategoryView: UIView {

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
        titleLabel.textColor = UIColor(named: "Black")
        titleLabel.font = .preferredFont(for: .body, weight: .semibold)
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
    }

    private func setUpConstraints() {
        titleLabel.edges(to: layoutMarginsGuide, excluding: .bottom)

        stackView.topToBottom(of: titleLabel, offset: 12)
        stackView.edges(to: layoutMarginsGuide, excluding: .top)
    }

    func addItemView(_ itemView: MenuItemView) {
        if !stackView.arrangedSubviews.isEmpty {
            stackView.addArrangedSubview(HDivider())
        }

        stackView.addArrangedSubview(itemView)
    }

}
