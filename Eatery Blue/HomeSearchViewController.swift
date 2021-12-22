//
//  HomeSearchViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import UIKit

class HomeSearchViewController: UIViewController {

    private let searchBar = UISearchBar()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let favoritesView = CarouselViewCompact()
    private let recentsView = SearchRecentsView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
        RootViewController.setStatusBarStyle(.darkContent)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        searchBar.searchTextField.becomeFirstResponder()
        searchBar.setShowsCancelButton(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        RootViewController.setStatusBarStyle(.lightContent)
        searchBar.setShowsCancelButton(false, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setUpView() {
        hero.isEnabled = true

        view.backgroundColor = .white
        view.addSubview(searchBar)
        setUpSearchBar()

        view.addSubview(scrollView)
        setUpScrollView()
    }

    private func setUpSearchBar() {
        searchBar.hero.id = "searchBar"
        searchBar.placeholder = "Search for grub..."
        searchBar.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
    }

    private func setUpScrollView() {
        scrollView.addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 24

        stackView.addArrangedSubview(favoritesView)
        setUpFavoritesView()

        stackView.addArrangedSubview(recentsView)
        setUpRecentsView()
    }

    private func setUpFavoritesView() {
        favoritesView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        favoritesView.scrollView.contentInset = favoritesView.layoutMargins
        favoritesView.titleLabel.text = "Favorites"

        for favorite in [DummyData.macs] {
            let cardView = CarouselCardViewCompact()
            cardView.imageView.kf.setImage(with: favorite.imageUrl)
            cardView.titleLabel.text = favorite.name
            favoritesView.addCardView(cardView)
        }
    }

    private func setUpRecentsView() {
        recentsView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let recentSearches = [
            (icon: "Place", title: "Café Jennie", subtitle: nil),
            (icon: "Item", title: "Balsamic Chicken with Spinach & Peppers", subtitle: "Okenshields"),
        ]

        for recentSearch in recentSearches {
            let itemView = SearchRecentItemView()
            itemView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            itemView.imageView.image = UIImage(named: recentSearch.icon)
            itemView.titleLabel.text = recentSearch.title

            if let subtitle = recentSearch.subtitle {
                itemView.subtitleLabel.isHidden = false
                itemView.subtitleLabel.text = subtitle
            } else {
                itemView.subtitleLabel.isHidden = true
            }

            recentsView.addItem(itemView)
        }
    }

    private func setUpConstraints() {
        searchBar.topToSuperview(offset: 12, usingSafeArea: true)
        searchBar.leadingToSuperview()
        searchBar.trailingToSuperview()

        scrollView.topToBottom(of: searchBar, offset: 8)
        scrollView.edgesToSuperview(excluding: .top)

        stackView.edgesToSuperview()
        stackView.width(to: scrollView)
    }

}

extension HomeSearchViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        navigationController?.popViewController(animated: true)
    }

}
