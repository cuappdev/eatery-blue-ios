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
    
    func updateMenuDay(date: Day)
    
}

class MenusModelController: MenusViewController {
    
    private var isTesting = false
    private var isLoading = true
    
    private var filter = EateryFilter()
    private var allEateries: [Eatery] = []
    private var fetchedEateries: [Eatery] = []
    
    private lazy var filterController = MenusFilterViewController(currentMealType: currentMealType)
    
    private lazy var loadCells: () = updateCellsFromState()
    
    private var selectedDay: Day = Day()
    private var currentMealType: String = {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        if let hour : Int = Int(dateFormatter.string(from: date)) {
            dateFormatter.dateFormat = "mm"
            if let minute : Int = Int(dateFormatter.string(from: date)){
                if hour < 10 || hour == 10 && minute < 30 || hour >= 23 || hour == 22 && minute >= 30 {
                    return "Breakfast"
                } else if hour == 10 && minute >= 30 || 10 < hour && hour < 14 || hour == 14 && minute < 30 {
                    return "Lunch"
                } else if hour == 14 && minute >= 30 || 14 < hour && hour < 20 || hour == 20 && minute < 30 {
                    return "Dinner"
                } else {
                    return "Late Dinner"
                }
            } else {
                return "Breakfast"
            }
        } else {
            return "Breakfast"
        }
    }()
    
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
        
        setUpFilterController()
        
        Task {
            await updateAllEateriesFromNetworking()
            updateCellsFromState()
            view.isUserInteractionEnabled = !isLoading
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let _ = loadCells
    }
    
    private func setUpFilterController() {
        addChild(filterController)
        
        filter.north = true
        filter.west = true
        filter.central = true
        
        filterController.view.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        filterController.delegate = self
        filterController.didMove(toParent: self)
    }
    
    private func updateAllEateriesFromNetworking() async {
        do {
            // Fetch from cache within the last 100000 ms
            let eateries = isTesting ? DummyData.eateries : try await Networking.default.eateries.fetch(maxStaleness: 100000)
            fetchedEateries = eateries
            
            allEateries = eateries.filter { eatery in
                eatery.events.contains { $0.canonicalDay == Day() }
            }
            
            allEateries = allEateries.filter { eatery in
                return !eatery.name.isEmpty
            }.sorted(by: { lhs, rhs in
                lhs.name < rhs.name
            })
        } catch {
            logger.error("\(error)")
        }
        isLoading = false
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
            let filteredEateries = allEateries.filter {
                predicate.isSatisfied(by: $0, metadata: coreDataStack.metadata(eateryId: $0.id))
            }
            
            currentEateries = filteredEateries
            eateryStartIndex = cells.count
            
            if filter.north {
                var didAppendNorthLabel: Bool = false
                currentEateries.forEach { eatery in
                    if eatery.campusArea == "North" && eatery.paymentMethods.contains(.mealSwipes) {
                        !didAppendNorthLabel ? cells.append(.titleLabel(title: "North")) : nil
                        didAppendNorthLabel = true
                        cells.append(.expandableCard(expandedEatery: ExpandedEatery(eatery: eatery, selectedMealType: currentMealType, selectedDate: selectedDay)))
                    }
                }
            }
            
            if filter.west {
                var didAppendWestLabel: Bool = false
                currentEateries.forEach { eatery in
                    !didAppendWestLabel ? cells.append(.titleLabel(title: "West")) : nil
                    didAppendWestLabel = true
                    if eatery.campusArea == "West" && eatery.paymentMethods.contains(.mealSwipes) {
                        cells.append(.expandableCard(expandedEatery: ExpandedEatery(eatery: eatery, selectedMealType: currentMealType, selectedDate: selectedDay)))
                    }
                }
            }

            if filter.central {
                var didAppendCentralLabel: Bool = false
                currentEateries.forEach { eatery in
                    if eatery.campusArea == "Central" && eatery.paymentMethods.contains(.mealSwipes) {
                        !didAppendCentralLabel ? cells.append(.titleLabel(title: "Central")) : nil
                        didAppendCentralLabel = true
                        cells.append(.expandableCard(expandedEatery: ExpandedEatery(eatery: eatery, selectedMealType: currentMealType, selectedDate: selectedDay)))
                    }
                }
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
    
    func updateMenuDay(date: Day) {
        allEateries = fetchedEateries.filter { eatery in
            eatery.events.contains { $0.canonicalDay == date }
        }
        
        selectedDay = date
        updateCellsFromState()
    }
    
}
