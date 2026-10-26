//
//  FavoritesStore.swift
//  Eatery Blue
//
//  Created by Arielle Nudelman on 10/25/26.
//

import Foundation

enum FavoritesStore {
    @discardableResult
    static func setEateryFavorite(_ isFavorite: Bool, eateryId: Int?) -> Bool {
        let coreDataStack = AppDelegate.shared.coreDataStack
        let metadata = coreDataStack.metadata(eateryId: eateryId)
        metadata.isFavorite = isFavorite
        coreDataStack.save()
        return metadata.isFavorite
    }

    static func isEateryFavorite(eateryId: Int?) -> Bool {
        AppDelegate.shared.coreDataStack.metadata(eateryId: eateryId).isFavorite
    }

    @discardableResult
    static func toggleEateryFavorite(eateryId: Int?) -> Bool {
        let coreDataStack = AppDelegate.shared.coreDataStack
        let metadata = coreDataStack.metadata(eateryId: eateryId)
        metadata.isFavorite.toggle()
        coreDataStack.save()
        return metadata.isFavorite
    }

    static func isItemFavorite(itemName: String) -> Bool {
        AppDelegate.shared.coreDataStack.metadata(itemName: itemName).isFavorite
    }

    @discardableResult
    static func setItemFavorite(_ isFavorite: Bool, item: ItemMetadata) -> Bool {
        item.isFavorite = isFavorite
        AppDelegate.shared.coreDataStack.save()
        syncItemFavorite(isFavorite, itemName: item.itemName)
        return item.isFavorite
    }

    @discardableResult
    static func toggleItemFavorite(itemName: String) -> Bool {
        let coreDataStack = AppDelegate.shared.coreDataStack
        let metadata = coreDataStack.metadata(itemName: itemName)
        metadata.isFavorite.toggle()
        coreDataStack.save()
        let isFavorite = metadata.isFavorite
        syncItemFavorite(isFavorite, itemName: itemName)
        return isFavorite
    }

    private static func syncItemFavorite(_ isFavorite: Bool, itemName: String?) {
        guard let itemName else { return }
        Task {
            await FavoriteItemSyncCoordinator.shared.setFavorite(isFavorite, itemName: itemName)
        }
    }
}
