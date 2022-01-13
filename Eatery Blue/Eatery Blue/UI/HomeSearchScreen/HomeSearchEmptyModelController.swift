//
//  HomeSearchEmptyModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/1/22.
//

import Combine
import EateryModel
import UIKit

protocol HomeSearchEmptyModelControllerDelegate: AnyObject {

    func homeSearchEmptyModelController(
        _ viewController: HomeSearchEmptyModelController,
        didSelectRecentSearch recentSearch: RecentSearch
    )

}

class HomeSearchEmptyModelController: HomeSearchEmptyViewController {

    weak var delegate: HomeSearchEmptyModelControllerDelegate?

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        updateFavorites([DummyData.macs])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateRecentSearchesFromCoreData()
    }

    private func updateRecentSearchesFromCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let stack = appDelegate.coreDataStack

        let sortDescriptor = NSSortDescriptor(keyPath: \RecentSearch.dateAdded, ascending: false)

        stack
            .fetch(RecentSearch.self, sortDescriptors: [sortDescriptor], fetchLimit: 5)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    logger.error("\(error)")
                }
            } receiveValue: { [self] recentSearches in
                logger.debug("Fetched \(recentSearches.count) recent searches", metadata: nil)
                updateRecentSearches(recentSearches)
            }
            .store(in: &cancellables)
    }

    func updateFavorites(_ favorites: [Eatery]) {
        favoritesView.removeAllCardViews()

        favoritesView.buttonImageView.on(UITapGestureRecognizer()) { [self] _ in
            let viewController = ListModelController()
            viewController.setUp(favorites, title: "Favorite Eateries", description: nil)
            navigationController?.hero.isEnabled = false
            navigationController?.pushViewController(viewController, animated: true)
        }

        for favorite in favorites {
            let cardView = EaterySmallCardView()
            cardView.imageView.kf.setImage(with: favorite.imageUrl)
            cardView.titleLabel.text = favorite.name
            cardView.on(UITapGestureRecognizer()) { [self] _ in
                let viewController = EateryModelController()
                viewController.setUp(eatery: favorite)
                navigationController?.hero.isEnabled = false
                navigationController?.pushViewController(viewController, animated: true)
            }
            favoritesView.addCardView(cardView)
        }
    }

    func updateRecentSearches(_ recentSearches: [RecentSearch]) {
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
            itemView.imageView.tintColor = UIColor(named: "EateryBlue")
            itemView.titleLabel.text = recentSearch.title

            if let subtitle = recentSearch.subtitle {
                itemView.subtitleLabel.isHidden = false
                itemView.subtitleLabel.text = subtitle
            } else {
                itemView.subtitleLabel.isHidden = true
            }

            itemView.on(UITapGestureRecognizer()) { [self] _ in
                delegate?.homeSearchEmptyModelController(self, didSelectRecentSearch: recentSearch)
            }

            recentsView.addItem(itemView)
        }
    }

}
