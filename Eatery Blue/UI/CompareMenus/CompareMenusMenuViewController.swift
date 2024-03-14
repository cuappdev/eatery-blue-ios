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

    var eatery: Eatery?

    private let titleLabel = UILabel()
    var previousButton = ButtonView(content: UIView())
    var nextButton = ButtonView(content: UIView())
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    let removeEateryButton = PillButtonView()

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
}
