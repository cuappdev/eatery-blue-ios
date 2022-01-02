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
        // Assuming that users type at about 50 wpm
        // 50 wpm * (5 cpm / wpm) * (1 min / 60 s) = 4.17 characters per second
        // Debounce interval should be 1 / 4.17 ~= 0.25 seconds per character

        $searchText
            .filter({ searchText in
                3 <= searchText.count && searchText.count <= 30
            })
            .debounce(for: 0.25, scheduler: DispatchQueue.main, options: nil)
            .combineLatest($filter, $allEateries)
            .flatMap({ [self] (searchText, filter, allEateries) -> AnyPublisher<([SearchItem], [Fuse.FusableSearchResult]), Never> in
                let filtered = allEateries.filter(filter.predicate(userLocation: nil).isSatisfiedBy(_:))
                let searchItems = computeSearchItems(filtered)

                return Fuse(threshold: 0.4).searchPublisher(searchText, in: searchItems).map { results in
                    (searchItems, results)
                }.eraseToAnyPublisher()
            })
            .sink { [self] result in
                updateCells(searchItems: result.0, searchResults: result.1)
            }
            .store(in: &cancellables)
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

    private func updateCells(searchItems: [SearchItem], searchResults: [Fuse.FusableSearchResult]) {
        cells = []

        // Lower score is better match
        let displayed = searchResults.sorted { lhs, rhs in
            lhs.score < rhs.score
        }.prefix(100)

        for searchResult in displayed {
            let item = searchItems[searchResult.index]
            switch item {
            case .eatery(let eatery):
                cells.append(.eatery(eatery))

            case .menuItem(let menuItem, _, let eatery):
                cells.append(.item(menuItem, eatery))
            }
        }

        tableView.reloadData()
    }

    func searchTextDidChange(_ searchText: String) {
        self.searchText = searchText
    }

}

extension HomeSearchContentModelController: EateryFilterViewControllerDelegate {

    func eateryFilterViewController(_ viewController: EateryFilterViewController, filterDidChange filter: EateryFilter) {
        self.filter = filter
    }

}
