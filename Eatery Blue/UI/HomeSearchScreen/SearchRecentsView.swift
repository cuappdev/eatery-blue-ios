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
        titleLabel.textColor = UIColor.Eatery.black
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
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(layoutMarginsGuide)
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    func addItem(_ itemView: SearchRecentItemView) {
        stackView.addArrangedSubview(itemView)
    }

    func removeAllItems() {
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
    }

}
