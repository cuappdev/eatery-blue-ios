//
//  FavoritesNavigationView.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 10/26/24.
//

import UIKit

class FavoritesNavigationView: UIView {
    // MARK: - Properties (view)

    private let eateriesTab = TabButtonView()
    private let itemsTab = TabButtonView()
    private let navigationBar = UINavigationBar()
    private let navigationItem = UINavigationItem()
    private let placeholderView = UIView()
    private let searchBar = UISearchBar()
    private let titleLabel = UILabel()

    // MARK: - Properties (data)

    /// The controller that this view uses to pop on back button press
    var navigationController: UINavigationController?
    /// Search bar delegate, called when search bar text changes
    var searchDelegate: UISearchBarDelegate? {
        didSet {
            searchBar.delegate = searchDelegate
        }
    }

    /// Whether or not the search bar should be shown
    var searchShown = false {
        didSet {
            if !searchShown {
                searchBar.text = ""
                searchDelegate?.searchBar?(searchBar, textDidChange: "")
                UIView.animate(withDuration: 0.1) { [weak self] in
                    guard let self else { return }
                    searchBar.snp.updateConstraints { make in
                        make.height.equalTo(0)
                    }

                    layoutIfNeeded()
                } completion: { [weak self] _ in
                    guard let self else { return }

                    searchBar.resignFirstResponder()
                    searchBar.isHidden = true
                }
            } else {
                searchBar.becomeFirstResponder()
                searchBar.isHidden = false
                UIView.animate(withDuration: 0.1) { [weak self] in
                    guard let self else { return }
                    searchBar.snp.updateConstraints { make in
                        make.height.equalTo(36)
                    }

                    layoutIfNeeded()
                }
            }
        }
    }

    /// Tab buttons delegate, called when tab buttons are pressed
    var tabButtonsDelegate: TabButtonViewDelegate? {
        didSet {
            eateriesTab.delegate = tabButtonsDelegate
            itemsTab.delegate = tabButtonsDelegate
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSelf()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Set Up

    private func setUpSelf() {
        layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 4, right: 16)
        backgroundColor = UIColor.Eatery.default00

        addSubview(navigationBar)
        setUpNavigationBar()

        addSubview(titleLabel)
        setUpTitleLabel()

        addSubview(eateriesTab)
        setUpEateriesTab()

        addSubview(itemsTab)
        setUpItemsTab()

        addSubview(placeholderView)

        addSubview(searchBar)
        setUpSearchBar()

        setUpConstraints()
        searchShown = false
    }

    private func setUpNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.tintColor = UIColor.Eatery.primaryText

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "ArrowLeft"),
            style: .plain,
            target: self,
            action: #selector(didTapBackButton)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "Search"),
            style: .plain,
            target: self,
            action: #selector(didTapSearchButton)
        )
        navigationBar.setItems([navigationItem], animated: false)
    }

    @objc private func didTapBackButton() {
        navigationController?.hero.isEnabled = false
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapSearchButton() {
        searchShown = true
        searchBar.becomeFirstResponder()
    }

    private func setUpTitleLabel() {
        titleLabel.text = "Favorites"
        titleLabel.font = .eateryNavigationBarLargeTitleFont
        titleLabel.textColor = UIColor.Eatery.blue
    }

    private func setUpEateriesTab() {
        eateriesTab.text = "Eateries"
        eateriesTab.buttonPress { [weak self] _ in
            guard let self else { return }
            itemsTab.selected = false
        }

        eateriesTab.selected = true
    }

    private func setUpItemsTab() {
        itemsTab.text = "Items"
        itemsTab.buttonPress { [weak self] _ in
            guard let self else { return }
            eateriesTab.selected = false
        }

        itemsTab.selected = false
    }

    private func setUpSearchBar() {
        searchBar.setShowsCancelButton(true, animated: false)
        searchBar.placeholder = "Search for faves..."
        searchBar.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = UIColor.Eatery.default00
    }

    private func setUpConstraints() {
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(layoutMarginsGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(layoutMarginsGuide.snp.leading).inset(4)
            make.trailing.equalTo(layoutMarginsGuide.snp.trailing)
            make.top.equalTo(navigationBar.snp.bottom)
            make.height.equalTo(42)
        }

        placeholderView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(8)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.equalTo(layoutMarginsGuide)
        }

        eateriesTab.snp.makeConstraints { make in
            make.height.equalTo(36)
            make.trailing.equalTo(placeholderView.snp.leading)
            make.leading.bottom.equalTo(layoutMarginsGuide)
        }

        itemsTab.snp.makeConstraints { make in
            make.height.equalTo(36)
            make.leading.equalTo(placeholderView.snp.trailing)
            make.trailing.bottom.equalTo(layoutMarginsGuide)
        }

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(layoutMarginsGuide)
            make.leading.trailing.equalToSuperview().priority(.low)
            make.height.equalTo(0)
        }
    }
}

extension FavoritesNavigationView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !scrollView.isDragging {
            return
        }

        if scrollView.contentOffset.x > scrollView.contentSize.width / 4 {
            eateriesTab.selected = false
            itemsTab.selected = true
        } else {
            eateriesTab.selected = true
            itemsTab.selected = false
        }
    }
}
