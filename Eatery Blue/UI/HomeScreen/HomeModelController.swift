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
    private var allEateries: [Eatery] = []

    private let filterController = EateryFilterViewController()

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpFilterController()
        setUpNavigationView()
        setUpUserLocationSubscription()

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

    private func setUpUserLocationSubscription() {
        // Update cells when the user location changes because we may need to display the "Nearest to You" carousel
        LocationManager.shared.userLocationDidChange.sink { [self] _ in
            updateCellsFromState()
        }.store(in: &cancellables)
    }

    private func updateAllEateriesFromNetworking() async {
        do {
            let eateries = isTesting ? DummyData.eateries : try await Networking.default.eateries.fetch(maxStaleness: 0)
            allEateries = eateries.filter { eatery in
                return !eatery.name.isEmpty
            }.sorted(by: { lhs, rhs in
                lhs.name < rhs.name
            })

        } catch {
            logger.error("\(error)")
        }
        isLoading = false
    }
    
    //MARK: - Just added...need to figure out where to place so allEateries is not empty
    func pushViewController(for eatery: Eatery) {
        print("pushing!")
        print(allEateries)
        let pageVC = EateryPageViewController(eateries: allEateries, index: 0)
        navigationController?.hero.isEnabled = false
        navigationController?.pushViewController(pageVC, animated: true)
    }
    
    private func createLoadingCarouselView(
        title: String,
        numEateries: Int
    ) -> CarouselView {
        
        let carouselView = CarouselView()
        carouselView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        carouselView.titleLabel.text = title
        carouselView.titleLabel.textColor = UIColor.Eatery.gray02
        
        for _ in 0...2 {
            let contentView = EateryMediumLoadingCardView()
            carouselView.addCardView(contentView)
        }
        
        return carouselView
    }

    private func createCarouselView(
        title: String,
        description: String?,
        carouselEateries: [Eatery],
        listEateries: [Eatery]
    ) -> CarouselView {

        let carouselView = CarouselView()
        carouselView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        carouselView.titleLabel.text = title

        for i in 0...2 {
            let eatery = carouselEateries[i]
            let contentView = EateryMediumCardContentView()
            contentView.imageView.kf.setImage(
                with: eatery.imageUrl,
                options: [.backgroundDecode]
            )
            contentView.imageTintView.alpha = eatery.isOpen ? 0 : 0.5
            contentView.titleLabel.text = eatery.name

            let metadata = AppDelegate.shared.coreDataStack.metadata(eateryId: eatery.id)
            if metadata.isFavorite {
                contentView.favoriteImageView.image = UIImage(named: "FavoriteSelected")
            } else {
                contentView.favoriteImageView.image = UIImage(named: "FavoriteUnselected")
            }

            LocationManager.shared.$userLocation
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

            let now = Date()
            switch eatery.status {
            case .closingSoon(let event):
                let alert = EateryCardAlertView()
                let minutesUntilClosed = Int(round(event.endDate.timeIntervalSince(now) / 60))
                alert.titleLabel.text = "Closing in \(minutesUntilClosed) min"
                contentView.addAlertView(alert)

            case .openingSoon(let event):
                let alert = EateryCardAlertView()
                let minutesUntilOpen = Int(round(event.startDate.timeIntervalSince(now) / 60))
                alert.titleLabel.text = "Opening in \(minutesUntilOpen) min"
                contentView.addAlertView(alert)

            default:
                break
            }

            carouselView.addCardView(contentView, buttonPress: { [self] _ in
                navigationController?.hero.isEnabled = false
                let pageVC = EateryPageViewController(eateries: carouselEateries, index: i)
                pageVC.modalPresentationStyle = .overCurrentContext
                navigationController?.pushViewController(pageVC, animated: true)
            })
        }

        if carouselEateries.count > 3 {
            let view = CarouselMoreEateriesView()
            view.tap { [self] _ in
                pushListViewController(title: title, description: description, eateries: listEateries)
            }
            carouselView.addAccessoryView(EateryCardVisualEffectView(content: view))
        }

        carouselView.buttonImageView.tap { [self] _ in
            pushListViewController(title: title, description: description, eateries: listEateries)
        }

        return carouselView
    }

    private func updateCellsFromState() {
        let coreDataStack = AppDelegate.shared.coreDataStack
        var cells: [Cell] = []
        
        cells.append(.searchBar)
        cells.append(.customView(view: filterController.view))
        
        if isLoading {
            cells.append(.loadingView(createLoadingCarouselView(title: "Finding flavorful food...", numEateries: 40)))
            cells.append(.loadingLabel(title: "Checking for chow..."))
            for _ in 0...10 {
                cells.append(.loadingCard)
            }
        } else {
            if !filter.isEnabled {
                if let carouselView = createFavoriteEateriesCarouselView() {
                    cells.append(.carouselView(carouselView))
                }
                if let carouselView = createNearestEateriesCarouselView() {
                    cells.append(.carouselView(carouselView))
                }
                
                if !allEateries.isEmpty {
                    cells.append(.titleLabel(title: "All Eateries"))
                }
                
                for eatery in allEateries {
                    cells.append(.eateryCard(eatery: eatery))
                }
                
            } else {
                let predicate = filter.predicate(userLocation: LocationManager.shared.userLocation, departureDate: Date())
                let filteredEateries = allEateries.filter({
                    predicate.isSatisfied(by: $0, metadata: coreDataStack.metadata(eateryId: $0.id))
                })
                for eatery in filteredEateries {
                    cells.append(.eateryCard(eatery: eatery))
                }
            }
        }
        updateCells(cells)
    }

    private func createFavoriteEateriesCarouselView() -> CarouselView? {
        let favoriteEateries = allEateries.filter {
            AppDelegate.shared.coreDataStack.metadata(eateryId: $0.id).isFavorite
        }

        guard !favoriteEateries.isEmpty else {
            return nil
        }

        let carouselEateries = favoriteEateries.sorted { lhs, rhs in
            if lhs.isOpen == rhs.isOpen {
                return lhs.name < rhs.name
            } else {
                return lhs.isOpen && !rhs.isOpen
            }
        }

        return createCarouselView(
            title: "Favorites",
            description: nil,
            carouselEateries: Array(carouselEateries),
            listEateries: favoriteEateries
        )
    }

    private func createNearestEateriesCarouselView() -> CarouselView? {
        let userLocation = LocationManager.shared.userLocation
        let departureDate = Date()

        let nearestEateriesAndTotalTime: [(eatery: Eatery, totalTime: TimeInterval)] = allEateries.compactMap {
            if let totalTime = $0.expectedTotalTime(userLocation: userLocation, departureDate: departureDate) {
                return (eatery: $0, totalTime: totalTime)
            } else {
                return nil
            }
        }

        guard !nearestEateriesAndTotalTime.isEmpty else {
            return nil
        }

        let carouselEateries = nearestEateriesAndTotalTime.sorted { lhs, rhs in
            if lhs.eatery.isOpen == rhs.eatery.isOpen {
                return lhs.totalTime < rhs.totalTime
            } else {
                return lhs.eatery.isOpen && !rhs.eatery.isOpen
            }
        }.map(\.eatery)

        let listEateries = nearestEateriesAndTotalTime.sorted { lhs, rhs in
            lhs.totalTime < rhs.totalTime
        }.map(\.eatery)

        return createCarouselView(
            title: "Nearest to You",
            description: nil,
            carouselEateries: carouselEateries,
            listEateries: listEateries
        )
    }

    @objc private func didRefresh(_ sender: LogoRefreshControl) {
        LocationManager.shared.requestLocation()

        Task {
            await withTaskGroup(of: Void.self) { [weak self] group in
                guard let strongSelf = self else { return }
                group.addTask {
                    await strongSelf.updateAllEateriesFromNetworking()
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
