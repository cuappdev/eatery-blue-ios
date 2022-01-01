//
//  HomeSearchModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/1/22.
//

import UIKit

class HomeSearchModelController: HomeSearchViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpSearchBar()
    }

    private func setUpSearchBar() {
        searchBar.delegate = self
    }

    func setUp(_ eateries: [Eatery]) {
        contentController.setUp(eateries)
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
