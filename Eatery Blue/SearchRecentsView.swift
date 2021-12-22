//
//  SearchRecentsView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import UIKit

class SearchRecentsView: UIView {

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
        titleLabel.font = .preferredFont(for: .title2, weight: .semibold)
        titleLabel.text = "Recent Searches"
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 12
    }

    private func setUpConstraints() {
        titleLabel.edges(to: layoutMarginsGuide, excluding: .bottom)

        stackView.topToBottom(of: titleLabel, offset: 12)
        stackView.edgesToSuperview(excluding: .top)
    }

    func addItem(_ itemView: SearchRecentItemView) {
        stackView.addArrangedSubview(itemView)
    }

}
