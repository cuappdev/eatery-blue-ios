//
//  CompareMenusFilterViewController.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 3/18/24.
//

import EateryModel

class CompareMenusFilterViewController: EateryFilterViewController {
    // MARK: - Properties (view)

    private let selected = PillFilterButtonView()

    // MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpSelected()
        anyFilterTap { [weak self] in
            guard let self else { return }

            filter.selected = false
        }

        // Moving "Favorites" button to the 5th position
        // "moveButton" forces out of bounds index to the bounds
        filtersView.moveButton(from: .max, to: 4)
    }

    private func setUpSelected() {
        filtersView.addButton(selected, at: 0)
        selected.label.text = "Selected"
        selected.tap { [weak self] _ in
            guard let self else { return }

            tapSelected()
        }
    }

    private func removeAllFilters() {
        filter.paymentMethods = []
        filter.central = false
        filter.favoriteEnabled = false
        filter.north = false
        filter.under10MinutesEnabled = false
        filter.west = false
    }

    override func updateFilterButtonsFromState(animated: Bool) {
        super.updateFilterButtonsFromState(animated: animated)
        selected.setHighlighted(filter.selected)
    }

    func tapSelected() {
        filter.selected.toggle()
        removeAllFilters()
        updateFilterButtonsFromState(animated: true)
        delegate?.eateryFilterViewController(self, filterDidChange: filter)
    }
}
