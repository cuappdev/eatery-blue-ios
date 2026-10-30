//
//  HomeSearchModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/1/22.
//

import Combine
import EateryModel
import UIKit

class HomeSearchModelController: HomeSearchViewController {
    private var cancellables: Set<AnyCancellable> = []
    private var allEateries: [Eatery] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpSearchBar()
        setUpEmptyController()

        Task {
            await updateEateriesFromNetworking()
        }
    }

    private func setUpSearchBar() {
        searchBar.delegate = self
    }

    private func setUpEmptyController() {
        emptyController.delegate = self
    }

    private func updateEateriesFromNetworking() async {
        do {
            let eateries = try await Networking.default.loadAllEatery()
            allEateries = eateries
            contentController.setUp(eateries)
        } catch {
            logger.error("\(error)")
        }
    }
}

extension HomeSearchModelController: UISearchBarDelegate {
    func searchBar(_: UISearchBar, textDidChange searchText: String) {
        let showingEmpty = searchText.isEmpty
        emptyController.view.alpha = showingEmpty ? 1 : 0
        emptyController.view.isUserInteractionEnabled = showingEmpty
        contentController.view.alpha = showingEmpty ? 0 : 1
        contentController.view.isUserInteractionEnabled = !showingEmpty

        contentController.searchTextDidChange(searchText)
    }

    func searchBarCancelButtonClicked(_: UISearchBar) {
        navigationController?.popViewController(animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension HomeSearchModelController: HomeSearchEmptyModelControllerDelegate {
    func homeSearchEmptyModelController(
        _: HomeSearchEmptyModelController,
        didSelectRecentSearch recentSearch: RecentSearch
    ) {
        Task { @MainActor in
            spinner.startAnimating()
            view.isUserInteractionEnabled = false
            defer {
                spinner.stopAnimating()
                view.isUserInteractionEnabled = true
            }

            if allEateries.isEmpty {
                await updateEateriesFromNetworking()
            }

            guard let eatery = resolveEatery(for: recentSearch) else {
                logger.error(
                    "Failed to open recent search \(recentSearch.title ?? "") id=\(recentSearch.eateryID)"
                )
                return
            }

            let viewController = EateryModelController()
            viewController.setUp(eatery: eatery, isTracking: true)
            navigationController?.hero.isEnabled = false
            navigationController?.pushViewController(viewController, animated: true)
            viewController.setUpMenu(eatery: eatery)
        }
    }

    private func resolveEatery(for recentSearch: RecentSearch) -> Eatery? {
        let eateryID = Int(recentSearch.eateryID)

        if eateryID != 0,
           let eatery = allEateries.first(where: { $0.id == eateryID || $0.cornellId == eateryID }) {
            return eatery
        }

        if let title = recentSearch.title {
            if recentSearch.type == "item",
               let subtitle = recentSearch.subtitle,
               let eatery = allEateries.first(where: { $0.name == subtitle }) {
                return eatery
            }

            if let eatery = allEateries.first(where: { $0.name == title }) {
                return eatery
            }
        }

        return nil
    }
}
