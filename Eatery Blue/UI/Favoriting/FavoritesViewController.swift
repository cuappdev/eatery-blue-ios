//
//  FavoritesViewController.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 10/11/24.
//

import EateryModel
import UIKit

class FavoritesViewController: UIViewController {

    // MARK: - Properties (View)

    private let favoriteEateriesView = EateryListView()
    private let favoriteItemsView = FavoritesItemsView()
    private let favoritesNavigationView = FavoritesNavigationView()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    // MARK: - Properties (Data)

    private var allEateries: [Eatery] = []
    private var favoriteEateries: [Eatery] = []
    private var favoriteItems: [ItemMetadata] = []

    // MARK: - Configure

    private func configure(allEateries: [Eatery], favoriteItems: [ItemMetadata], favoriteEateries: [Eatery]) {
        self.allEateries = allEateries
        self.favoriteEateries = favoriteEateries
        self.favoriteItems = favoriteItems
        favoriteEateriesView.eateries = favoriteEateries
        favoriteItemsView.allEateries = allEateries
        favoriteItemsView.favoriteItems = favoriteItems
    }

    // MARK: - Set Up

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        navigationItem.standardAppearance = nil

        Task {
            await updateFavoritesFromNetworking()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewRespectsSystemMinimumLayoutMargins = false
        view.backgroundColor = .white

        setUpFavoritesNavigationView()
        view.addSubview(favoritesNavigationView)

        setUpScrollView()
        view.addSubview(scrollView)

        setUpStackView()
        scrollView.addSubview(stackView)

        setUpFavoriteEateriesView()
        stackView.addArrangedSubview(favoriteEateriesView)

        setUpFavoriteItemsView()
        stackView.addArrangedSubview(favoriteItemsView)

        setUpFavNotification()

        setUpConstraints()
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }

    private func setUpFavoritesNavigationView() {
        favoritesNavigationView.navigationController = navigationController
        favoritesNavigationView.tabButtonsDelegate = self
        favoritesNavigationView.searchDelegate = self
    }

    private func setUpFavoriteEateriesView() {
        favoriteEateriesView.eateries = favoriteEateries
        favoriteEateriesView.navigationController = navigationController
    }

    private func setUpScrollView() {
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = favoritesNavigationView
        scrollView.isPagingEnabled = true
    }

    private func setUpStackView() {
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill
    }

    private func setUpFavoriteItemsView() {
        favoriteItemsView.allEateries = allEateries
        favoriteItemsView.favoriteItems = favoriteItems
    }

    private func setUpFavNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshFavorites(_:)),
            name: NSNotification.Name("favoriteEatery"),
            object: nil
        )
    }

    private func setUpConstraints() {
        favoritesNavigationView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(208)
        }

        scrollView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.top.equalTo(favoritesNavigationView.snp.bottom)
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.height.equalTo(scrollView.frameLayoutGuide.snp.height)
        }

        favoriteEateriesView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(view.snp.width)
        }

        favoriteItemsView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(view.snp.width)
        }
    }

    // MARK: - Networking

    private func updateFavoritesFromNetworking() async {
        do {
            let allEateries = try await Networking.default.loadAllEatery()

            let favoriteEateries = allEateries.filter { eatery in
                AppDelegate.shared.coreDataStack.metadata(eateryId: eatery.id).isFavorite
            }.sorted { lhs, rhs in
                lhs.name < rhs.name
            }

            let favoriteItems = AppDelegate.shared.coreDataStack.fetchFavoriteItems()

            self.configure(allEateries: allEateries, favoriteItems: favoriteItems, favoriteEateries: favoriteEateries)
        } catch {
            logger.error("\(#function): \(error)")
        }
    }

    // MARK: - Actions

    @objc private func refreshFavorites(_ notification: Notification) {
        Task {
            await updateFavoritesFromNetworking()
        }
    }

}

extension FavoritesViewController: TabButtonViewDelegate {

    func tabButtonView(_ tabButtonView: TabButtonView, didSelect label: String) {
        if label == "Items" {
            scrollView.scrollRectToVisible(favoriteItemsView.frame, animated: true)
        } else if label == "Eateries" {
            scrollView.scrollRectToVisible(favoriteEateriesView.frame, animated: true)
        }
    }

}

extension FavoritesViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            favoriteEateriesView.eateries = favoriteEateries
            favoriteItemsView.favoriteItems = favoriteItems
        } else {
            favoriteEateriesView.eateries = favoriteEateries.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            favoriteItemsView.favoriteItems = favoriteItems.filter { $0.itemName?.lowercased().contains(searchText.lowercased()) ?? false }
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        favoritesNavigationView.searchShown = false
    }

}

