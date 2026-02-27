//
//  EateryExpandableCardDetailView.swift
//  Eatery Blue
//
//  Created by Antoinette Marie Torres on 9/23/23.
//

import EateryModel
import SnapKit
import UIKit

class EateryExpandableCardDetailView: UIView {
    // MARK: - Properties

    private let menuCategoryStackView = UIStackView()
    private let viewEateryDetails = PillButtonView()

    private var eatery: Eatery?
    private var allEateries: [Eatery] = []

    // MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupMenuCategoryStackView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - configure

    func configure(eatery: Eatery, selectedDay: Day, selectedMealType: EventType, allEateries: [Eatery]) {
        self.eatery = eatery
        self.allEateries = allEateries

        let selectedEvents = eatery.events.filter { $0.canonicalDay == selectedDay }

        // Ignore late lunch
        if let event = selectedEvents.first(where: { $0.type == selectedMealType }) {
            menuCategoryStackView.addArrangedSubview(HDivider())
            addMenuCategories(event: event)
            setupViewEateryDetailsButton()
        }
    }

    // MARK: - Set Up Views

    private func setupMenuCategoryStackView() {
        menuCategoryStackView.axis = .vertical
        menuCategoryStackView.alignment = .fill
        menuCategoryStackView.distribution = .equalSpacing
        menuCategoryStackView.spacing = 12

        addSubview(menuCategoryStackView)

        menuCategoryStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
    }

    private func setupViewEateryDetailsButton() {
        viewEateryDetails.backgroundColor = UIColor.Eatery.gray00
        viewEateryDetails.imageView.image = UIImage(named: "EateryDetails")?.withRenderingMode(.alwaysTemplate)
        viewEateryDetails.imageView.tintColor = UIColor.Eatery.secondaryText
        viewEateryDetails.titleLabel.textColor = UIColor.Eatery.primaryText
        viewEateryDetails.titleLabel.text = "View Eatery Details"
        viewEateryDetails.isUserInteractionEnabled = true
        viewEateryDetails.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(didTapEateryDetails(_:))
        ))

        addSubview(viewEateryDetails)

        viewEateryDetails.snp.makeConstraints { make in
            make.height.equalTo(36)
            make.width.equalToSuperview().inset(12)
            make.centerX.equalToSuperview()
            make.top.equalTo(menuCategoryStackView.snp.bottom).offset(16)
            make.bottom.equalToSuperview().inset(8)
        }
    }

    // MARK: - Helpers

    private func addMenuCategories(event: Event) {
        var sortedCategories: [MenuCategory] = eatery?.name == "Morrison Dining" ? event.menu : event.menu
            .reversed()
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

        for category in sortedCategories {
            let menuCategoryView = EateryExpandableCardMenuCategoryView()
            menuCategoryView.configure(menuCategory: category)
            menuCategoryStackView.addArrangedSubview(menuCategoryView)
        }
    }

    func reset() {
        for subview in menuCategoryStackView.arrangedSubviews {
            menuCategoryStackView.removeArrangedSubview(subview)
            guard let categorySubView = subview as? EateryExpandableCardMenuCategoryView else { continue }

            categorySubView.reset()
        }
    }

    // MARK: - Tap recognizer

    @objc private func didTapEateryDetails(_: UITapGestureRecognizer) {
        if let navigationController = findNavigationController() {
            if let eatery = eatery {
                let eateryVC = EateryModelController()
                eateryVC.setUp(eatery: eatery, isTracking: true)
                eateryVC.setUpMenu(eatery: eatery)
                navigationController.pushViewController(eateryVC, animated: true)
            }
        }
    }

    private func findNavigationController() -> UINavigationController? {
        var responder: UIResponder? = self
        while let currentResponder = responder {
            if let navigationController = currentResponder as? UINavigationController {
                return navigationController
            }
            responder = currentResponder.next
        }
        return nil
    }
}
