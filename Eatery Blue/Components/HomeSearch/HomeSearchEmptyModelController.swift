//
//  HomeSearchEmptyModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/1/22.
//

import UIKit

class HomeSearchEmptyModelController: HomeSearchEmptyViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        updateFavorites([DummyData.macs, DummyData.rpcc])
        updateRecentSearches([
            RecentSearch(type: .place, title: "Cafe Jennie", subtitle: nil),
            RecentSearch(type: .item, title: "Balsamic Chicken with Spinach & Peppers", subtitle: "Okenshields"),
            RecentSearch(type: .place, title: "Terrace Restaurant", subtitle: nil),
            RecentSearch(type: .item, title: "Whole Grain Fried Rice with Egg", subtitle: "Okenshields")
        ])
    }

}
