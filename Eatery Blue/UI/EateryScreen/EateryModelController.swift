//
//  EateryModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/26/21.
//

import CoreLocation
import EateryModel
import MapKit
import UIKit

class EateryModelController: EateryViewController {

    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.calendar = .eatery
        return formatter
    }()

    var menuHasLoaded: Bool = false
    private var eatery: Eatery?
    private var selectedEventIndex: Int?
    private var selectedEvent: Event? {
        if let index = selectedEventIndex {
            return eatery?.events[index]
        } else {
            return nil
        }
    }

    func setUp(eatery: Eatery, isTracking: Bool) {
        self.eatery = eatery
        resetSelectedEventIndex()
        setUpNavigationView(eatery)
        setUpStackView(eatery)
        addSpinner()

        if isTracking {
            setUpAnalytics(eatery)
        }
    }
    
    func setUpMenu(eatery: Eatery) {
        Task {
            self.eatery = await Networking.default.loadEatery(by: Int(eatery.id))
            if let eatery = self.eatery {
                deleteSpinner()
                resetSelectedEventIndex()
                setUpNavigationView(eatery)
                setUpAnalytics(eatery)
                addMenuFromState()
                menuHasLoaded = true
            }
        }
    }

    private func resetSelectedEventIndex() {
        guard let eatery = eatery else {
            return
        }

        if let index = EateryStatus.indexOfSalientEvent(eatery.events, on: Day()) {
            selectedEventIndex = index
        }
    }

    private func setUpNavigationView(_ eatery: Eatery) {
        navigationView.titleLabel.text = eatery.name

        navigationView.favoriteButton.tap { [self] _ in
            let coreDataStack = AppDelegate.shared.coreDataStack
            let metadata = coreDataStack.metadata(eateryId: eatery.id)
            metadata.isFavorite.toggle()
            coreDataStack.save()

            updateNavigationViewFavoriteButtonFromCoreData()
            NotificationCenter.default.post(
                name: NSNotification.Name("favoriteEatery"),
                object: nil
            )
        }

        updateNavigationViewFavoriteButtonFromCoreData()
        updateNavigationViewCategoriesFromState()
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
        addAlertsIfNeeded(eatery)
        addTimingView(eatery)
        addSpacer(height: 16)
    }

    private func setUpAnalytics(_ eatery: Eatery) {
        if eatery.paymentMethods.contains(.mealSwipes) {
            AppDevAnalytics.shared.logFirebase(CampusDiningCellPressPayload(diningHallName: eatery.name))
        } else {
            AppDevAnalytics.shared.logFirebase(CampusCafeCellPressPayload(cafeName: eatery.name))
        }
    }

    private func addButtons(_ eatery: Eatery) {
        addButtons(
            orderOnlineAction: eatery.onlineOrderUrl != nil ? didPressOrderOnlineButton : nil,
            directionsAction: eatery.latitude != nil && eatery.longitude != nil ? didPressDirectionsButton : nil
        )
    }

    private func addAlertsIfNeeded(_ eatery: Eatery) {
        let now = Date()
        let relevantAlerts = eatery.alerts.filter { alert in
            alert.startDate <= now && now <= alert.endDate
        }

        for alert in relevantAlerts {
            if let description = alert.description {
                addAlertInfoView(description)
            }
        }
    }

    private func updateNavigationViewFavoriteButtonFromCoreData() {
        guard let eatery = eatery else {
            return
        }

        let metadata = AppDelegate.shared.coreDataStack.metadata(eateryId: eatery.id)
        if metadata.isFavorite {
            navigationView.favoriteButton.content.image = UIImage(named: "FavoriteSelected")
        } else {
            navigationView.favoriteButton.content.image = UIImage(named: "FavoriteUnselected")
        }
    }

    private func updateNavigationViewCategoriesFromState() {
        guard let event = selectedEvent, let menu = event.menu else {
            navigationView.scrollView.isHidden = true
            return
        }

        navigationView.removeAllCategories()

        let sortedCategories = sortMenuCategories(categories: menu.categories)
        navigationView.scrollView.isHidden = sortedCategories.isEmpty
        for (i, menuCategory) in sortedCategories.enumerated() {
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

    private func addMenuFromState() {
        guard let event = selectedEvent else {
            addMenuHeaderView(
                title: "Closed Today",
                subtitle: "Choose a different date to see menu"
            ) { [self] in
                presentMenuPicker()
            }
            addSpacer(height: 16)
            addReportIssueView(eateryId: eatery?.id)
            addViewProportionalSpacer(multiplier: 0.5)
            return
        }

        let title: String
        if event.canonicalDay == Day() {
            title = event.description ?? "Full Menu"
        } else {
            title = "\(weekdayFormatter.string(from: event.canonicalDay.date())) \(event.description ?? "Menu")"
        }

        addMenuHeaderView(
            title: title,
            subtitle: EateryFormatter.default.formatEventTime(event)
        ) { [self] in
            presentMenuPicker()
        }

        // Search bar is currently unimplemented
        // addSearchBar()

        addSpacer(height: 16)

        if let menu = event.menu {
            let sortedCategories = sortMenuCategories(categories: menu.categories)
            if !sortedCategories.isEmpty {
                sortedCategories[..<(sortedCategories.count - 1)].forEach { menuCategory in
                    addMenuCategory(menuCategory)
                    addSpacer(height: 8)
                }

                if let last = sortedCategories.last {
                    addMenuCategory(last)
                }
            }
        }

        addSpacer(height: 8)
        addReportIssueView(eateryId: eatery?.id)
        addViewProportionalSpacer(multiplier: 0.5)
    }

    private func sortMenuCategories(categories: [MenuCategory]) -> [MenuCategory] {
        var sortedCategories: [MenuCategory] = categories.reversed()
        for i in 0..<sortedCategories.count {
            let menuCategory = sortedCategories[i]
            if menuCategory.category == "Chef's Table" {
                sortedCategories.swapAt(0, i)
            }
            if menuCategory.category == "Chef's Table - Sides" {
                sortedCategories.swapAt(1, i)
            }
            if menuCategory.category == "Grill" {
                sortedCategories.swapAt(2, i)
            }
        }
        return sortedCategories
    }

    private func presentMenuPicker() {
        guard let eatery = eatery else {
            return
        }

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

        tabBarController?.present(viewController, animated: true)
    }

    private func didPressOrderOnlineButton() {
        if let url = eatery?.onlineOrderUrl {
            UIApplication.shared.open(url, options: [:])
        }
    }

    private func didPressDirectionsButton() {
        guard let eatery = eatery, let latitude = eatery.latitude, let longitude = eatery.longitude else {
            return
        }

        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = eatery.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ])
    }

}

extension EateryModelController: MenuPickerSheetViewControllerDelegate {

    func menuPickerSheetViewController(_ vc: MenuPickerSheetViewController, didSelectMenuChoiceAt index: Int) {
        selectedEventIndex = index

        updateNavigationViewCategoriesFromState()
        removeMenuFromStackView()
        addMenuFromState()

        vc.dismiss(animated: true)
    }

    func menuPickerSheetViewControllerDidResetMenuChoice(_ vc: MenuPickerSheetViewController) {
        resetSelectedEventIndex()

        updateNavigationViewCategoriesFromState()
        removeMenuFromStackView()
        addMenuFromState()

        vc.dismiss(animated: true)
    }

}
