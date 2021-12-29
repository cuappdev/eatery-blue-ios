//
//  HomeModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/29/21.
//

import UIKit

class HomeModelController: HomeViewController {

    private var selectedFilters: Set<EateryFilter> = []
    private var eateryCollections: [EateryCollection] = []
    private var allEateries: [Eatery] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        updateCellsFromState()

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [self] in
            eateryCollections = [
                EateryCollection(
                    title: "Favorite Eateries",
                    description: nil,
                    eateries: [
                        DummyData.rpcc, DummyData.macs
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
                DummyData.macs,
                DummyData.macsClosed,
                DummyData.macsOpenSoon,
                DummyData.macsClosingSoon
            ] + Array(repeating: DummyData.macs, count: 50)

            updateCellsFromState()
        }
    }

    private func addFilters() {
        var buttons: [PillFilterButtonView] = []

        let shortFilter = PillFilterButtonView()
        shortFilter.label.text = "Under 10 min"
        shortFilter.on(UITapGestureRecognizer()) { [weak shortFilter] _ in
            guard let shortFilter = shortFilter else { return }
            shortFilter.setHighlighted(!shortFilter.isHighlighted)
        }
        buttons.append(shortFilter)

        let paymentMethods = PillFilterButtonView()
        paymentMethods.label.text = "Payment Methods"
        paymentMethods.imageView.isHidden = false
        paymentMethods.on(UITapGestureRecognizer()) { [self] _ in
            let viewController = PaymentMethodsFilterSheetViewController()
            viewController.setUpSheetPresentation()
            present(viewController, animated: true)
        }
        buttons.append(paymentMethods)

        cells.append(.filterView(buttons: buttons))
    }

    private func updateCellsFromState() {
        cells = []

        cells.append(.searchBar)
        addFilters()

        if selectedFilters.isEmpty {
            for collection in eateryCollections {
                cells.append(.carouselView(collection: collection))
            }

            if !allEateries.isEmpty {
                cells.append(.titleLabel(title: "All Eateries"))
            }

            for eatery in allEateries {
                cells.append(.eateryCard(eatery: eatery))
            }
        }

        tableView.reloadData()
    }

}
