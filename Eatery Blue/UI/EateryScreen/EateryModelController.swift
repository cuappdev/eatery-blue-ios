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

    func setUp(eatery: Eatery, isTracking: Bool, shouldShowCompareMenus _: Bool = true) {
        self.eatery = eatery

        resetSelectedEventIndex()
        setUpNavigationView(eatery)
        setUpStackView(eatery)
        addSpinner()

        if isTracking {
            setUpAnalytics(eatery)
        }

        setUpCompareMenusButton()
    }

    func setUpMenu(eatery: Eatery) {
        Task {
            self.eatery = await Networking.default.loadEatery(by: eatery.id)
            if let eatery = self.eatery {
                deleteSpinner()
                resetSelectedEventIndex()
                setUpNavigationView(eatery)
                addMenuFromState()
                menuHasLoaded = true
            } else {
                // Failure: Networking returned nil eatery
                deleteSpinner()
                removeMenuFromStackView()

                // If a specific event is selected, show its info in the header
                if let event = selectedEvent {
                    addMenuHeaderView(
                        eateryId: eatery.id,
                        title: event.canonicalDay.toWeekdayString(),
                        subtitle: EateryFormatter.default.formatEventTime(event)
                    ) { [self] in
                        presentMenuPicker()
                    }
                }
                // Otherwise, default to today's day in the header
                else {
                    addMenuHeaderView(
                        eateryId: eatery.id,
                        title: Day().toWeekdayString(),
                        subtitle: ""
                    ) { [self] in
                        presentMenuPicker()
                    }
                }
                addSpacer(height: 16)
                addInlineErrorBlock(reportIssueEateryId: nil)
                // Keep header above any overlapping subviews added later
                if let header = stackView.arrangedSubviews.first(where: { $0 is MenuHeaderView }) {
                    stackView.bringSubviewToFront(header)
                }
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
                name: UIViewController.notificationName,
                object: nil,
                userInfo: [UIViewController.notificationUserInfoKey: metadata.isFavorite]
            )
        }

        updateNavigationViewFavoriteButtonFromCoreData()
        updateNavigationViewCategoriesFromState()
    }

    private func setUpStackView(_ eatery: Eatery) {
        addHeaderImageView(url: eatery.imageUrl)
        addPaymentMethodsView(headerView: stackView.arrangedSubviews.last, paymentMethods: eatery.paymentMethods)
        addPlaceDecorationIcon(headerView: stackView.arrangedSubviews.last)
        addNameLabel(eatery.name)
        navigationTriggerView = stackView.arrangedSubviews.last
        setCustomSpacing(8)
        addShortDescriptionLabel(eatery)
        addButtons(eatery)
        addAlertsIfNeeded(eatery)
        addTimingView(eatery)
        addAboutDescription(eatery)
        addSpacer(height: 16)
    }

    func setUpAnalytics(_ eatery: Eatery) {
        if eatery.paymentMethods.contains(.mealSwipe) {
            AppDevAnalytics.shared.logFirebase(CampusDiningCellPressPayload(diningHallName: eatery.name))
        } else {
            AppDevAnalytics.shared.logFirebase(CampusCafeCellPressPayload(cafeName: eatery.name))
        }
    }

    private func setUpCompareMenusButton() {
        // Save the current eatery at setup time
        let preselectedEatery = eatery

        compareMenusButton.buttonPress { [weak self, preselectedEatery] _ in
            guard let self else { return }

            guard let selectedEatery = self.eatery ?? preselectedEatery else { return }

            self.view.bringSubviewToFront(self.compareMenusButton)

            Task { @MainActor in
                let viewController = CompareMenusSheetViewController(
                    parentNavigationController: self.navigationController,
                    selectedEateries: [selectedEatery]
                )
                viewController.setUpSheetPresentation()

                if let presenter = self.tabBarController {
                    presenter.present(viewController, animated: true)
                } else {
                    self.present(viewController, animated: true)
                }

                AppDevAnalytics.shared.logFirebase(CompareMenusButtonPressPayload(entryPage: "EateryModelController"))
            }
        }
    }

    private func addButtons(_ eatery: Eatery) {
        addButtons(
            orderOnlineAction: eatery.onlineOrderUrl != nil ? didPressOrderOnlineButton : nil,
            directionsAction: didPressDirectionsButton
        )
    }

    private func addAlertsIfNeeded(_ eatery: Eatery) {
        let now = Date()

        for alert in eatery.announcements {
            addAlertInfoView(alert)
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
        guard let event = selectedEvent, !event.menu.isEmpty else {
            navigationView.scrollView.isHidden = true
            return
        }

        navigationView.removeAllCategories()

        let sortedCategories = sortMenuCategories(categories: event.menu)
        navigationView.scrollView.isHidden = sortedCategories.isEmpty
        for (i, menuCategory) in sortedCategories.enumerated() {
            navigationView.addCategory(menuCategory.name) { [self] in
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
            // Error state
            guard let eat = eatery else {
                // Determine which day to display
                let selectedDay: Day
                if let picker = presentedViewController as? MenuPickerSheetViewController,
                   let day = picker.selectedCanonicalDay {
                    selectedDay = day
                } else {
                    selectedDay = Day()
                }
                addMenuHeaderView(
                    eateryId: eatery?.id,
                    title: selectedDay.toWeekdayString(),
                    subtitle: ""
                ) { [self] in
                    presentMenuPicker()
                }
                addSpacer(height: 16)
                addInlineErrorBlock(reportIssueEateryId: eatery.flatMap { $0.id })
                addViewProportionalSpacer(multiplier: 0.5)
                return
            }
            // Closed for the day state
            addMenuHeaderView(
                eateryId: eatery?.id,
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
            title = event.type.description
        } else {
            title = "\(weekdayFormatter.string(from: event.canonicalDay.date())) \(event.type.description)"
        }

        addMenuHeaderView(
            eateryId: eatery?.id,
            title: event.canonicalDay.toWeekdayString(),
            subtitle: EateryFormatter.default.formatEventTime(event)
        ) { [self] in
            presentMenuPicker()
        }

        // Search bar is currently unimplemented
        // addSearchBar()

        let events = eatery?.events
            .filter {
                $0.canonicalDay == selectedEvent?.canonicalDay && !($0.menu.isEmpty)
            } ?? []
        if events.count <= 1 {
            addSpacer(height: 16)
        } else {
            addTimeTabs(eatery: eatery, selectedEvent: event) { [weak self] index in
                guard let self else { return }

                selectedEventIndex = index

                updateNavigationViewCategoriesFromState()
                removeMenuFromStackView()
                addMenuFromState()
            }
        }

        // Treat categories with no items as absent
        // If all categories are empty, show the inline error state
        // Filter out categories whose items are empty
        let nonEmptyCategories = event.menu.filter { !$0.items.isEmpty }

        if nonEmptyCategories.isEmpty {
            addInlineErrorBlock(reportIssueEateryId: eatery.flatMap { $0.id })
        } else {
            let sortedCategories = sortMenuCategories(categories: nonEmptyCategories)
            if !sortedCategories.isEmpty {
                for menuCategory in sortedCategories[..<(sortedCategories.count - 1)] {
                    addMenuCategory(menuCategory)
                    addSpacer(height: 8)
                }

                if let last = sortedCategories.last {
                    addMenuCategory(last)
                }

                addSpacer(height: 16)
                addReportIssueView(eateryId: eatery?.id)
                addViewProportionalSpacer(multiplier: 0.25)
            } else {
                addInlineErrorBlock(reportIssueEateryId: eatery.flatMap { $0.id })
            }
        }
    }

    private func sortMenuCategories(categories: [MenuCategory]) -> [MenuCategory] {
        var sortedCategories: [MenuCategory] = eatery?.name == "Morrison Dining" ? categories : categories.reversed()
        for i in 0 ..< sortedCategories.count {
            let menuCategory = sortedCategories[i]
            // Remove hardcoded categories and use a better sorting mechanism
            if menuCategory.name == "Chef's Table" {
                sortedCategories.swapAt(0, i)
            }

            if menuCategory.name == "Chef's Table - Sides" {
                sortedCategories.swapAt(1, i)
            }

            if menuCategory.name == "Grill" {
                sortedCategories.swapAt(2, i)
            }
        }
        return sortedCategories
    }

    private func presentMenuPicker() {
        let viewController = MenuPickerSheetViewController()
        viewController.setUpSheetPresentation()
        viewController.delegate = self

        var menuChoices: [MenuPickerSheetViewController.MenuChoice] = []
        if let eatery = eatery {
            for event in eatery.events {
                menuChoices.append(MenuPickerSheetViewController.MenuChoice(
                    description: event.type.description,
                    event: event
                ))
            }
        }

        viewController.setUp(menuChoices: menuChoices, selectedMenuIndex: selectedEventIndex)

        if let presenter = tabBarController {
            presenter.present(viewController, animated: true)
        } else {
            present(viewController, animated: true)
        }
    }

    private func didPressOrderOnlineButton() {
        if let stringUrl = eatery?.onlineOrderUrl, let url = URL(string: stringUrl) {
            UIApplication.shared.open(url, options: [:])
        }
    }

    private func didPressDirectionsButton() {
        guard let eatery = eatery else {
            return
        }

        let coordinate = CLLocationCoordinate2D(latitude: Double(eatery.latitude), longitude: Double(eatery.longitude))
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = eatery.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ])
    }

    private func addInlineErrorBlock(reportIssueEateryId: Int?) {
        let container = UIView()
        container.isUserInteractionEnabled = false

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12

        let imageView = UIImageView(image: UIImage(systemName: "xmark.octagon"))
        imageView.tintColor = UIColor.Eatery.red
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(41)
        }

        let titleLabel = UILabel()
        titleLabel.text = "Hmm, no chow here (yet)."
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        let messageLabel = UILabel()
        messageLabel.text = "We ran into an issue loading this page. Check your connection or try again later"
        messageLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        messageLabel.textColor = UIColor.Eatery.gray05
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        stack.addArrangedSubview(imageView)
        stack.setCustomSpacing(12, after: imageView)
        stack.addArrangedSubview(titleLabel)
        stack.setCustomSpacing(4, after: titleLabel)
        stack.addArrangedSubview(messageLabel)

        container.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(41)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(32)
            make.bottom.equalToSuperview().inset(155)
        }

        stackView.addArrangedSubview(container)
        addSpacer(height: 16)
        addReportIssueView(eateryId: reportIssueEateryId)
        addViewProportionalSpacer(multiplier: 0.5)
    }
}

extension EateryModelController: MenuPickerSheetViewControllerDelegate {
    func menuPickerSheetViewController(_ vc: MenuPickerSheetViewController, didSelectMenuChoiceAt index: Int?) {
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
