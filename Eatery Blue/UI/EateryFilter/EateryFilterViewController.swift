//
//  EateryFilterViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import UIKit

protocol EateryFilterViewControllerDelegate: AnyObject {

    func eateryFilterViewController(_ viewController: EateryFilterViewController, filterDidChange filter: EateryFilter)

}

class EateryFilterViewController: UIViewController {

    let under10Minutes = PillFilterButtonView()
    let paymentMethods = PillFilterButtonView()
    let favorites = PillFilterButtonView()
    let north = PillFilterButtonView()
    let west = PillFilterButtonView()
    let central = PillFilterButtonView()

    private(set) var filter = EateryFilter()
    private let filtersView = PillFiltersView()

    weak var delegate: EateryFilterViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpConstraints()
    }

    private func setUpView() {
        view.insetsLayoutMarginsFromSafeArea = false
        view.addSubview(filtersView)
        setUpFiltersView()
    }

    private func setUpFiltersView() {
        filtersView.addButton(under10Minutes)
        setUpUnder10Minutes()

        filtersView.addButton(paymentMethods)
        setUpPaymentMethods()

        filtersView.addButton(favorites)
        setUpFavorites()

        filtersView.addButton(north)
        setUpNorth()

        filtersView.addButton(west)
        setUpWest()

        filtersView.addButton(central)
        setUpCentral()
    }

    private func setUpUnder10Minutes() {
        under10Minutes.label.text = "Under 10 min"
        under10Minutes.on(UITapGestureRecognizer()) { [self] _ in
            filter.under10MinutesEnabled.toggle()
            updateFilterButtonsFromState()
            delegate?.eateryFilterViewController(self, filterDidChange: filter)
        }
    }

    private func setUpPaymentMethods() {
        paymentMethods.label.text = "Payment Methods"
        paymentMethods.imageView.isHidden = false
        paymentMethods.on(UITapGestureRecognizer()) { [self] _ in
            let viewController = PaymentMethodsFilterSheetViewController()
            viewController.setUpSheetPresentation()
            viewController.setSelectedPaymentMethods(filter.paymentMethods)
            viewController.delegate = self
            present(viewController, animated: true)
        }
    }

    private func setUpFavorites() {
        favorites.label.text = "Favorites"
        favorites.on(UITapGestureRecognizer()) { [self] _ in
            filter.favoriteEnabled.toggle()
            updateFilterButtonsFromState()
            delegate?.eateryFilterViewController(self, filterDidChange: filter)
        }
    }

    private func setUpNorth() {
        north.label.text = "North"
        north.on(UITapGestureRecognizer()) { [self] _ in
            filter.north.toggle()
            updateFilterButtonsFromState()
            delegate?.eateryFilterViewController(self, filterDidChange: filter)
        }
    }

    private func setUpWest() {
        west.label.text = "West"
        west.on(UITapGestureRecognizer()) { [self] _ in
            filter.west.toggle()
            updateFilterButtonsFromState()
            delegate?.eateryFilterViewController(self, filterDidChange: filter)
        }
    }


    private func setUpCentral() {
        central.label.text = "Central"
        central.on(UITapGestureRecognizer()) { [self] _ in
            filter.central.toggle()
            updateFilterButtonsFromState()
            delegate?.eateryFilterViewController(self, filterDidChange: filter)
        }
    }

    private func setUpConstraints() {
        filtersView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func viewLayoutMarginsDidChange() {
        filtersView.scrollView.contentInset = view.layoutMargins
    }

    private func updateFilterButtonsFromState() {
        under10Minutes.setHighlighted(filter.under10MinutesEnabled)
        favorites.setHighlighted(filter.favoriteEnabled)
        north.setHighlighted(filter.north)
        west.setHighlighted(filter.west)
        central.setHighlighted(filter.central)

        if filter.paymentMethods.isEmpty {
            paymentMethods.setHighlighted(false)
            paymentMethods.label.text = "Payment Methods"
        } else {
            paymentMethods.setHighlighted(true)
            paymentMethods.label.text = EateryFormatter.default.formatPaymentMethods(filter.paymentMethods)
        }
    }

    func setFilter(_ filter: EateryFilter) {
        self.filter = filter
        updateFilterButtonsFromState()
    }

}

extension EateryFilterViewController: PaymentMethodsFilterSheetViewControllerDelegate {

    func paymentMethodsFilterSheetViewController(
        _ viewController: PaymentMethodsFilterSheetViewController,
        didSelectPaymentMethods paymentMethods: Set<PaymentMethod>
    ) {
        filter.paymentMethods = paymentMethods

        updateFilterButtonsFromState()
        delegate?.eateryFilterViewController(self, filterDidChange: filter)
        viewController.dismiss(animated: true)
    }

}
