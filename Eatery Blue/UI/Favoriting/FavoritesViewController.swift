//
//  FavoritesViewController.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 10/11/24.
//

import EateryModel
import UIKit

class FavoritesViewController: UIViewController {
    // MARK: - Properties (view)

    private let favoriteEateriesView = FavoritesEateriesView()
    private let favoriteItemsView = FavoritesItemsView()
    private let favoritesNavigationView = FavoritesNavigationView()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    // MARK: - Properties (data)

    private var allEateries: [Eatery] = []
    private var favoriteEateries: [Eatery] = []
    private var favoriteItems: [ItemMetadata] = []
    private var observer: NSObjectProtocol?

    // MARK: - Deinit

    deinit {
        removeObserver(current: observer)
    }

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

        viewRespectsSystemMinimumLayoutMargins = false
        view.backgroundColor = UIColor.Eatery.default00

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

        addFavoriteObservation(current: &observer) { [weak self] _ in
            guard let self else { return }

            Task { [weak self] in
                guard let self else { return }

                await updateFavoritesFromNetworking()
            }
        }

        setUpConstraints()
    }

    override func viewWillDisappear(_: Bool) {
        navigationController?.navigationBar.isHidden = false
    }

    private func setUpFavoritesNavigationView() {
        favoritesNavigationView.navigationController = navigationController
        favoritesNavigationView.tabButtonsDelegate = self
        favoritesNavigationView.delegate = self
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

    private func setUpConstraints() {
        favoritesNavigationView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(220)
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
                AppDelegate.shared.coreDataStack.metadata(eateryId: eatery.cornellId).isFavorite
            }.sorted { lhs, rhs in
                lhs.name < rhs.name
            }

            let favoriteItems = try AppDelegate.shared.coreDataStack.fetchFavoriteItems()

            configure(allEateries: allEateries, favoriteItems: favoriteItems, favoriteEateries: favoriteEateries)
        } catch {
            logger.error("\(#function): \(error)")
        }
    }
}

extension FavoritesViewController: TabButtonViewDelegate {
    func tabButtonView(_: TabButtonView, didSelect label: String) {
        if label == "Items" {
            scrollView.scrollRectToVisible(favoriteItemsView.frame, animated: true)
        } else if label == "Eateries" {
            scrollView.scrollRectToVisible(favoriteEateriesView.frame, animated: true)
        }
    }
}

extension FavoritesViewController: FavoritesNavigationViewDelegate {
    func favoritesNavigationViewDidTapAdd(_: FavoritesNavigationView) {
        let searchVC = FavoritesAddSearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
    }
}
