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
        titleLabel.top(to: layoutMarginsGuide)
        titleLabel.leading(to: layoutMarginsGuide)
        titleLabel.height(to: buttonImageView)

        buttonImageView.top(to: layoutMarginsGuide)
        buttonImageView.leadingToTrailing(of: titleLabel, offset: 8)
        buttonImageView.trailing(to: layoutMarginsGuide)
        buttonImageView.height(40)
        buttonImageView.width(40)

        searchBar.topToBottom(of: titleLabel, offset: 2)
        // Counter the 8-px margin built into the search bar
        searchBar.leading(to: layoutMarginsGuide, offset: -8)
        searchBar.trailing(to: layoutMarginsGuide, offset: 8)

        separator.topToBottom(of: searchBar, offset: 2)
        separator.leading(to: layoutMarginsGuide)
        separator.trailing(to: layoutMarginsGuide)

        headerLabel.topToBottom(of: searchBar, offset: 12)
        headerLabel.edges(to: layoutMarginsGuide, excluding: .top)
    }

}
