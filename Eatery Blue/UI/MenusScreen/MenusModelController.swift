//
//  MenusModelController.swift
//  Eatery Blue
//
//  Created by Antoinette Marie Torres on 9/21/23.
//

import Combine
import EateryModel
import UIKit

protocol UpdateDateDelegate: AnyObject {
    
    func updateMenuDay(index: Int)

}

class MenusModelController: MenusViewController {
    
    private var isTesting = false
    private var isLoading = true
    
    private var filter = EateryFilter()
    private var allEateries: [Int: [Eatery]] = [:]
    private var fetchedEateries: [Eatery] = []
    
    private lazy var filterController = MenusFilterViewController(currentMealType: currentMealType)
    
    private lazy var loadCells: () = updateCellsFromState()
    
    private var selectedDay: Day = Day()
    private var selectedIndex: Int = 0
    private var currentMealType: String = String.Eatery.mealFromTime()

    class MenuChoice {

        let description: String
        let event: Event

        init(description: String, event: Event) {
            self.description = description
            self.event = event
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isUserInteractionEnabled = false
        updateDateDelegate = self
        
        setUpNavigationView()
        setUpFilterController()
        
        setDays()
        
        Task {
            await updateEateriesFromNetworking()
            updateCellsFromState()
            view.isUserInteractionEnabled = !isLoading
        }
    }
    
