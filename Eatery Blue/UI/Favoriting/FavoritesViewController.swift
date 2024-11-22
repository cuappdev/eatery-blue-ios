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
    private var favoriteItems: [ItemMetadata]

    // MARK: - Init

    init(allEateries: [Eatery], favoriteEateries: [Eatery], favoriteItems: [ItemMetadata]) {
        self.allEateries = allEateries
        self.favoriteEateries = favoriteEateries
        self.favoriteItems = favoriteItems
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure

    func configure(allEateries: [Eatery], favoriteItems: [ItemMetadata], favoriteEateries: [Eatery]) {
        favoriteEateriesView.allEateries = allEateries
        favoriteItemsView.allEateries = allEateries
        favoriteItemsView.favoriteItems = favoriteItems
        favoriteEateriesView.listEateries = favoriteEateries
    }

    // MARK: - Set Up

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

        setUpConstraints()
    }

    private func setUpFavoritesNavigationView() {
        favoritesNavigationView.navigationController = navigationController
        favoritesNavigationView.tabButtonsDelegate = self
    }

    private func setUpFavoriteEateriesView() {
        favoriteEateriesView.listEateries = favoriteEateries
        favoriteEateriesView.allEateries = allEateries
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
