//
//  HomeModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/29/21.
//

import Combine
import EateryModel
import UIKit
import CoreLocation

class HomeModelController: HomeViewController {
    
    private var isTesting = false
    private var isLoading = true

    private var filter = EateryFilter()

    private let filterController = EateryFilterViewController()

    private var cancellables: Set<AnyCancellable> = []

    private lazy var loadCells: () = updateCellsFromState()
    
    private var favoritesCarousel = CarouselView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.isUserInteractionEnabled = false

        setUpFilterController()
        setUpNavigationView()
        setUpUserLocationSubscription()
        setUpFavNotification()

        Task {
            await withThrowingTaskGroup(of: Void.self) { [weak self] group in
                guard let self = self else { return }
                
                group.addTask {
                    await self.updateSimpleEateriesFromNetworking()
                    await self.updateCellsFromState()
                    await self.animateCellLoading()
                }
                
                group.addTask {
                    // Don't update cells. Used for caching purposes.
                    await self.updateAllEateriesFromNetworking()
                }
            }
            setUpCompareMenusButton()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let _ = loadCells

        LocationManager.shared.requestAuthorization()
        LocationManager.shared.requestLocation()
    }

    private func trySetCompareMenusUpOnboarding() {
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.didExternallyOnboardCompareMenus) { return }

