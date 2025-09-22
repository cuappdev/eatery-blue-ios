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
        listEateries = eateries
        updateEateriesFromState()
    }

    func updateEateriesFromState() {
        if filter.isEnabled {
            let predicate = filter.predicate(userLocation: LocationManager.shared.userLocation, departureDate: Date())
            let coreDataStack = AppDelegate.shared.coreDataStack

            let filteredEateries = listEateries.filter {
                predicate.isSatisfied(by: $0, metadata: coreDataStack.metadata(eateryId: $0.id))
            }

            updateEateries(eateries: filteredEateries)
        } else {
            updateEateries(eateries: listEateries)
        }
    }
}

extension ListModelController: EateryFilterViewControllerDelegate {
    func eateryFilterViewController(_: EateryFilterViewController, filterDidChange filter: EateryFilter) {
        self.filter = filter
        updateEateriesFromState()
    }
}
