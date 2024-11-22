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

        // Moving "Favorites" button to the 5th position.
        filtersView.moveButton(from: .max, to: 4)
        // "moveButton" handles out of binds index to bounds. Because "Favorites"
        // button is always last, a large from will ensure this doesn't
        // break if more filters are added
    }

    private func setUpSelected() {
        filtersView.addButton(selected, at: 0)
        self.selected.label.text = "Selected"
        self.selected.tap { [weak self] _ in
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
        self.removeAllFilters()
        updateFilterButtonsFromState(animated: true)
        delegate?.eateryFilterViewController(self, filterDidChange: filter)
    }

}
