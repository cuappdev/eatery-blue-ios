//
//  CompareMenusEateryViewController.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 3/5/24.
//

import EateryModel
import UIKit

class CompareMenusEateryViewController: UIViewController {
    // MARK: - Properties (data)

    private var allEateries: [Eatery] = []
    private var categoryViews: [UIView] = []
    private var eatery: Eatery?
    private var menuHasLoaded = false
    private var selectedEventIndex: Int?
    private var selectedEvent: Event? {
        guard let selectedEventIndex else { return nil }
        return eatery?.events[selectedEventIndex]
    }

    // MARK: - Properties (view)

    private let hoursDataView = TimingDataView()
    private let hoursView = TimingCellView()
    private let menuCategoryPicker = MenuCategoryPickerView()
    private let midSpacer = UIView()
    private let scrollView = UIScrollView()
    private let spinnerView = UIActivityIndicatorView()
    private let stackView = UIStackView()
    private let topSpacer = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        topSpacer.backgroundColor = UIColor.Eatery.gray01
        view.addSubview(topSpacer)

        view.addSubview(hoursDataView)

        setUpMenuCategoryPicker()
        view.addSubview(menuCategoryPicker)

        midSpacer.backgroundColor = UIColor.Eatery.gray01
        view.addSubview(midSpacer)

        setUpScrollView()
        view.addSubview(scrollView)

        setUpStackView()
        scrollView.addSubview(stackView)

        setUpSpinnerView()
        view.addSubview(spinnerView)

