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
    private var allEateries: [Eatery]?

    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupMenuCategoryStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - configure
    
    func configure(eatery: Eatery, selectedDay: Day, selectedMealType: String) {
        self.eatery = eatery
        
        let selectedEvents = eatery.events.filter { $0.canonicalDay == selectedDay }
        
        // TODO: Ideally this should be an enum but good for now
        
        // Ignore late lunch
        var event: Event?
        if selectedMealType == "Breakfast" {
            event = selectedEvents.first { $0.description == "Brunch" || $0.description == "Breakfast" }
        } else if selectedMealType == "Lunch" {
            event = selectedEvents.first { $0.description == "Brunch" || $0.description == "Lunch" }
        } else if selectedMealType == "Dinner" {
            event = selectedEvents.first { $0.description == "Dinner" }
        } else if selectedMealType == "Late Dinner" {
            event = selectedEvents.first { $0.description == "Late Night" }
        }
        
        if let event, event.endDate > Date() {
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
        viewEateryDetails.imageView.tintColor = UIColor.Eatery.gray05
        viewEateryDetails.titleLabel.textColor = UIColor.Eatery.black
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
        if let categories = event.menu?.categories {
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

            sortedCategories.forEach { category in
                let menuCategoryView = EateryExpandableCardMenuCategoryView()
                menuCategoryView.configure(menuCategory: category)
                menuCategoryStackView.addArrangedSubview(menuCategoryView)
            }
        }
    }
    
    func reset() {
        menuCategoryStackView.arrangedSubviews.forEach { subview in
            menuCategoryStackView.removeArrangedSubview(subview)
            guard let categorySubView = subview as? EateryExpandableCardMenuCategoryView else { return }
            
            categorySubView.reset()
        }
    }
    
    // MARK: - Tap recognizer
    
    @objc private func didTapEateryDetails(_ sender: UITapGestureRecognizer) {
        if let navigationController = findNavigationController() {
            if let eatery = eatery {
                let eateryVC = EateryModelController()
                eateryVC.setUp(eatery: eatery, allEateries: allEateries ?? [], isTracking: true)
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
