//
//  HomeSearchModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/1/22.
//

import Combine
import UIKit

class HomeSearchModelController: HomeSearchViewController {

    private var cancellables: Set<AnyCancellable> = []

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
            let eateries = try await Networking.default.eateries.fetch(maxStaleness: .infinity)
            contentController.setUp(eateries)
            emptyController.setUp(eateries)
        } catch {
            logger.error("\(error)")
        }
    }

}

extension HomeSearchModelController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        emptyController.view.alpha = searchText.isEmpty ? 1 : 0
        contentController.view.alpha = searchText.isEmpty ? 0 : 1

        contentController.searchTextDidChange(searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationController?.popViewController(animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

}

extension HomeSearchModelController: HomeSearchEmptyModelControllerDelegate {

    func homeSearchEmptyModelController(
        _ viewController: HomeSearchEmptyModelController,
        didSelectRecentSearch recentSearch: RecentSearch
    ) {
        searchBar.text = recentSearch.title
        searchBar(searchBar, textDidChange: searchBar.text ?? "")
    }

}
