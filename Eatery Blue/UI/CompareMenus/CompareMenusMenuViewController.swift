//
//  CompareMenusMenuViewController.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 3/5/24.
//

import EateryModel
import UIKit

class CompareMenusMenuViewController: UIViewController {

    var menuHasLoaded = false
    private var selectedEventIndex: Int?
    private var selectedEvent: Event? {
        if let index = selectedEventIndex {
            return eatery?.events[index]
        } else {
            return nil
        }
    }

    private var eatery: Eatery?

    private let titleLabel = UILabel()
    var previousButton = ButtonView(content: UIView())
    var nextButton = ButtonView(content: UIView())
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    private(set) var highlightedCategoryIndex: Int? = nil
    let categoryStack = UIStackView()
    let foregroundMask = PillView()

    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.calendar = .eatery
        return formatter
    }()

    private static let priceNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .eatery
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        setUpScrollView()
        view.addSubview(scrollView)

        setUpStackView()
        scrollView.addSubview(stackView)

        setUpConstraints()
    }

    private func setUpScrollView() {
        scrollView.backgroundColor = UIColor.Eatery.gray00
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.scrollIndicatorInsets = .zero
        scrollView.showsVerticalScrollIndicator = false
    }


    private func setUpStackView() {
        stackView.backgroundColor = .white
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 12
        stackView.hero.isEnabled = true
    }

    private func setUpConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
    }

    func setUp(eatery: Eatery) {
        self.eatery = eatery
        resetSelectedEventIndex()
        setUpAnalytics(eatery)
    }

    func setUpMenu(eatery: Eatery) {
        Task {
            self.eatery = await Networking.default.loadEatery(by: Int(eatery.id))
            if let eatery = self.eatery {
//                deleteSpinner()
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

    private func setUpAnalytics(_ eatery: Eatery) {
        if eatery.paymentMethods.contains(.mealSwipes) {
            AppDevAnalytics.shared.logFirebase(CampusDiningCellPressPayload(diningHallName: eatery.name))
        } else {
            AppDevAnalytics.shared.logFirebase(CampusCafeCellPressPayload(cafeName: eatery.name))
        }
    }

    private func addMenuFromState() {
        addSpacer(height: 8)

        guard let event = selectedEvent else {
            addSorryText()
            return
        }

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
            } else {
                addSorryText()
            }
        } else {
            addSorryText()
        }
        addViewProportionalSpacer(multiplier: 0.5)
    }

    func addSorryText() {
        let sorryText = UILabel()
        sorryText.text = "Sorry, there is no menu available for this time."
        sorryText.font = .systemFont(ofSize: 17, weight: .medium)
        sorryText.textAlignment = .center
        sorryText.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        sorryText.snp.makeConstraints { make in
            make.height.equalTo(64)
        }
        stackView.addArrangedSubview(sorryText)
    }

    func addMenuHeaderView(title: String, subtitle: String, dropDownButtonAction: (() -> Void)? = nil) {
        let menuHeaderView = MenuHeaderView()
        menuHeaderView.titleLabel.text = title
        menuHeaderView.subtitleLabel.text = subtitle
        menuHeaderView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        menuHeaderView.buttonImageView.tap { _ in
            dropDownButtonAction?()
        }
        stackView.addArrangedSubview(menuHeaderView)
    }

    func addSpacer(height: CGFloat, color: UIColor? = UIColor.Eatery.gray00) {
        let spacer = UIView()
        spacer.backgroundColor = color
        stackView.addArrangedSubview(spacer)
        spacer.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
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
        }
        return sortedCategories
    }

    func addMenuCategory(_ menuCategory: MenuCategory) {
        let categoryView = MenuCategoryView()
        categoryView.titleLabel.text = menuCategory.category
        categoryView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        for item in menuCategory.items {
            let itemView = MenuItemView()
            itemView.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            itemView.titleLabel.text = item.name

            if let price = item.price {
                itemView.priceLabel.text = CompareMenusMenuViewController
                    .priceNumberFormatter
                    .string(from: NSNumber(value: Double(price) / 100))
            } else {
                itemView.priceLabel.text = ""
            }

            if let description = item.description {
                itemView.descriptionLabel.isHidden = false
                itemView.descriptionLabel.text = description
            } else {
                itemView.descriptionLabel.isHidden = true
            }

            categoryView.addItemView(itemView)
        }

        stackView.addArrangedSubview(categoryView)
    }

    func addViewProportionalSpacer(multiplier: CGFloat, color: UIColor? = UIColor.Eatery.gray00) {
        let spacer = UIView()
        spacer.backgroundColor = color
        stackView.addArrangedSubview(spacer)
        spacer.snp.makeConstraints { make in
            make.height.equalTo(view).multipliedBy(multiplier)
        }
    }

    func highlightCategory(atIndex i: Int, animated: Bool) {
        if highlightedCategoryIndex != nil, animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState, .curveEaseOut]) {
                self.highlightCategory(atIndex: i, animateScrollView: false)
            }
        } else {
            highlightCategory(atIndex: i)
        }
    }

    func highlightCategory(atIndex i: Int, animateScrollView: Bool = false) {
        highlightedCategoryIndex = i
//        foregroundMask.frame = categoriesForeground.arrangedSubviews[i].frame

        scrollView.scrollRectToVisible(foregroundMask.frame, animated: animateScrollView)
    }

}

extension CompareMenusMenuViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        handleHeaderImageScaling()
//        handleNavigationViewTrigger()
        handleNavigationViewCategory()
    }

    private func handleNavigationViewCategory() {
        let offset = scrollView.contentOffset.y + scrollView.contentInset.top

        // We define a cursor that the user is looking at 55px below the navigation view in the scroll view's
        // coordinate system.
        let cursorPosition = offset + categoryStack.frame.height + 55

        // The selected category is the menu category view that is under the cursor position
        let categoryView = stackView.arrangedSubviews.first { view in
            guard let categoryView = view as? MenuCategoryView else { return false }
            return categoryView.frame.minY <= cursorPosition && cursorPosition <= categoryView.frame.maxY
        } as? MenuCategoryView

        if let categoryView = categoryView {
//            guard let index = categoryViews.firstIndex(of: categoryView) else {
//                logger.error("\(self): Could not find index of \(categoryView) in categoryViews")
//                return
//            }
//
//            highlightCategory(atIndex: index, animated: true)
        }
    }

}
