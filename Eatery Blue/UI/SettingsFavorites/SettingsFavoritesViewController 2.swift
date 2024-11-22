//
//  SettingsFavoritesViewController.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 11/18/24.
//

import EateryModel
import UIKit

class SettingsFavoritesViewController: FavoritesViewController {

    init() {
        super.init(allEateries: [], favoriteEateries: [], favoriteItems: [])

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        navigationItem.standardAppearance = nil

        Task {
            await updateFavoritesFromNetworking()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }

    private func updateFavoritesFromNetworking() async {
        do {
            let allEateries = try await Networking.default.loadAllEatery()
            let favoriteEateries = allEateries.filter { eatery in
                AppDelegate.shared.coreDataStack.metadata(eateryId: eatery.id).isFavorite
            }.sorted { lhs, rhs in
                lhs.name < rhs.name
            }

            let favoriteItems = AppDelegate.shared.coreDataStack.fetchFavoriteItems()

            print(allEateries.count)
            self.configure(allEateries: allEateries, favoriteItems: favoriteItems, favoriteEateries: favoriteEateries)
        } catch {
            logger.error("\(#function): \(error)")
        }
    }
}

