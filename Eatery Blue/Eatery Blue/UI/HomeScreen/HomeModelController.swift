//
//  HomeModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/29/21.
//

import Combine
import EateryModel
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
    private var allEateries: [Eatery] = []

    private let filterController = EateryFilterViewController()

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpFilterController()
        setUpNavigationView()

        Task {
            await updateAllEateriesFromNetworking()
            updateCellsFromState()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateCellsFromState()

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

    private func updateAllEateriesFromNetworking() async {
        do {
            let eateries = try await Networking.default.eateries.fetch(maxStaleness: 0)
            allEateries = eateries.sorted(by: { lhs, rhs in
                lhs.name < rhs.name
            })

        } catch {
            logger.error("\(error)")
        }
    }

    private func filterFavoriteEateries() -> [Eatery] {
        allEateries.filter({
            AppDelegate.shared.coreDataStack.metadata(eateryId: $0.id).isFavorite
        })
    }

    private func createCarouselView(title: String, description: String?, eateries: [Eatery]) -> CarouselView {
        let carouselView = CarouselView()
        carouselView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        carouselView.scrollView.contentInset = carouselView.layoutMargins
        carouselView.titleLabel.text = title

        let carouselEateries = eateries.sorted { lhs, rhs in
            if EateryStatus(lhs.events).isOpen, !EateryStatus(rhs.events).isOpen {
                return true
            } else {
                return lhs.name < rhs.name
            }
        }

        for eatery in carouselEateries.prefix(3) {
            let contentView = EateryMediumCardContentView()
            contentView.imageView.kf.setImage(
                with: eatery.imageUrl,
                options: [.backgroundDecode]
            )
            contentView.imageTintView.alpha = EateryStatus(eatery.events).isOpen ? 0 : 0.5
            contentView.titleLabel.text = eatery.name

            let metadata = AppDelegate.shared.coreDataStack.metadata(eateryId: eatery.id)
            if metadata.isFavorite {
                contentView.favoriteImageView.image = UIImage(named: "FavoriteSelected")
            } else {
                contentView.favoriteImageView.image = UIImage(named: "FavoriteUnselected")
            }

            $userLocation
                .sink { userLocation in
                    contentView.subtitleLabel.attributedText = EateryFormatter.default.formatEatery(
                        eatery,
                        style: .medium,
                        font: .preferredFont(for: .footnote, weight: .medium),
                        userLocation: userLocation,
                        date: Date()
                    ).first
                }
                .store(in: &cancellables)

            contentView.on(UITapGestureRecognizer()) { [self] _ in
                pushViewController(for: eatery)
            }

            carouselView.addCardView(contentView)
        }

        if carouselEateries.count > 3 {
            let view = CarouselMoreEateriesView()
            view.on(UITapGestureRecognizer()) { [self] _ in
                pushListViewController(title: title, description: description, eateries: eateries)
            }
            carouselView.addAccessoryView(view)
        }

        carouselView.buttonImageView.on(UITapGestureRecognizer()) { [self] _ in
            pushListViewController(title: title, description: description, eateries: eateries)
        }

        return carouselView
    }

    /// Update cells based on
    /// - Eatery metadata in core data
    /// - Filter
    /// - All eateries
    private func updateCellsFromState() {
        let coreDataStack = AppDelegate.shared.coreDataStack
        var cells: [Cell] = []

        cells.append(.searchBar)
        cells.append(.customView(view: filterController.view))

        if !filter.isEnabled {
            let favoriteEateries = filterFavoriteEateries()
            if !favoriteEateries.isEmpty {
                cells.append(.carouselView(createCarouselView(
                    title: "Favorites",
                    description: nil,
                    eateries: favoriteEateries
                )))
            }

            if !allEateries.isEmpty {
                cells.append(.titleLabel(title: "All Eateries"))
            }

            for eatery in allEateries {
                cells.append(.eateryCard(eatery: eatery))
            }

        } else {
            let predicate = filter.predicate(userLocation: LocationManager.shared.userLocation)
            let filteredEateries = allEateries.filter({
                predicate.isSatisfied(by: $0, metadata: coreDataStack.metadata(eateryId: $0.id))
            })
            for eatery in filteredEateries {
                cells.append(.eateryCard(eatery: eatery))
            }
        }

        updateCells(cells)
    }

    @objc private func didRefresh(_ sender: LogoRefreshControl) {
        Task {
            await updateAllEateriesFromNetworking()
            try? await Task.sleep(nanoseconds: 200_000_000)
            updateCellsFromState()
            sender.endRefreshing()
        }
    }

    private func pushListViewController(title: String, description: String?, eateries: [Eatery]) {
        let viewController = ListModelController()
        viewController.setUp(eateries, title: title, description: description)

        navigationController?.hero.isEnabled = false
        navigationController?.pushViewController(viewController, animated: true)
    }

}

extension HomeModelController: EateryFilterViewControllerDelegate {

    func eateryFilterViewController(_ viewController: EateryFilterViewController, filterDidChange filter: EateryFilter) {
        self.filter = filter
        updateCellsFromState()
    }

}
