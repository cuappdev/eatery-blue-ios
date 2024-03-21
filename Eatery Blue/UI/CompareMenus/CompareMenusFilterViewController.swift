//
//  CompareMenusFilterViewController.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 3/18/24.
//

import EateryModel

class CompareMenusFilterViewController: EateryFilterViewController {
    
    private let selected = PillFilterButtonView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpSelected()
    }

    func setUpSelected() {
        filtersView.addButton(selected, at: 0)
        self.selected.label.text = "Selected"
        self.selected.tap { [weak self] _ in
            guard let self else { return }
            filter.selected.toggle()
            self.removeAllFilters()
            updateFilterButtonsFromState(animated: true)
            delegate?.eateryFilterViewController(self, filterDidChange: filter)
        }
    }

    func removeAllFilters() {
        filter.paymentMethods = []
        filter.central = false
        filter.favoriteEnabled = false
        filter.north = false
        filter.under10MinutesEnabled = false
        filter.west = false
    }

    override func updateFilterButtonsFromState(animated: Bool) {
        if filter.selected {
            removeAllFilters()
        }
        super.updateFilterButtonsFromState(animated: animated)
        selected.setHighlighted(filter.selected)
    }

}
