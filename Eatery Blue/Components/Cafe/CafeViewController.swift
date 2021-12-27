//
//  CafeViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/26/21.
//

import UIKit

class CafeViewController: EateryViewController {

    func setUp(cafe: Cafe) {
        setUpNavigationView(cafe)
        setUpStackView(cafe)
    }

    private func setUpNavigationView(_ cafe: Cafe) {
        navigationView.titleLabel.text = cafe.name

        if let menu = cafe.menu {
            let categories = menu.categories

            for (i, menuCategory) in categories.enumerated() {
                navigationView.addCategory(menuCategory.category) { [self] in
                    scrollToCategoryView(at: i)
                }
            }
        }
    }

    private func setUpStackView(_ cafe: Cafe) {
        addHeaderImageView(imageUrl: cafe.imageUrl)
        addPaymentMethodsView(headerView: stackView.arrangedSubviews.last, paymentMethods: cafe.paymentMethods)
        addPlaceDecorationIcon(headerView: stackView.arrangedSubviews.last)
        addNameLabel(cafe.name)
        navigationTriggerView = stackView.arrangedSubviews.last
        setCustomSpacing(8)
        addShortDescriptionLabel(cafe)
        addButtons(cafe)
        addTimingView(cafe)
        addSpacer(height: 16)
        addMenuHeaderView(
            title: "Full Menu",
            subtitle: EateryFormatter.default.formatSchedule(cafe.schedule().onDay(Day()))
        )
        setCustomSpacing(0)
        addSearchBar()
        addThinSpacer()

        if let menu = cafe.menu {
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
