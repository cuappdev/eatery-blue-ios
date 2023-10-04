//
//  MenusModelController.swift
//  Eatery Blue
//
//  Created by Antoinette Marie Torres on 9/21/23.
//

import Combine
import EateryModel
import UIKit
import CoreLocation

class MenusModelController: MenusViewController {
    
    private var isTesting = true
    private var isLoading = true
    
    private var filter = EateryFilter()
    private var allEateries: [Eatery] = []
    
    private let filterController = MenusFilterViewController()
        
    private lazy var loadCells: () = updateCellsFromState()
    
    private var currentMealType = "Breakfast"
    
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
        filterController.view.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        filterController.delegate = self
        filterController.didMove(toParent: self)
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
            
            // TODO: Do filtering for eateries's menus here instead. Reference EateryExpandableCardDetailView's configure function for how to do it.
            
            eateryStartIndex = cells.count
            
            cells.append(.titleLabel(title: "North"))
            currentEateries.forEach { eatery in
                if eatery.campusArea == "North" && eatery.paymentMethods.contains(.mealSwipes) {
                    cells.append(.expandableCard(expandedEatery: ExpandedEatery(eatery: eatery)))
                }
            }
            
            cells.append(.titleLabel(title: "West"))
            currentEateries.forEach { eatery in
                if eatery.campusArea == "West" && eatery.paymentMethods.contains(.mealSwipes) {
                    cells.append(.expandableCard(expandedEatery: ExpandedEatery(eatery: eatery)))
                }
            }

            cells.append(.titleLabel(title: "Central"))
            currentEateries.forEach { eatery in
                if eatery.campusArea == "Central" && eatery.paymentMethods.contains(.mealSwipes) {
                    cells.append(.expandableCard(expandedEatery: ExpandedEatery(eatery: eatery)))
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

    func menusFilterViewController(_ viewController: MenusFilterViewController, filterDidChange filter: EateryFilter) {
        self.filter = filter
        updateCellsFromState()
    }
    
    func filterMenusByMealType(mealType: String) {
        self.currentMealType = mealType
        updateCellsFromState()
    }
    
}
