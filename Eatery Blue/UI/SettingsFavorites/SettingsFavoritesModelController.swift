//
//  SettingsFavoritesModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/24/22.
//

import Foundation

@MainActor
class SettingsFavoritesModelController: SettingsFavoritesViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Task {
            await updateFavoriteEateriesFromNetworking()
        }
    }

    private func updateFavoriteEateriesFromNetworking() async {
        do {
            let allEateries = try await Networking.default.loadAllEatery()
            let favoriteEateries = allEateries.filter { eatery in
                AppDelegate.shared.coreDataStack.metadata(eateryId: eatery.id).isFavorite
            }.sorted { lhs, rhs in
                lhs.name < rhs.name
            }
            updateFavoriteEateries(favoriteEateries)
        } catch {
            logger.error("\(#function): \(error)")
        }
    }

}