    private func setDays() {
        days = []
        for i in 0...6 {
            days.append(Day().advanced(by: i))
        }
        
        // If the day changed on refresh, update the selected day
        if days[selectedIndex] != selectedDay {
            selectedDay = selectedDay.advanced(by: 1)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let _ = loadCells
    }
    
    private func setUpFilterController() {
        addChild(filterController)
        
        filter.north = false
        filter.west = false
        filter.central = false

        filterController.view.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        filterController.delegate = self
        filterController.didMove(toParent: self)
    }
    
    private func updateEateriesFromNetworking() async {
        let cachedEateries = allEateries[selectedIndex] ?? []

        if cachedEateries.isEmpty {
            isLoading = true
            view.isUserInteractionEnabled = false
            updateCellsFromState()

            do {
                let eateries = isTesting ? DummyData.eateries : try await Networking.default.loadEateryByDay(day: selectedIndex)
                allEateries[selectedIndex] = eateries

                fetchedEateries = eateries.filter { eatery in
                    return !eatery.name.isEmpty
                }.sorted(by: { lhs, rhs in
                    lhs.name < rhs.name
                })
            } catch {
                logger.error("\(error)")
            }

            isLoading = false
            view.isUserInteractionEnabled = true
        } else {
            fetchedEateries = cachedEateries.filter { eatery in
                return !eatery.name.isEmpty
            }.sorted(by: { lhs, rhs in
                lhs.name < rhs.name
            })
        }
    }
    
    private func setUpNavigationView() {
        navigationView.logoRefreshControl.addTarget(self, action: #selector(didRefresh), for: .valueChanged)
    }
    
    @objc private func didRefresh(_ sender: LogoRefreshControl) {
        Task {
            await withTaskGroup(of: Void.self) { [weak self] group in
                guard let strongSelf = self else { return }
                group.addTask {
                    await strongSelf.updateEateriesFromNetworking()
                }
                // Create a task to let the logo view do one complete animation cycle
                group.addTask {
                    try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                }
            }
            
            setDays()

            updateCellsFromState()
            sender.endRefreshing()
        }
    }
    
    private func updateCellsFromState() {
        let coreDataStack = AppDelegate.shared.coreDataStack
        var cells: [Cell] = []
        var eateryStartIndex: Int = 0
        var currentEateries: [Eatery] = []

        cells.append(.dayPicker)
        cells.append(.customView(view: filterController.view))
        
        if isLoading {
            cells.append(.loadingLabel(title: "Best in the biz since 2014..."))
            for _ in 0...5 {
                cells.append(.loadingCard)
            }
        } else {
            let predicate = filter.predicate(userLocation: LocationManager.shared.userLocation, departureDate: Date())
            var filteredEateries = fetchedEateries.filter {
                predicate.isSatisfied(by: $0, metadata: coreDataStack.metadata(eateryId: $0.id))
            }

            // Only display eateries based on selected meal type

            // TODO: This should be an enum but good for now
            filteredEateries = filteredEateries.filter { eatery in
                let events = eatery.events.filter { $0.canonicalDay == selectedDay }

                // Ignore Late Lunch
                if currentMealType == "Breakfast" {
                    return events.contains { $0.description == "Brunch" || $0.description == "Breakfast" }
                } else if currentMealType == "Lunch" {
                    return events.contains { $0.description == "Brunch" || $0.description == "Lunch" }
                } else if currentMealType == "Dinner" {
                    return events.contains { $0.description == "Dinner" }
                } else if currentMealType == "Late Dinner" {
                    return events.contains { $0.description == "Late Night" }
                }

                return false
            }

            currentEateries = filteredEateries
            eateryStartIndex = cells.count
            
            if filter.north || !filter.central && !filter.west && !filter.north {
                var didAppendNorthLabel: Bool = false
                currentEateries.forEach { eatery in
                    if eatery.campusArea == "North" && eatery.paymentMethods.contains(.mealSwipes) {
                        !didAppendNorthLabel ? cells.append(.titleLabel(title: "North")) : nil
                        didAppendNorthLabel = true
                        cells.append(.expandableCard(expandedEatery: ExpandedEatery(eatery: eatery, selectedMealType: currentMealType, selectedDate: selectedDay)))
                    }
                }
            }
            
            if filter.west || !filter.central && !filter.west && !filter.north {
                var didAppendWestLabel: Bool = false
                currentEateries.forEach { eatery in
                    !didAppendWestLabel ? cells.append(.titleLabel(title: "West")) : nil
                    didAppendWestLabel = true
                    if eatery.campusArea == "West" && eatery.paymentMethods.contains(.mealSwipes) {
                        cells.append(.expandableCard(expandedEatery: ExpandedEatery(eatery: eatery, selectedMealType: currentMealType, selectedDate: selectedDay)))
                    }
                }
            }

            if filter.central || !filter.central && !filter.west && !filter.north {
                var didAppendCentralLabel: Bool = false
                currentEateries.forEach { eatery in
                    if eatery.campusArea == "Central" && eatery.paymentMethods.contains(.mealSwipes) {
                        !didAppendCentralLabel ? cells.append(.titleLabel(title: "Central")) : nil
                        didAppendCentralLabel = true
                        cells.append(.expandableCard(expandedEatery: ExpandedEatery(eatery: eatery, selectedMealType: currentMealType, selectedDate: selectedDay)))
                    }
                }
            }
            
            if filteredEateries.isEmpty {
                cells.append(.titleLabel(title: "No eateries found..."))
            }
        }
        
        updateCells(cells: cells, allEateries: currentEateries, eateryStartIndex: eateryStartIndex)
    }
    
    private func pushListViewController(title: String, description: String?, eateries: [Eatery]) {
        let viewController = ListModelController()
        viewController.setUp(eateries, title: title, description: description)

        navigationController?.hero.isEnabled = false
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}

extension MenusModelController: MenusFilterViewControllerDelegate {
    
    func menusFilterViewController(_ viewController: MenusFilterViewController, didChangeMenuType string: String) {
        currentMealType = string
        updateCellsFromState()
        
        if currentMealType == "Breakfast" {
            filterController.selectedMenuIndex = 0
        } else if currentMealType == "Lunch" {
            filterController.selectedMenuIndex = 1
        } else if currentMealType == "Dinner" {
            filterController.selectedMenuIndex = 2
        } else if currentMealType == "Late Dinner" {
            filterController.selectedMenuIndex = 3
        }
    }

    func menusFilterViewController(_ viewController: MenusFilterViewController, didChangeLocation filter: EateryFilter) {
        self.filter = filter
        updateCellsFromState()
    }
    
}

extension MenusModelController: UpdateDateDelegate {
    
    func updateMenuDay(index: Int) {
        selectedDay = days[index]
        selectedIndex = index

        Task {
            await updateEateriesFromNetworking()
            updateCellsFromState()
        }
    }
    
}
