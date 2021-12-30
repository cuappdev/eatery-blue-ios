//
//  HomeModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/29/21.
//

import UIKit

class HomeModelController: HomeViewController {

    private struct FilterButtons {
        let under10Minutes = PillFilterButtonView()
        let paymentMethods = PillFilterButtonView()
        let favorites = PillFilterButtonView()
        let north = PillFilterButtonView()
        let west = PillFilterButtonView()
        let central = PillFilterButtonView()
    }

    private var filter = EateryFilter()
    private var eateryCollections: [EateryCollection] = []
    private var allEateries: [Eatery] = []

    private let filtersView = PillFiltersView()
    private let filterButtons = FilterButtons()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpFiltersView()

        updateCellsFromState()

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [self] in
            eateryCollections = [
                EateryCollection(
                    title: "Favorite Eateries",
                    description: nil,
                    eateries: [
                        DummyData.rpcc, DummyData.macs, DummyData.macs, DummyData.macs
                    ]
                ),
                EateryCollection(
                    title: "Lunch on the Go",
                    description: "Grab a quick bite on the way to (skipping) your classes",
                    eateries: [
                        DummyData.rpcc, DummyData.macs
                    ]
                ),
            ]

            allEateries = [
                DummyData.rpcc,
                DummyData.macs,
                DummyData.macsClosed,
                DummyData.macsOpenSoon,
                DummyData.macsClosingSoon
            ] + Array(repeating: DummyData.macs, count: 50)

            updateCellsFromState()
        }
    }

    private func setUpFiltersView() {
        filtersView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        filtersView.addButton(filterButtons.under10Minutes)
        filtersView.addButton(filterButtons.paymentMethods)
        filtersView.addButton(filterButtons.favorites)
        filtersView.addButton(filterButtons.north)
        filtersView.addButton(filterButtons.west)
        filtersView.addButton(filterButtons.central)

        setUpFilterButtons()
    }

    private func setUpFilterButtons() {
        setUpFilterButtonUnder10Minutes()
        setUpFilterButtonPaymentMethods()
        setUpFilterButtonFavorites()
        setUpFilterButtonNorth()
        setUpFilterButtonWest()
        setUpFilterButtonCentral()
    }

    private func setUpFilterButtonUnder10Minutes() {
        let button = filterButtons.under10Minutes
        button.label.text = "Under 10 min"
        button.on(UITapGestureRecognizer()) { [self] _ in
            filter.under10MinutesEnabled.toggle()
            updateFilterButtonsFromState()
            updateCellsFromState()
        }
    }

    private func setUpFilterButtonPaymentMethods() {
        let paymentMethod = filterButtons.paymentMethods
        paymentMethod.label.text = "Payment Methods"
        paymentMethod.imageView.isHidden = false
        paymentMethod.on(UITapGestureRecognizer()) { [self] _ in
            let viewController = PaymentMethodsFilterSheetViewController()
            viewController.setUpSheetPresentation()
            viewController.setSelectedPaymentMethods(filter.paymentMethods)
            viewController.delegate = self
            present(viewController, animated: true)
        }
    }

    private func setUpFilterButtonFavorites() {
        let button = filterButtons.favorites
        button.label.text = "Favorites"
        button.on(UITapGestureRecognizer()) { [self] _ in
            filter.favoriteEnabled.toggle()
            updateFilterButtonsFromState()
            updateCellsFromState()
        }
    }

    private func setUpFilterButtonNorth() {
        let button = filterButtons.north
        button.label.text = "North"
        button.on(UITapGestureRecognizer()) { [self] _ in
            filter.north.toggle()
            updateFilterButtonsFromState()
            updateCellsFromState()
        }
    }

    private func setUpFilterButtonWest() {
        let button = filterButtons.west
        button.label.text = "West"
        button.on(UITapGestureRecognizer()) { [self] _ in
            filter.west.toggle()
            updateFilterButtonsFromState()
            updateCellsFromState()
        }
    }


    private func setUpFilterButtonCentral() {
        let button = filterButtons.central
        button.label.text = "Central"
        button.on(UITapGestureRecognizer()) { [self] _ in
            filter.central.toggle()
            updateFilterButtonsFromState()
            updateCellsFromState()
        }
    }

    private func updateCellsFromState() {
        cells = []

        cells.append(.searchBar)

        cells.append(.filterView(filterView: filtersView))

        if !filter.isEnabled {
            for collection in eateryCollections {
                cells.append(.carouselView(collection: collection))
            }

            if !allEateries.isEmpty {
                cells.append(.titleLabel(title: "All Eateries"))
            }

            for eatery in allEateries {
                cells.append(.eateryCard(eatery: eatery))
            }

        } else {
            let predicate = filter.predicate()
            let filteredEateries = allEateries.filter(predicate.isSatisfiedBy(_:))
            for eatery in filteredEateries {
                cells.append(.eateryCard(eatery: eatery))
            }
        }

        tableView.reloadData()
    }

    private func updateFilterButtonsFromState() {
        filterButtons.under10Minutes.setHighlighted(filter.under10MinutesEnabled)
        filterButtons.favorites.setHighlighted(filter.favoriteEnabled)
        filterButtons.north.setHighlighted(filter.north)
        filterButtons.west.setHighlighted(filter.west)
        filterButtons.central.setHighlighted(filter.central)

        if filter.paymentMethods.isEmpty {
            filterButtons.paymentMethods.setHighlighted(false)
            filterButtons.paymentMethods.label.text = "Payment Methods"
        } else {
            filterButtons.paymentMethods.setHighlighted(true)
            filterButtons.paymentMethods.label.text = EateryFormatter.default.formatPaymentMethods(filter.paymentMethods)
        }
    }

}

extension HomeModelController: PaymentMethodsFilterSheetViewControllerDelegate {

    func paymentMethodsFilterSheetViewController(
        _ viewController: PaymentMethodsFilterSheetViewController,
        didSelectPaymentMethods paymentMethods: Set<PaymentMethod>
    ) {
        filter.paymentMethods = paymentMethods

        updateFilterButtonsFromState()
        updateCellsFromState()
        viewController.dismiss(animated: true)
    }

}
