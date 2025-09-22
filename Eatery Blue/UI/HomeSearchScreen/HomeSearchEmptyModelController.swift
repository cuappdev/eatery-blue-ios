//
//  HomeSearchEmptyModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/1/22.
//

import Combine
import CoreData
import EateryModel
import UIKit

protocol HomeSearchEmptyModelControllerDelegate: AnyObject {
    func homeSearchEmptyModelController(
        _ viewController: HomeSearchEmptyModelController,
        didSelectRecentSearch recentSearch: RecentSearch
    )
}

@MainActor
class HomeSearchEmptyModelController: HomeSearchEmptyViewController {
    weak var delegate: HomeSearchEmptyModelControllerDelegate?

    private var cancellables: Set<AnyCancellable> = []

    private var allEateries: [Eatery] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateRecentSearchesFromCoreData()
        updateFavoritesFromCoreData()
    }

    func setUp(_ eateries: [Eatery]) {
        allEateries = eateries
    }

    private func updateFavoritesFromCoreData() {
        let coreData = AppDelegate.shared.coreDataStack
        let favorites = allEateries.filter { eatery in
            coreData.metadata(eateryId: eatery.id).isFavorite
        }

        updateFavorites(favorites)
    }

    private func updateFavorites(_ favorites: [Eatery]) {
        guard !favorites.isEmpty else {
            favoritesView.isHidden = true
            return
        }

        favoritesView.isHidden = false

        favoritesView.removeAllCardViews()

        favoritesView.buttonImageView.tap { [self] _ in
            let viewController = ListModelController()
            viewController.setUp(favorites, title: "Favorite Eateries", description: nil)
            navigationController?.hero.isEnabled = false
            navigationController?.pushViewController(viewController, animated: true)
        }

        let coreDataStack = AppDelegate.shared.coreDataStack

        for favorite in favorites {
            let cardView = EaterySmallCardView()
            cardView.configure(eatery: favorite, favorited: coreDataStack.metadata(eateryId: favorite.id).isFavorite)
            cardView.tap { [self] _ in
                let viewController = EateryModelController()
                viewController.setUp(eatery: favorite, isTracking: false)
                navigationController?.hero.isEnabled = false
                navigationController?.pushViewController(viewController, animated: true)
                viewController.setUpMenu(eatery: favorite)
            }
            favoritesView.addCardView(cardView)
        }
    }

    private func updateRecentSearchesFromCoreData() {
        let context = AppDelegate.shared.coreDataStack.context

        let fetchRequest = NSFetchRequest<RecentSearch>()
        fetchRequest.entity = RecentSearch.entity()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \RecentSearch.dateAdded, ascending: false)]
        fetchRequest.fetchLimit = 5

        let recentSearches: [RecentSearch]
        do {
            recentSearches = try context.fetch(fetchRequest)
            logger.debug("Fetched \(recentSearches.count) recent searches")
        } catch {
            recentSearches = []
            logger.debug("\(#function): \(error)")
        }

        updateRecentSearches(recentSearches)
    }

    private func updateRecentSearches(_ recentSearches: [RecentSearch]) {
        recentsView.removeAllItems()

        for recentSearch in recentSearches {
            let itemView = SearchRecentItemView()
            itemView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            switch recentSearch.type {
            case "item":
                itemView.imageView.image = UIImage(named: "Item")?.withRenderingMode(.alwaysTemplate)
            default:
                itemView.imageView.image = UIImage(named: "Place")?.withRenderingMode(.alwaysTemplate)
            }
            itemView.imageView.tintColor = UIColor.Eatery.blue
            itemView.titleLabel.text = recentSearch.title

            if let subtitle = recentSearch.subtitle {
                itemView.subtitleLabel.isHidden = false
                itemView.subtitleLabel.text = subtitle
            } else {
                itemView.subtitleLabel.isHidden = true
            }

            itemView.tap { [self] _ in
                delegate?.homeSearchEmptyModelController(self, didSelectRecentSearch: recentSearch)
            }

            recentsView.addItem(itemView)
        }
    }
}
