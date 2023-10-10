//
//  EateryFilterViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import EateryModel
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
        under10Minutes.tap { [self] _ in
            filter.under10MinutesEnabled.toggle()
            updateFilterButtonsFromState(animated: true)
            delegate?.eateryFilterViewController(self, filterDidChange: filter)
            if filter.under10MinutesEnabled {
                AppDevAnalytics.shared.logFirebase(NearestFilterPressPayload())
            }
        }
    }

    private func setUpPaymentMethods() {
        paymentMethods.label.text = "Payment Methods"
        paymentMethods.imageView.isHidden = false
        paymentMethods.tap { [self] _ in
            let viewController = PaymentMethodsFilterSheetViewController()
            viewController.setUpSheetPresentation()
            viewController.setSelectedPaymentMethods(filter.paymentMethods, animated: false)
            viewController.delegate = self
            tabBarController?.present(viewController, animated: true)
        }
    }

    private func setUpFavorites() {
        favorites.label.text = "Favorites"
        favorites.tap { [self] _ in
            filter.favoriteEnabled.toggle()
            updateFilterButtonsFromState(animated: true)
            delegate?.eateryFilterViewController(self, filterDidChange: filter)
            if filter.favoriteEnabled {
                AppDevAnalytics.shared.logFirebase(FavoriteItemsPressPayload())
            }
        }
    }

    private func setUpNorth() {
        north.label.text = "North"
        north.tap { [self] _ in
            filter.north.toggle()
            updateFilterButtonsFromState(animated: true)
            delegate?.eateryFilterViewController(self, filterDidChange: filter)
            if filter.north {
                AppDevAnalytics.shared.logFirebase(NorthFilterPressPayload())
            }
        }
    }

    private func setUpWest() {
        west.label.text = "West"
        west.tap { [self] _ in
            filter.west.toggle()
            updateFilterButtonsFromState(animated: true)
            delegate?.eateryFilterViewController(self, filterDidChange: filter)
            if filter.west {
                AppDevAnalytics.shared.logFirebase(WestFilterPressPayload())
            }
        }
    }

    private func setUpCentral() {
        central.label.text = "Central"
        central.tap { [self] _ in
            filter.central.toggle()
            updateFilterButtonsFromState(animated: true)
            delegate?.eateryFilterViewController(self, filterDidChange: filter)
            if filter.central {
                AppDevAnalytics.shared.logFirebase(CentralFilterPressPayload())
            }
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

    private func updateFilterButtonsFromState(animated: Bool) {
        guard !animated else {
            UIView.transition(with: view, duration: 0.1, options: [.allowUserInteraction, .transitionCrossDissolve]) {
                self.updateFilterButtonsFromState(animated: false)
            }
            return
        }

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

    func setFilter(_ filter: EateryFilter, animated: Bool) {
        self.filter = filter
        updateFilterButtonsFromState(animated: animated)
    }

}

extension EateryFilterViewController: PaymentMethodsFilterSheetViewControllerDelegate {

    func paymentMethodsFilterSheetViewController(
        _ viewController: PaymentMethodsFilterSheetViewController,
        didSelectPaymentMethods paymentMethods: Set<PaymentMethod>
    ) {
        filter.paymentMethods = paymentMethods
        filter.paymentMethods.forEach { paymentMethod in
            switch paymentMethod {
            case .brbs: AppDevAnalytics.shared.logFirebase(BRBFilterPressPayload())
            case .mealSwipes: AppDevAnalytics.shared.logFirebase(SwipesFilterPressPayload())
            default: break
            }
        }

        updateFilterButtonsFromState(animated: true)
        delegate?.eateryFilterViewController(self, filterDidChange: filter)
        viewController.dismiss(animated: true)
    }

}
