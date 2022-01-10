//
//  ListModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/31/21.
//

import Foundation

class ListModelController: ListViewController {

    private var filter = EateryFilter()

    private var allEateries: [Eatery] = []

    func setUp(
        _ eateries: [Eatery],
        title: String? = nil,
        description: String? = nil
    ) {
        filterController.delegate = self
        filterController.setFilter(filter)

        super.setUp(title: title, description: description)
        self.allEateries = eateries

        updateEateriesFromState()
    }

    func updateEateriesFromState() {
        if filter.isEnabled {
            let predicate = filter.predicate(userLocation: LocationManager.shared.userLocation)
            updateEateries(allEateries.filter(predicate.isSatisfiedBy(_:)))
        } else {
            updateEateries(allEateries)
        }
    }

}

extension ListModelController: EateryFilterViewControllerDelegate {

    func eateryFilterViewController(_ viewController: EateryFilterViewController, filterDidChange filter: EateryFilter) {
        self.filter = filter
        updateEateriesFromState()
    }

}
