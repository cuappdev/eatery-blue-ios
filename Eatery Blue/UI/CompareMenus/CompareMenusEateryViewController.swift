//
//  CompareMenusMenuViewController.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 3/5/24.
//

import EateryModel
import UIKit

class CompareMenusEateryViewController: UIViewController {

    var delegate: CompareMenusEateryViewControllerDelegate?
    var previousContentOffset: CGFloat = 0

    var menuHasLoaded = false
    private var selectedEventIndex: Int?
    private var selectedEvent: Event? {
        if let index = selectedEventIndex {
            return eatery?.events[index]
        } else {
            return nil
        }
    }

    var eatery: Eatery?
    var categoryViews: [MenuCategoryView] = []

    private let titleLabel = UILabel()
    var previousButton = ButtonView(content: UIView())
    var nextButton = ButtonView(content: UIView())
    private let scrollView = UIScrollView()
    private let menuCategoryContainer = UIView()
    private let menuCategoryScrollView = UIScrollView()
    private let stackView = UIStackView()
    let removeEateryButton = PillButtonView()

    let categoriesBackground = UIStackView()
    let categoriesForeground = UIStackView()
    let foregroundMask = PillView()

    private(set) var highlightedCategoryIndex: Int? = nil
    

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

        setUpMenuCategory()
        view.addSubview(menuCategoryContainer)
        menuCategoryContainer.addSubview(menuCategoryScrollView)

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
        scrollView.delegate = self
    }

    private func setUpStackView() {
        stackView.backgroundColor = .white
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 12
        stackView.hero.isEnabled = true
    }

    private func setUpMenuCategory() {
        menuCategoryScrollView.bounces = false
        menuCategoryScrollView.showsHorizontalScrollIndicator = false

        menuCategoryScrollView.addSubview(categoriesBackground)
        setUpCategoriesStackView(categoriesBackground)
        categoriesBackground.isUserInteractionEnabled = true

        menuCategoryScrollView.addSubview(categoriesForeground)

        setUpCategoriesStackView(categoriesForeground)
        categoriesForeground.isUserInteractionEnabled = false
        categoriesForeground.backgroundColor = UIColor.Eatery.black

        foregroundMask.backgroundColor = .white
        categoriesForeground.mask = foregroundMask
    }

    private func setUpCategoriesStackView(_ stackView: UIStackView) {
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill
    }

    private func setUpConstraints() {
        menuCategoryContainer.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(52)
        }
        menuCategoryScrollView.snp.makeConstraints { make in
            make.width.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(36)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(menuCategoryContainer.snp.bottom)
            make.bottom.width.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        setUpCategoriesStackViewConstraints(categoriesBackground)
        setUpCategoriesStackViewConstraints(categoriesForeground)
    }

    private func setUpCategoriesStackViewConstraints(_ stackView: UIStackView) {
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(menuCategoryScrollView.contentLayoutGuide)
            make.height.equalTo(menuCategoryScrollView.frameLayoutGuide)
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
                setUpAnalytics(eatery)
                addMenuFromState()
                menuHasLoaded = true
                highlightCategory(atIndex: 0, animateScrollView: true)
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
        addSpacer(height: 8)
        addDetailsSection()
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

    func addDetailsSection() {
        let viewEateryContainer = UIView()
        let viewEateryDetails = PillButtonView()
        viewEateryDetails.backgroundColor = UIColor.Eatery.gray00
        viewEateryDetails.imageView.image = UIImage(named: "EateryDetails")?.withRenderingMode(.alwaysTemplate)
        viewEateryDetails.imageView.tintColor = UIColor.Eatery.gray05
        viewEateryDetails.titleLabel.textColor = UIColor.Eatery.black
        viewEateryDetails.titleLabel.text = "View Eatery Details"
        viewEateryDetails.isUserInteractionEnabled = true
        viewEateryDetails.tap { [weak self] _ in
            guard let self else { return }
            guard let eatery else { return }
            let eateryVC = EateryModelController()
            eateryVC.setUp(eatery: eatery)
            eateryVC.setUpMenu(eatery: eatery)
            navigationController?.pushViewController(eateryVC, animated: true)
        }
        viewEateryContainer.addSubview(viewEateryDetails)
        viewEateryDetails.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
        }
        stackView.addArrangedSubview(viewEateryContainer)
        viewEateryContainer.snp.makeConstraints { make in
            make.height.equalTo(36)
        }

        let removeEateryContainer = UIView()
        removeEateryButton.backgroundColor = .white
        removeEateryButton.imageView.image = UIImage(named: "X")?.withRenderingMode(.alwaysTemplate)
        removeEateryButton.imageView.tintColor = UIColor.Eatery.red
        removeEateryButton.titleLabel.textColor = UIColor.Eatery.red
        removeEateryButton.titleLabel.text = "Remove Eatery"
        removeEateryButton.layer.borderWidth = 1
        removeEateryButton.layer.borderColor = UIColor.Eatery.red.cgColor
        removeEateryButton.isUserInteractionEnabled = true

        removeEateryContainer.addSubview(removeEateryButton)
        removeEateryButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
        }
        stackView.addArrangedSubview(removeEateryContainer)
        removeEateryContainer.snp.makeConstraints { make in
            make.height.equalTo(36)
        }
    }

    @objc func pushEatery() {
        guard let eatery else { return }
        let eateryVC = EateryModelController()
        eateryVC.setUp(eatery: eatery)
        eateryVC.setUpMenu(eatery: eatery)
        navigationController?.pushViewController(eateryVC, animated: true)
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
                itemView.priceLabel.text = CompareMenusEateryViewController
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
        categoryViews.append(categoryView)

        let backgroundContainer = ContainerView(content: UILabel())
        let foregroundContainer = ContainerView(content: UILabel())

        backgroundContainer.content.text = menuCategory.category
        foregroundContainer.content.text = backgroundContainer.content.text

        backgroundContainer.content.font = .preferredFont(for: .footnote, weight: .semibold)
        foregroundContainer.content.font = .preferredFont(for: .footnote, weight: .medium)

        backgroundContainer.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        foregroundContainer.layoutMargins = backgroundContainer.layoutMargins

        backgroundContainer.content.textColor = UIColor.Eatery.gray05
        foregroundContainer.content.textColor = .white

        categoriesBackground.addArrangedSubview(backgroundContainer)
        categoriesForeground.addArrangedSubview(foregroundContainer)

        backgroundContainer.snp.makeConstraints { make in
            make.width.equalTo(foregroundContainer)
        }

        let index = stackView.subviews.count - 1

        backgroundContainer.tap { [weak self] _ in
            guard let self else { return }
            scrollToCategoryView(at: index)
        }
        foregroundContainer.isUserInteractionEnabled = false
    }

    func scrollToCategoryView(at index: Int) {
        let offset = stackView.subviews[index].frame.minY - 20
        scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
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
        foregroundMask.frame = categoriesForeground.arrangedSubviews[i].frame

        menuCategoryScrollView.scrollRectToVisible(foregroundMask.frame, animated: animateScrollView)
    }
}

extension CompareMenusEateryViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let newOffset = scrollView.contentOffset.y + scrollView.contentInset.top
        delegate?.compareMenusEateryViewController(viewWasScrolled: newOffset, positive: newOffset - previousContentOffset)
        previousContentOffset = newOffset
        let cursorPosition = scrollView.contentOffset.y + scrollView.contentInset.top + 25
        // The selected category is the menu category view that is under the cursor position
        let categoryView = stackView.arrangedSubviews.first { view in
            guard let categoryView = view as? MenuCategoryView else { return false }
            return categoryView.frame.minY <= cursorPosition && cursorPosition <= categoryView.frame.maxY
        } as? MenuCategoryView

        if let categoryView = categoryView {
            guard let index = categoryViews.firstIndex(of: categoryView) else {
                logger.error("\(self): Could not find index of \(categoryView) in categoryViews")
                return
            }

            highlightCategory(atIndex: index, animated: true)
        }
    }
}

protocol CompareMenusEateryViewControllerDelegate {
    func compareMenusEateryViewController(viewWasScrolled scrollAmount: CGFloat, positive: CGFloat)
}
