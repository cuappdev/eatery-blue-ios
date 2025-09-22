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
    private let north = PillFilterButtonView()
    private let west = PillFilterButtonView()
    private let central = PillFilterButtonView()
    private let under10Minutes = PillFilterButtonView()
    private let brbs = PillFilterButtonView()
    private let mealSwipes = PillFilterButtonView()
    private let paymentMethods = PillFilterButtonView()
    private let favorites = PillFilterButtonView()

    private var allFiltersCallback: (() -> Void)?

    var filter = EateryFilter()
    let filtersView = PillFiltersView()

    var viewController: UIViewController?

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
        filtersView.addButton(north)
        setUpNorth()

        filtersView.addButton(west)
        setUpWest()

        filtersView.addButton(central)
        setUpCentral()

        filtersView.addButton(mealSwipes)
        setUpSwipes()

        filtersView.addButton(brbs)
        setUpBRBs()

        filtersView.addButton(favorites)
        setUpFavorites()

        filtersView.addButton(under10Minutes)
        setUpUnder10Minutes()
    }

    private func setUpNorth() {
        north.label.text = "North"
        north.tap { [weak self] _ in
            guard let self else { return }

            allFiltersCallback?()
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
        west.tap { [weak self] _ in
            guard let self else { return }

            allFiltersCallback?()
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
        central.tap { [weak self] _ in
            guard let self else { return }

            allFiltersCallback?()
            filter.central.toggle()
            updateFilterButtonsFromState(animated: true)
            delegate?.eateryFilterViewController(self, filterDidChange: filter)
            if filter.central {
                AppDevAnalytics.shared.logFirebase(CentralFilterPressPayload())
            }
        }
    }

    private func setUpSwipes() {
        mealSwipes.label.text = "Meal Swipes"
        mealSwipes.tap { [weak self] _ in
            guard let self else { return }

            allFiltersCallback?()
            filter.mealSwipesEnabled.toggle()
            updateFilterButtonsFromState(animated: true)
            delegate?.eateryFilterViewController(self, filterDidChange: filter)
            if filter.mealSwipesEnabled {
                AppDevAnalytics.shared.logFirebase(SwipesFilterPressPayload())
            }
        }
    }

    private func setUpBRBs() {
        brbs.label.text = "BRBs"
        brbs.tap { [weak self] _ in
            guard let self else { return }

            allFiltersCallback?()
            filter.brbsEnabled.toggle()
            updateFilterButtonsFromState(animated: true)
            delegate?.eateryFilterViewController(self, filterDidChange: filter)
            if filter.brbsEnabled {
                AppDevAnalytics.shared.logFirebase(SwipesFilterPressPayload())
            }
        }
    }

    private func setUpUnder10Minutes() {
        under10Minutes.label.text = "Under 10 min"
        under10Minutes.tap { [weak self] _ in
            guard let self else { return }

            allFiltersCallback?()
            filter.under10MinutesEnabled.toggle()
            updateFilterButtonsFromState(animated: true)
            delegate?.eateryFilterViewController(self, filterDidChange: filter)
            if filter.under10MinutesEnabled {
                AppDevAnalytics.shared.logFirebase(NearestFilterPressPayload())
            }
        }
    }

    private func setUpFavorites() {
        favorites.label.text = "Favorites"
        favorites.tap { [weak self] _ in
            guard let self else { return }

            allFiltersCallback?()
            filter.favoriteEnabled.toggle()
            updateFilterButtonsFromState(animated: true)
            delegate?.eateryFilterViewController(self, filterDidChange: filter)
            if filter.favoriteEnabled {
                AppDevAnalytics.shared.logFirebase(FavoriteItemsPressPayload())
            }
        }
    }

    func anyFilterTap(_ callback: (() -> Void)?) {
        allFiltersCallback = callback
    }

    private func setUpConstraints() {
        filtersView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func viewLayoutMarginsDidChange() {
        filtersView.scrollView.contentInset = view.layoutMargins
        filtersView.scrollView.layoutIfNeeded()

        super.viewLayoutMarginsDidChange()
    }

    func updateFilterButtonsFromState(animated: Bool) {
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
        mealSwipes.setHighlighted(filter.mealSwipesEnabled)
        brbs.setHighlighted(filter.brbsEnabled)

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
        for paymentMethod in filter.paymentMethods {
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
