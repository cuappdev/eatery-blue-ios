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
        case menuItem(MenuItem, Eatery)

        var properties: [FuseProperty] {
            switch self {
            case .eatery(let eatery):
                return [
                    FuseProperty(name: eatery.name, weight: 1),
                    FuseProperty(name: eatery.building ?? "", weight: eatery.building != nil ? 0.3 : 0),
                    FuseProperty(name: eatery.menuSummary ?? "", weight: eatery.menuSummary != nil ? 0.5 : 0)
                ]

            case .menuItem(let item, _):
                return [
                    FuseProperty(name: item.name, weight: 1),
                    FuseProperty(name: item.description ?? "", weight: item.description != nil ? 0.5 : 0)
                ]
            }
        }

    }

    private var searchItems: [SearchItem] = []

    private var searchText = CurrentValueSubject<String, Never>("")
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpSearchTextSubscription()
    }

    private func setUpSearchTextSubscription() {
        // Assuming that users type at about 50 wpm
        // 50 wpm * (5 cpm / wpm) * (1 min / 60 s) = 4.17 characters per second
        // Debounce interval should be 1 / 4.17 ~= 0.25 seconds per character

        searchText
            .debounce(for: 0.25, scheduler: DispatchQueue.main, options: nil)
            .filter({ searchText in
                3 <= searchText.count && searchText.count <= 30
            })
            .flatMap({ [self] searchText -> AnyPublisher<([SearchItem], [Fuse.FusableSearchResult]), Never> in
                // Pass along the search items at the time the search is started in case the search items change
                // mid-search
                let searchItems = self.searchItems

                return Fuse(threshold: 0.4).searchPublisher(searchText, in: searchItems).map { results in
                    (searchItems, results)
                }.eraseToAnyPublisher()
            })
            .sink { [self] result in
                updateCells(searchItems: result.0, searchResults: result.1)
            }
            .store(in: &cancellables)
    }

    func setUp(_ eateries: [Eatery]) {
        searchItems = []

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

                let allItems = menu.categories.flatMap({ $0.items })
                for item in allItems {
                    guard item.isSearchable else {
                        continue
                    }

                    searchItems.append(.menuItem(item, eatery))
                }
            }
        }
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

            case .menuItem(let menuItem, let eatery):
                cells.append(.item(menuItem, eatery))
            }
        }

        tableView.reloadData()
    }

    func searchTextDidChange(_ searchText: String) {
        self.searchText.value = searchText
    }

}
