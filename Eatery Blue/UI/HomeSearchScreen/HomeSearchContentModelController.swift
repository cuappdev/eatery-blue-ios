//
//  HomeSearchContentModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/1/22.
//

import Combine
import Fuse
import UIKit

class HomeSearchContentModelController: HomeSearchContentViewController {

    enum SearchItem: Fuseable {

        case eatery(Eatery)
        case menuItem(MenuItem, category: String, Eatery)

        var properties: [FuseProperty] {
            switch self {
            case .eatery(let eatery):
                return [
                    FuseProperty(name: eatery.name, weight: 1),
                    FuseProperty(name: eatery.building ?? "", weight: eatery.building != nil ? 0.25 : 0),
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
        // Minimum number of characters before beginning search
        let minCharacters = 3

        $searchText
            .filter({ searchText in
                minCharacters <= searchText.count && searchText.count <= 30
            })
            // Assuming that users type at about 50 wpm...
            // 50 wpm * (5 cpm / wpm) * (1 min / 60 s) = 4.17 characters per second
            // Debounce interval should be 1 / 4.17 < 0.25 seconds per character
            .debounce(for: 0.25, scheduler: DispatchQueue.main)
            .combineLatest($filter, $allEateries)
            .flatMap({ [self] (searchText, filter, allEateries) -> AnyPublisher<([SearchItem], [Fuse.FusableSearchResult]), Never> in
                let eateries: [Eatery]
                if filter.isEnabled {
                    let predicate = filter.predicate(userLocation: LocationManager.shared.userLocation)
                    eateries = allEateries.filter(predicate.isSatisfiedBy(_:))
                } else {
                    eateries = allEateries
                }
                let searchItems = computeSearchItems(eateries)

                return Fuse(threshold: 0.4).searchPublisher(searchText, in: searchItems).map { results in
                    (searchItems, results)
                }.eraseToAnyPublisher()
            })
            .sink { [self] result in
                updateCells(filtered: filter.isEnabled, searchItems: result.0, searchResults: result.1)
            }
            .store(in: &cancellables)

        // Clear results when search does not contain enough characters
        $searchText.filter { searchText in
            searchText.count < minCharacters
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
                        guard item.isSearchable else {
                            continue
                        }

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
        }.prefix(100)

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
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let coreData = appDelegate.coreDataStack

        let sortDescriptor = NSSortDescriptor(keyPath: \RecentSearch.dateAdded, ascending: false)

        coreData.fetch(RecentSearch.self, sortDescriptors: [sortDescriptor], fetchLimit: 5).sink { completion in
            switch completion {
            case .failure(let error): logger.error("\(#function): \(error)")
            case .finished: break
            }
        } receiveValue: { recentSearches in
            if !recentSearches.contains(where: { $0.title == title }) {
                let recentSearch = coreData.create(RecentSearch.self)
                recentSearch.dateAdded = Date()
                recentSearch.type = type
                recentSearch.title = title
                recentSearch.subtitle = subtitle
                coreData.save()
            }
        }
        .store(in: &cancellables)
    }

}

extension HomeSearchContentModelController: EateryFilterViewControllerDelegate {

    func eateryFilterViewController(_ viewController: EateryFilterViewController, filterDidChange filter: EateryFilter) {
        self.filter = filter
    }

}
