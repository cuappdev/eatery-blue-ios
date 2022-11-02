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
        titleLabel.textColor = UIColor.Eatery.black
        titleLabel.font = .preferredFont(for: .body, weight: .semibold)
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
    }

    private func setUpConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(layoutMarginsGuide)
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalTo(layoutMarginsGuide)
        }
    }

    func addItemView(_ itemView: MenuItemView) {
        if !stackView.arrangedSubviews.isEmpty {
            stackView.addArrangedSubview(HDivider())
        }

        stackView.addArrangedSubview(itemView)
    }

}
