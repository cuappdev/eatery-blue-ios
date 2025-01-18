//
//  ListModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/31/21.
//

import CoreData
import EateryModel
import Foundation

class ListModelController: ListViewController {

    private var filter = EateryFilter()
    private var listEateries: [Eatery] = []

    func setUp(
        _ eateries: [Eatery],
        title: String? = nil,
        description: String? = nil
    ) {
        filterController.delegate = self
        filterController.setFilter(filter, animated: false)

        super.setUp(title: title, description: description)
        self.listEateries = eateries
        updateEateriesFromState()
    }

    func updateEateriesFromState() {
        if filter.isEnabled {
            let predicate = filter.predicate(userLocation: LocationManager.shared.userLocation, departureDate: Date())
            let coreDataStack = AppDelegate.shared.coreDataStack

            var filteredEateries: [Eatery] = []
            for eatery in listEateries {
                if predicate.isSatisfied(by: eatery, metadata: coreDataStack.metadata(eateryId: eatery.id)) {
                    filteredEateries.append(eatery)
                }
            }

            updateEateries(eateries: filteredEateries)
        } else {
            updateEateries(eateries: listEateries)
        }
    }

}

extension ListModelController: EateryFilterViewControllerDelegate {

    func eateryFilterViewController(_ viewController: EateryFilterViewController, filterDidChange filter: EateryFilter) {
        self.filter = filter
        updateEateriesFromState()
    }

}