        setUpConstraints()
    }

    private func setUpMenuCategoryPicker() {
        menuCategoryPicker.delegate = self
    }

    private func setUpHoursView(_ eatery: Eatery) {
        hoursDataView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        hoursView.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        hoursView.titleLabel.textColor = UIColor.Eatery.gray05
        let text = NSMutableAttributedString()
        text.append(NSAttributedString(
            attachment: NSTextAttachment(image: UIImage(named: "Clock"), scaledToMatch: hoursView.titleLabel.font)
        ))
        text.append(NSAttributedString(string: " Hours"))
        hoursView.titleLabel.attributedText = text

        hoursView.statusLabel.attributedText = EateryFormatter.default.formatStatus(eatery.status)

        hoursView.tap { [weak self] _ in
            guard let self else { return }
            let viewController = HoursSheetViewController()
            viewController.setUpSheetPresentation()
            viewController.setUp(eatery.id, eatery.events)
            tabBarController?.present(viewController, animated: true)
        }

        hoursDataView.addCellView(hoursView)
    }

    private func setUpScrollView() {
        scrollView.backgroundColor = UIColor.Eatery.gray00
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.scrollIndicatorInsets = .zero
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
    }

    private func setUpStackView() {
        stackView.backgroundColor = UIColor.Eatery.gray00
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.hero.isEnabled = true
    }

    private func setUpSpinnerView() {
        spinnerView.hidesWhenStopped = true
        spinnerView.style = .medium
        spinnerView.backgroundColor = .white
        spinnerView.startAnimating()
    }

    private func setUpConstraints() {
        topSpacer.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.trailing.top.equalToSuperview()
        }

        hoursDataView.snp.makeConstraints { make in
            make.top.equalTo(topSpacer).offset(12)
            make.leading.trailing.equalToSuperview()
        }

        menuCategoryPicker.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(hoursDataView.snp.bottom)
            make.height.equalTo(50)
        }

        midSpacer.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.top.equalTo(menuCategoryPicker.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(midSpacer.snp.bottom)
            make.width.bottom.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        spinnerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setUp(eatery: Eatery, allEateries: [Eatery]) {
        self.eatery = eatery
        self.allEateries = allEateries

        resetSelectedEventIndex()
        setUpHoursView(eatery)
        setUpAnalytics(eatery)
    }

    func setUpMenu(eatery: Eatery) {
        Task {
            self.eatery = await Networking.default.loadEatery(by: Int(eatery.id))
            if let eatery = self.eatery {
                setUpAnalytics(eatery)
                addMenuFromState()
                spinnerView.stopAnimating()
                menuHasLoaded = true
            }
        }
    }

    private func resetSelectedEventIndex() {
        guard let eatery else { return }

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
                for menuCategory in sortedCategories[..<(sortedCategories.count - 1)] {
                    addMenuCategory(menuCategory, isLast: false)
                }

                if let last = sortedCategories.last {
                    addMenuCategory(last, isLast: true)
                }
            } else {
                addSorryText()
            }
        } else {
            addSorryText()
        }

        addDetailsSection()
        addViewProportionalSpacer(multiplier: 0.5)
    }

    private func addSorryText() {
        let backgroundView = UIView()
        backgroundView.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        backgroundView.backgroundColor = UIColor.Eatery.gray00

        let sorryText = UILabel()
        sorryText.text = "Sorry, there is no menu available now."
        sorryText.font = .systemFont(ofSize: 17, weight: .medium)
        sorryText.textAlignment = .center
        sorryText.backgroundColor = .white
        sorryText.clipsToBounds = true
        sorryText.layer.cornerRadius = 10
        sorryText.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        backgroundView.addSubview(sorryText)
        stackView.addArrangedSubview(backgroundView)

        sorryText.snp.makeConstraints { make in
            make.edges.equalTo(backgroundView.layoutMargins)
            make.height.equalTo(64)
        }
    }

    private func addDetailsSection() {
        let viewEateryContainer = UIView()
        viewEateryContainer.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        viewEateryContainer.backgroundColor = UIColor.Eatery.gray00

        let backgroundView = UIView()
        backgroundView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        backgroundView.backgroundColor = .white
        backgroundView.layer.cornerRadius = 10

        let viewEateryDetails = PillButtonView()
        viewEateryDetails.backgroundColor = UIColor.Eatery.gray00
        viewEateryDetails.imageView.image = UIImage(named: "EateryDetails")?.withRenderingMode(.alwaysTemplate)
        viewEateryDetails.imageView.tintColor = UIColor.Eatery.gray05
        viewEateryDetails.titleLabel.textColor = UIColor.Eatery.black
        viewEateryDetails.titleLabel.text = "View Eatery Details"
        viewEateryDetails.isUserInteractionEnabled = true
        viewEateryDetails.tap { [weak self] _ in
            guard let self, let eatery else { return }

            let eateryVC = EateryModelController()
            eateryVC.setUp(eatery: eatery, isTracking: true, shouldShowCompareMenus: false)
            eateryVC.setUpMenu(eatery: eatery)
            navigationController?.pushViewController(eateryVC, animated: true)
        }

        backgroundView.addSubview(viewEateryDetails)
        viewEateryContainer.addSubview(backgroundView)
        stackView.addArrangedSubview(viewEateryContainer)

        viewEateryDetails.snp.makeConstraints { make in
            make.edges.equalTo(backgroundView.layoutMargins)
            make.height.equalTo(42)
        }

        backgroundView.snp.makeConstraints { make in
            make.edges.equalTo(viewEateryContainer.layoutMargins)
        }
    }

    private func addSpacer(height: CGFloat, color: UIColor? = UIColor.Eatery.gray00) {
        let spacer = UIView()
        spacer.backgroundColor = color
        stackView.addArrangedSubview(spacer)
        spacer.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
    }

    private func sortMenuCategories(categories: [MenuCategory]) -> [MenuCategory] {
        var sortedCategories: [MenuCategory] = categories.reversed()
        for i in 0 ..< sortedCategories.count {
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

    private func addMenuCategory(_ menuCategory: MenuCategory, isLast: Bool) {
        let categoryContainer = UIView()
        categoryContainer.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        let categoryView = MenuCategoryView()
        categoryView.titleLabel.text = menuCategory.category
        categoryView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        categoryView.backgroundColor = .white

        for item in menuCategory.items {
            let itemView = MenuItemView()
            itemView.item = item
            categoryView.addItemView(itemView)
        }
        categoryContainer.addSubview(categoryView)
        categoryView.snp.makeConstraints { make in
            make.edges.equalTo(categoryContainer.layoutMargins)
        }

        if categoryViews.isEmpty {
            categoryView.clipsToBounds = true
            categoryView.layer.cornerRadius = 10
            if !isLast {
                categoryView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            }
        } else if isLast {
            categoryView.clipsToBounds = true
            categoryView.layer.cornerRadius = 10
            categoryView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }

        stackView.addArrangedSubview(categoryContainer)
        categoryViews.append(categoryContainer)

        menuCategoryPicker.addMenuCategory(categoryName: menuCategory.category)
    }

    private func scrollToCategoryView(at index: Int) {
        let offset = stackView.subviews[index].frame.minY - 8
        scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
    }

    private func addViewProportionalSpacer(multiplier: CGFloat, color: UIColor? = UIColor.Eatery.gray00) {
        let spacer = UIView()
        spacer.backgroundColor = color
        stackView.addArrangedSubview(spacer)
        spacer.snp.makeConstraints { make in
            make.height.equalTo(view).multipliedBy(multiplier)
        }
    }
}

extension CompareMenusEateryViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let cursorPosition = scrollView.contentOffset.y + scrollView.contentInset.top + 25
        // The selected category is the menu category view that is under the cursor position
        let categoryView = stackView.arrangedSubviews.first { view in
            if !view.subviews.contains(where: { subviews in
                subviews is MenuCategoryView
            }) {
                return false
            }
            return view.frame.minY <= cursorPosition && cursorPosition <= view.frame.maxY
        }

        if let categoryView = categoryView {
            guard let index = categoryViews.firstIndex(of: categoryView) else {
                logger.error("\(self): Could not find index of \(categoryView) in categoryViews")
                return
            }

            menuCategoryPicker.highlightCategory(atIndex: index, animated: true)
        }
    }
}

extension CompareMenusEateryViewController: MenuCategoryPickerDelegate {
    func menuCategoryPicker(buttonPressedAtIndex idx: Int) {
        let category = categoryViews[idx]
        let viewIdx = stackView.subviews.firstIndex { $0 == category } ?? 0
        scrollToCategoryView(at: viewIdx)
    }
}
