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

        Networking.default
            .fetchEateries(maxStaleness: .infinity)
            .sink { _ in
            } receiveValue: { [self] eateries in
                contentController.setUp(eateries)
            }
            .store(in: &cancellables)

    }

    private func setUpSearchBar() {
        searchBar.delegate = self
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

}