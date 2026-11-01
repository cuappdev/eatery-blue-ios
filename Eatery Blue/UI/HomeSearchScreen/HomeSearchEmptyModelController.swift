//
//  HomeSearchEmptyModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/1/22.
//

import CoreData
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateRecentSearchesFromCoreData()
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
