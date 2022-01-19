//
//  HomeSearchContentModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/1/22.
//

import Combine
import CoreData
import EateryModel
import Fuse
import UIKit

class HomeSearchContentModelController: HomeSearchContentViewController {

    private static let searchMinCharacters = 3
    private static let searchMaxCharacters = 120

    private static let searchMaxResults = 100

    enum SearchItem: Fuseable {

        case eatery(Eatery)
        case menuItem(MenuItem, category: String, Eatery)

        var properties: [FuseProperty] {
            switch self {
            case .eatery(let eatery):
                return [
                    FuseProperty(name: eatery.name, weight: 1),
                    FuseProperty(name: eatery.locationDescription ?? "", weight: eatery.locationDescription != nil ? 0.25 : 0),
                ]

            case .menuItem(let item, let category, _):
                return [
                    FuseProperty(name: item.name, weight: 1),
                    FuseProperty(name: item.description ?? "", weight: item.description != nil ? 0.5 : 0),
                    FuseProperty(name: category, weight: 0.5)
                ]
            }
        }

    }

    @Published private var allEateries: [Eatery] = []
    @Published private var filter = EateryFilter()
    @Published private var searchText = ""
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpSearchTextSubscription()
        setUpFilterController()
    }

    private func setUpSearchTextSubscription() {
        $searchText
            .filter({ searchText in
                HomeSearchContentModelController.searchMinCharacters <= searchText.count
                && searchText.count <= HomeSearchContentModelController.searchMaxCharacters
            })
            // Assuming that users type at about 50 wpm...
            // 50 wpm * (5 cpm / wpm) * (1 min / 60 s) = 4.17 characters per second
            // Debounce interval should be 1 / 4.17 < 0.25 seconds per character
            .debounce(for: 0.25, scheduler: DispatchQueue.main)
            .combineLatest($filter, $allEateries)
            .flatMap({ [self] (searchText, filter, allEateries) -> AnyPublisher<([SearchItem], [Fuse.FusableSearchResult]), Never> in
                let eateries: [Eatery]
                if filter.isEnabled {
                    let coreDataStack = AppDelegate.shared.coreDataStack
                    let predicate = filter.predicate(userLocation: LocationManager.shared.userLocation)
                    eateries = allEateries.filter({
                        predicate.isSatisfied(by: $0, metadata: coreDataStack.metadata(eateryId: $0.id))
                    })
                } else {
                    eateries = allEateries
                }
                let searchItems = computeSearchItems(eateries)

                return Fuse(
                    threshold: 0.4,
                    maxPatternLength: HomeSearchContentModelController.searchMaxCharacters
                ).searchPublisher(searchText, in: searchItems).map { results in
                    (searchItems, results)
                }.eraseToAnyPublisher()
            })
            .sink { [self] result in
                updateCells(filtered: filter.isEnabled, searchItems: result.0, searchResults: result.1)
            }
            .store(in: &cancellables)

        // Clear results when search does not contain enough characters
        $searchText.filter { searchText in
            searchText.count < HomeSearchContentModelController.searchMinCharacters
        }.sink { [self] _ in
            updateCells(filtered: false, searchItems: [], searchResults: [])
        }.store(in: &cancellables)
    }

    private func setUpFilterController() {
        filterController.delegate = self
    }

    func setUp(_ eateries: [Eatery]) {
        self.allEateries = eateries
    }

    private func computeSearchItems(_ eateries: [Eatery]) -> [SearchItem] {
        var searchItems: [SearchItem] = []

        let now = Date()
        let today = Day(date: now)

        for eatery in eateries {
            searchItems.append(.eatery(eatery))

            let eventsTodayAfterNow = eatery.events.filter { event in
                event.canonicalDay == today && now <= event.endDate
            }

            for event in eventsTodayAfterNow {
                guard let menu = event.menu else {
                    continue
                }

                for category in menu.categories {
                    for item in category.items {
                        searchItems.append(.menuItem(item, category: category.category, eatery))
                    }
                }
            }
        }

        return searchItems
    }

    private func updateCells(filtered: Bool, searchItems: [SearchItem], searchResults: [Fuse.FusableSearchResult]) {
        var cells: [Cell] = []

        // Lower score is better
        let displayed = searchResults.sorted { lhs, rhs in
            lhs.score < rhs.score
        }.prefix(HomeSearchContentModelController.searchMaxResults)

        if filtered {
            let countView = SearchResultsCountView()
            countView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

            if displayed.count == 1 {
                countView.titleLabel.text = "1 result"
            } else {
                countView.titleLabel.text = "\(displayed.count) results"
            }

            countView.resetButton.on(UITapGestureRecognizer()) { [self] _ in
                filter = EateryFilter()
                filterController.setFilter(EateryFilter())
            }

            cells.append(.customView(view: countView))
        }

        for searchResult in displayed {
            let item = searchItems[searchResult.index]
            switch item {
            case .eatery(let eatery):
                cells.append(.eatery(eatery))

            case .menuItem(let menuItem, _, let eatery):
                cells.append(.item(menuItem, eatery))
            }
        }

        updateCells(cells)
    }

    func searchTextDidChange(_ searchText: String) {
        self.searchText = searchText
    }

    override func didSelectEatery(_ eatery: Eatery, at indexPath: IndexPath) {
        super.didSelectEatery(eatery, at: indexPath)

        addRecentSearch(type: "place", title: eatery.name, subtitle: nil)

        let viewController = EateryModelController()
        viewController.setUp(eatery: eatery)
        navigationController?.hero.isEnabled = false
        navigationController?.pushViewController(viewController, animated: true)
    }

    override func didSelectItem(_ item: MenuItem, at indexPath: IndexPath, eatery: Eatery?) {
        super.didSelectItem(item, at: indexPath, eatery: eatery)

        addRecentSearch(type: "item", title: item.name, subtitle: eatery?.name)

        if let eatery = eatery {
            let viewController = EateryModelController()
            viewController.setUp(eatery: eatery)
            navigationController?.hero.isEnabled = false
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    private func addRecentSearch(type: String, title: String, subtitle: String?) {
        let coreDataStack = AppDelegate.shared.coreDataStack
        let context = coreDataStack.context

        let fetchRequest = NSFetchRequest<RecentSearch>()
        fetchRequest.entity = RecentSearch.entity()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \RecentSearch.dateAdded, ascending: false)]
        fetchRequest.fetchLimit = 5

        let recentSearches: [RecentSearch]
        do {
            recentSearches = try context.fetch(fetchRequest)
        } catch {
            logger.error("\(#function): \(error)")
            return
        }

        if recentSearches.contains(where: { $0.title == title }) {
            return
        }

        let recentSearch = RecentSearch(context: context)
        recentSearch.dateAdded = Date()
        recentSearch.type = type
        recentSearch.title = title
        recentSearch.subtitle = subtitle
        coreDataStack.save()
    }

}

extension HomeSearchContentModelController: EateryFilterViewControllerDelegate {

    func eateryFilterViewController(_ viewController: EateryFilterViewController, filterDidChange filter: EateryFilter) {
        self.filter = filter
    }

}