        compareMenusOnboarding.layer.opacity = 0.01
        navigationController?.tabBarController?.parent?.view.addSubview(compareMenusOnboarding)
        compareMenusOnboarding.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self else { return }
            compareMenusOnboarding.layer.opacity = 1
        }

        compareMenusOnboarding.compareMenusButton.tap { [weak self] _ in
            guard let self else { return }
            
            compareMenusOnboarding.dismiss()
            let viewController = CompareMenusSheetViewController(parentNavigationController: navigationController, allEateries: allEateries, selectedEateries: [])
            viewController.setUpSheetPresentation()
            tabBarController?.present(viewController, animated: true)
        }
    }

    private func setUpFilterController() {
        addChild(filterController)
        filterController.view.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        filterController.delegate = self
        filterController.didMove(toParent: self)
    }

    private func setUpNavigationView() {
        navigationView.searchButton.tap { [self] _ in
            let searchViewController = HomeSearchModelController()
            navigationController?.hero.isEnabled = false
            navigationController?.pushViewController(searchViewController, animated: true)
        }

        navigationView.logoRefreshControl.addTarget(self, action: #selector(didRefresh), for: .valueChanged)
    }
    
    private func setUpFavNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshFavorites(_:)),
            name: NSNotification.Name("favoriteEatery"),
            object: nil
        )
    }

    private func setUpCompareMenusButton() {
        compareMenusButton.buttonPress { [weak self] _ in
            guard let self else { return }

            let viewController = CompareMenusSheetViewController(parentNavigationController: navigationController, allEateries: allEateries, selectedEateries: [])
            viewController.setUpSheetPresentation()
            tabBarController?.present(viewController, animated: true)
            AppDevAnalytics.shared.logFirebase(CompareMenusButtonPressPayload(entryPage: "HomeModelController"))
        }
    }

    private func setUpUserLocationSubscription() {
        // Update cells when the user location changes because we may need to display the "Nearest to You" carousel
        LocationManager.shared.userLocationDidChange.sink { [self] _ in
            updateCellsFromState()
        }.store(in: &cancellables)
    }
    
    private func updateSimpleEateriesFromNetworking() async {
        do {
            let eateries = isTesting ? DummyData.eateries : try await Networking.default.loadSimpleEateries()
            trySetCompareMenusUpOnboarding()
            if isLoading {
                allEateries = eateries.filter { eatery in
                    return !eatery.name.isEmpty
                }.sorted(by: {
                    return $0.isOpen == $1.isOpen ? $0.name < $1.name : $0.isOpen
                })
            }
        } catch {
            logger.error("\(error)")
        }
        
        isLoading = false
        view.isUserInteractionEnabled = true
    }
    
    private func updateAllEateriesFromNetworking() async {
        do {
            let _ = isTesting ? DummyData.eateries : try await Networking.default.loadAllEatery()
        } catch {
            logger.error("\(error)")
        }
    }
    
    private func updateCellsFromState() {
        let coreDataStack = AppDelegate.shared.coreDataStack
        var cells: [Cell] = []
        var currentEateries: [Eatery] = []

        cells.append(.searchBar)
        cells.append(.customView(view: filterController.view))

        if isLoading {
            cells.append(.loadingLabel(title: "Finding flavorful food..."))
            cells.append(.loadingCard(isLarge: false))

            cells.append(.loadingLabel(title: "Checking for chow..."))
            for _ in 0...4 {
                cells.append(.loadingCard(isLarge: true))
            }
        } else {
            if !filter.isEnabled {
                if let carouselView = createFavoriteEateriesCarouselView() {
                    cells.append(.carouselView(carouselView))
                }
             
                currentEateries = allEateries
            } else {
                let predicate = filter.predicate(userLocation: LocationManager.shared.userLocation, departureDate: Date())
                let filteredEateries = allEateries.filter{
                    predicate.isSatisfied(by: $0, metadata: coreDataStack.metadata(eateryId: $0.id))
                }
                currentEateries = filteredEateries
                
                if filteredEateries.isEmpty {
                    cells.append(.titleLabel(title: "No eateries found..."))
                }
            }
        }
        
        
        LocationManager.shared.$userLocation
        .sink { userLocation in
                currentEateries = currentEateries.sorted(by: { eatery1, eatery2 in
                let dist1 = eatery1.walkTime(userLocation: userLocation)
                let dist2 = eatery2.walkTime(userLocation: userLocation)
                guard let dist1, let dist2 else { return true }
                    
                return dist1 < dist2
            })
        }
        .store(in: &cancellables)

        
        let openEateries = currentEateries.filter(\.isOpen)

        if !openEateries.isEmpty {
            cells.append(.statusLabel(status: .open))
            openEateries.forEach { eatery in
                cells.append(.eateryCard(eatery: eatery))
            }
        }
        
        let closedEateries = currentEateries.filter { !$0.isOpen }
        // sort
        if !closedEateries.isEmpty {
            cells.append(.statusLabel(status: .closed))
            closedEateries.forEach { eatery in
                cells.append(.eateryCard(eatery: eatery))
            }
        }
        
        updateCells(cells: cells, allEateries: currentEateries)
    }

    private func createFavoriteEateriesCarouselView() -> CarouselView? {
        let favoriteEateries = allEateries.filter {
            AppDelegate.shared.coreDataStack.metadata(eateryId: $0.id).isFavorite
        }.sorted { lhs, rhs in
            if lhs.isOpen == rhs.isOpen {
                return lhs.name < rhs.name
            } else {
                return lhs.isOpen && !rhs.isOpen
            }
        }

        let favoritesViewController = FavoritesViewController()
        favoritesCarousel.title = "Favorites"
        favoritesCarousel.carouselEateries = favoriteEateries
        favoritesCarousel.truncateAfter = 3
        favoritesCarousel.navigationController = navigationController
        favoritesCarousel.viewControllerToPush = favoritesViewController
        favoritesCarousel.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        return favoriteEateries.count == 0 ? nil : favoritesCarousel
    }


    @objc private func didRefresh(_ sender: LogoRefreshControl) {
        LocationManager.shared.requestLocation()

        Task {
            await withTaskGroup(of: Void.self) { [weak self] group in
                guard let strongSelf = self else { return }
                group.addTask {
                    await strongSelf.updateSimpleEateriesFromNetworking()
                }
                // Create a task to let the logo view do one complete animation cycle
                group.addTask {
                    try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                }
            }

            updateCellsFromState()
            sender.endRefreshing()
        }
    }

    private func pushListViewController(title: String, description: String?, eateries: [Eatery]) {
        let viewController = ListModelController()
        viewController.setUp(eateries, title: title, description: description, allEateries: allEateries)

        navigationController?.hero.isEnabled = false
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc func refreshFavorites(_ notification: Notification) {
        updateCellsFromState()
    }
}


extension HomeModelController: EateryFilterViewControllerDelegate {

    func eateryFilterViewController(_ viewController: EateryFilterViewController, filterDidChange filter: EateryFilter) {
        self.filter = filter
        updateCellsFromState()
    }

}
