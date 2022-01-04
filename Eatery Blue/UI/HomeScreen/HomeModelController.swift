//
//  HomeModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/29/21.
//

import Combine
import UIKit

class HomeModelController: HomeViewController {

    private struct FilterButtons {
        let under10Minutes = PillFilterButtonView()
        let paymentMethods = PillFilterButtonView()
        let favorites = PillFilterButtonView()
        let north = PillFilterButtonView()
        let west = PillFilterButtonView()
        let central = PillFilterButtonView()
    }

    private var filter = EateryFilter()
    private var eateryCollections: [EateryCollection] = []
    private var allEateries: [Eatery] = []

    private let filterController = EateryFilterViewController()

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpFilterController()
        setUpNavigationView()

        updateStateFromNetworking() { [self] in
            updateCellsFromState()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        LocationManager.shared.requestAuthorization()
        LocationManager.shared.requestLocation()
        LocationManager.shared.$userLocation.assign(to: &$userLocation)
    }

    private func setUpFilterController() {
        addChild(filterController)
        filterController.view.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        filterController.delegate = self
        filterController.didMove(toParent: self)
    }

    private func setUpNavigationView() {
        navigationView.searchButton.on(UITapGestureRecognizer()) { [self] _ in
            let searchViewController = HomeSearchModelController()
            navigationController?.hero.isEnabled = false
            navigationController?.pushViewController(searchViewController, animated: true)
        }

        navigationView.logoRefreshControl.addTarget(self, action: #selector(didRefresh), for: .valueChanged)
    }

    private func updateStateFromNetworking(_ completion: (() -> Void)? = nil) {
        Networking.default.fetchEateries().sink { subscriptionCompletion in
            switch subscriptionCompletion {
            case .failure(let error):
                logger.error("\(error)")

            case .finished:
                break
            }

            completion?()

        } receiveValue: { [self] eateries in
            eateryCollections = [
                EateryCollection(
                    title: "Debug",
                    description: nil,
                    eateries: [
                        eateries.first(where: { $0.name.starts(with: "Mac's") })!,
                        eateries.first(where: { $0.name.starts(with: "Terrace") })!
                    ]
                ),
                EateryCollection(
                    title: "Favorite Eateries",
                    description: nil,
                    eateries: [
                        DummyData.rpcc, DummyData.macsOpen, DummyData.macsOpenSoon
                    ]
                ),
                EateryCollection(
                    title: "Lunch on the Go",
                    description: "Grab a quick bite on the way to (skipping) your classes",
                    eateries: [
                        DummyData.macsClosed, DummyData.macsClosingSoon
                    ]
                ),
            ]

            allEateries = eateries.sorted(by: { lhs, rhs in
                lhs.name < rhs.name
            })
        }.store(in: &cancellables)
    }

    private func updateCellsFromState() {
        cells = []

        cells.append(.searchBar)

        cells.append(.customView(view: filterController.view))

        if !filter.isEnabled {
            for collection in eateryCollections {
                cells.append(.carouselView(collection: collection))
            }

            if !allEateries.isEmpty {
                cells.append(.titleLabel(title: "All Eateries"))
            }

            for eatery in allEateries {
                cells.append(.eateryCard(eatery: eatery))
            }

        } else {
            let predicate = filter.predicate(userLocation: LocationManager.shared.userLocation)
            let filteredEateries = allEateries.filter(predicate.isSatisfiedBy(_:))
            for eatery in filteredEateries {
                cells.append(.eateryCard(eatery: eatery))
            }
        }

        tableView.reloadData()
    }

    @objc private func didRefresh(_ sender: LogoRefreshControl) {
        updateStateFromNetworking { [self] in
            updateCellsFromState()
            sender.endRefreshing()
        }
    }

}

extension HomeModelController: EateryFilterViewControllerDelegate {

    func eateryFilterViewController(_ viewController: EateryFilterViewController, filterDidChange filter: EateryFilter) {
        self.filter = filter
        updateCellsFromState()
    }

}

extension HomeModelController {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let viewController = HomeSearchModelController()
        navigationController?.hero.isEnabled = true
        navigationController?.hero.navigationAnimationType = .fade
        navigationController?.pushViewController(viewController, animated: true)
        return false
    }

}

