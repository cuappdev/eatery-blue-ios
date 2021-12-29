//
//  EateryModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/26/21.
//

import UIKit

class EateryModelController: EateryViewController {

    private var eatery: Eatery?
    private var selectedEventIndex: Int?
    private var selectedEvent: Event? {
        if let index = selectedEventIndex {
            return eatery?.events[index]
        } else {
            return nil
        }
    }

    func setUp(eatery: Eatery) {
        self.eatery = eatery
        resetSelectedEventIndex()

        setUpNavigationView(eatery)
        setUpStackView(eatery)
    }

    private func resetSelectedEventIndex() {
        guard let eatery = eatery else {
            return
        }

        if let index = Schedule(eatery.events).onDay(Day()).indexOfSalientEvent() {
            selectedEventIndex = index
        } else {
            selectedEventIndex = nil
        }
    }

    private func setUpNavigationView(_ eatery: Eatery) {
        navigationView.titleLabel.text = eatery.name
        updateNavigationViewFromState()
    }

    private func setUpStackView(_ eatery: Eatery) {
        addHeaderImageView(imageUrl: eatery.imageUrl)
        addPaymentMethodsView(headerView: stackView.arrangedSubviews.last, paymentMethods: eatery.paymentMethods)
        addPlaceDecorationIcon(headerView: stackView.arrangedSubviews.last)
        addNameLabel(eatery.name)
        navigationTriggerView = stackView.arrangedSubviews.last
        setCustomSpacing(8)
        addShortDescriptionLabel(eatery)
        addButtons(eatery)
        addTimingView(eatery)
        addSpacer(height: 16)

        setUpMenuFromState()
    }

    private func updateNavigationViewFromState() {
        guard let event = selectedEvent,
              let menu = event.menu else {
            return
        }

        navigationView.removeAllCategories()

        let categories = menu.categories
        for (i, menuCategory) in categories.enumerated() {
            navigationView.addCategory(menuCategory.category) { [self] in
                scrollToCategoryView(at: i)
            }
        }
    }

    private func removeMenuFromStackView() {
        guard let index = stackView.arrangedSubviews.firstIndex(where: { $0 is MenuHeaderView }) else {
            return
        }

        for view in stackView.arrangedSubviews[index...] {
            view.removeFromSuperview()
        }

        for view in categoryViews {
            view.removeFromSuperview()
        }

        categoryViews.removeAll()
    }

    private func setUpMenuFromState() {
        guard let eatery = eatery, let event = selectedEvent else {
            return
        }

        addMenuHeaderView(
            title: event.description ?? "Menu",
            subtitle: EateryFormatter.default.formatEventTime(event)
        ) { [self] in
            let viewController = MenuPickerSheetViewController()
            viewController.setUpSheetPresentation()
            viewController.delegate = self

            var menuChoices: [MenuPickerSheetViewController.MenuChoice] = []
            for event in eatery.events {
                menuChoices.append(MenuPickerSheetViewController.MenuChoice(
                    description: event.description ?? "Event",
                    event: event
                ))
            }

            viewController.setUp(menuChoices: menuChoices, selectedMenuIndex: selectedEventIndex)

            present(viewController, animated: true)
        }
        setCustomSpacing(0)
        addSearchBar()
        addThinSpacer()

        if let menu = event.menu {
            let categories = menu.categories

            for menuCategory in categories[..<(categories.count - 1)] {
                addMenuCategory(menuCategory)
                addSpacer(height: 8)
            }

            if let last = categories.last {
                addMenuCategory(last)
            }
        }

        addSpacer(height: 8)
        addReportIssueView()
        addViewProportionalSpacer(multiplier: 0.5)
    }

}

extension EateryModelController: MenuPickerSheetViewControllerDelegate {

    func menuPickerSheetViewController(_ vc: MenuPickerSheetViewController, didSelectMenuChoiceAt index: Int) {
        selectedEventIndex = index

        updateNavigationViewFromState()
        removeMenuFromStackView()
        setUpMenuFromState()

        vc.dismiss(animated: true)
    }

    func menuPickerSheetViewControllerDidResetMenuChoice(_ vc: MenuPickerSheetViewController) {
        resetSelectedEventIndex()

        updateNavigationViewFromState()
        removeMenuFromStackView()
        setUpMenuFromState()

        vc.dismiss(animated: true)
    }

}
