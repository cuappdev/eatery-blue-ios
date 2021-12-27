//
//  DiningHallViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/26/21.
//

import UIKit

class DiningHallViewController: EateryViewController {

    private var diningHall: DiningHall?
    private var selectedEventIndex: Int?
    private var selectedEvent: DiningHallEvent? {
        if let index = selectedEventIndex {
            return diningHall?.diningHallEvents[index]
        } else {
            return nil
        }
    }

    func setUp(diningHall: DiningHall) {
        self.diningHall = diningHall
        resetSelectedEventIndex()

        setUpNavigationView(diningHall)
        setUpStackView(diningHall)
    }

    private func resetSelectedEventIndex() {
        guard let diningHall = diningHall else {
            return
        }

        if let index = Schedule(diningHall.diningHallEvents).onDay(Day()).indexOfSalientEvent() {
            selectedEventIndex = index
        } else if let index = Schedule(diningHall.diningHallEvents).indexOfSalientEvent() {
            selectedEventIndex = index
        } else {
            selectedEventIndex = nil
        }
    }

    private func setUpNavigationView(_ diningHall: DiningHall) {
        navigationView.titleLabel.text = diningHall.name
        updateNavigationViewFromState()
    }

    private func setUpStackView(_ diningHall: DiningHall) {
        addHeaderImageView(imageUrl: diningHall.imageUrl)
        addPaymentMethodsView(headerView: stackView.arrangedSubviews.last, paymentMethods: diningHall.paymentMethods)
        addPlaceDecorationIcon(headerView: stackView.arrangedSubviews.last)
        addNameLabel(diningHall.name)
        navigationTriggerView = stackView.arrangedSubviews.last
        setCustomSpacing(8)
        addShortDescriptionLabel(diningHall)
        addButtons(diningHall)
        addTimingView(diningHall)
        addThickSpacer()

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
        guard let diningHall = diningHall, let event = selectedEvent else {
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
            for event in diningHall.diningHallEvents {
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
                addMediumSpacer()
            }

            if let last = categories.last {
                addMenuCategory(last)
            }

            addHugeSpacer()
        }
    }

}

extension DiningHallViewController: MenuPickerSheetViewControllerDelegate {

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
