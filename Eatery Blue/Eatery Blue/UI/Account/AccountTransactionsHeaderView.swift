//
//  AccountTransactionsHeaderView.swift
//  Eatery Blue
//
//  Created by William Ma on 1/9/22.
//

import UIKit

class AccountTransactionsHeaderView: UIView {

    let titleLabel = UILabel()
    let buttonImageView = UIImageView()
    let searchBar = UISearchBar()
    private let separator = HDivider()
    let headerLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        addSubview(titleLabel)
        setUpTitleLabel()

        addSubview(buttonImageView)
        setUpButtonImageView()

        addSubview(searchBar)
        setUpSearchBar()

        addSubview(separator)

        addSubview(headerLabel)
        setUpHeaderLabel()
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .title2, weight: .semibold)
        titleLabel.textColor = UIColor(named: "Black")
    }

    private func setUpButtonImageView() {
        buttonImageView.image = UIImage(named: "ButtonChevronDown")
        buttonImageView.isUserInteractionEnabled = true
    }

    private func setUpSearchBar() {
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search for transactions..."
        searchBar.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    private func setUpHeaderLabel() {
        headerLabel.font = .preferredFont(for: .body, weight: .semibold)
        headerLabel.textColor = UIColor(named: "Black")
    }

    private func setUpConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(layoutMarginsGuide)
            make.height.equalTo(buttonImageView)
        }

        buttonImageView.snp.makeConstraints { make in
            make.top.trailing.equalTo(layoutMarginsGuide)
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
            make.width.height.equalTo(40)
        }

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.leading.trailing.equalTo(layoutMarginsGuide).inset(-8)
        }

        separator.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(2)
            make.leading.trailing.equalTo(layoutMarginsGuide)
        }

        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalTo(layoutMarginsGuide)
        }
    }

}
