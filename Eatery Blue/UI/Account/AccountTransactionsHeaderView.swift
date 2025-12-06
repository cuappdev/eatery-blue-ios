//
//  AccountTransactionsHeaderView.swift
//  Eatery Blue
//
//  Created by William Ma on 1/9/22.
//

import UIKit

class AccountTransactionsHeaderView: UIView {
    private let stackView = UIStackView()

    private let titleContainer = ContainerView(content: UIView())
    let titleLabel = UILabel()
    let buttonImageView = UIImageView()

    private let searchBarContainer = ContainerView(content: UISearchBar())
    var searchBar: UISearchBar {
        searchBarContainer.content
    }

    private let separatorContainer = ContainerView(content: HDivider())

    private let headerLabelContainer = ContainerView(content: UILabel())
    var headerLabel: UILabel {
        headerLabelContainer.content
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        insetsLayoutMarginsFromSafeArea = false
        layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.axis = .vertical

        stackView.addArrangedSubview(titleContainer)
        setUpTitleContainer()

        // stackView.addArrangedSubview(searchBarContainer)
        // setUpSearchBar()

        stackView.addArrangedSubview(separatorContainer)
        setUpSeparator()

        stackView.addArrangedSubview(headerLabelContainer)
        setUpHeaderLabel()
    }

    private func setUpTitleContainer() {
        titleContainer.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 6, right: 16)

        titleContainer.content.addSubview(titleLabel)
        setUpTitleLabel()

        titleContainer.content.addSubview(buttonImageView)
        setUpButtonImageView()
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .title2, weight: .semibold)
        titleLabel.textColor = UIColor.Eatery.primaryText
    }

    private func setUpButtonImageView() {
        buttonImageView.image = UIImage(named: "ChevronDown")
        buttonImageView.isUserInteractionEnabled = true
    }

    private func setUpSearchBar() {
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search for transactions..."

        searchBarContainer.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }

    private func setUpSeparator() {
        separatorContainer.layoutMargins = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
    }

    private func setUpHeaderLabel() {
        headerLabel.font = .preferredFont(for: .body, weight: .semibold)
        headerLabel.textColor = UIColor.Eatery.primaryText

        headerLabelContainer.layoutMargins = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
    }

    private func setUpConstraints() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
        }

        buttonImageView.snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
            make.width.height.equalTo(40)
        }
    }
}
