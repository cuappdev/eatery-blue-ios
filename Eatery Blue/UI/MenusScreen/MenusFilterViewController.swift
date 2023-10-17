//
//  MenusFilterViewController.swift
//  Eatery Blue
//
//  Created by Antoinette Marie Torres on 9/23/23.
//

import EateryModel
import UIKit

protocol MenusFilterViewControllerDelegate: AnyObject {

    func menusFilterViewController(_ viewController: MenusFilterViewController, didChangeLocation filter: EateryFilter)
    func menusFilterViewController(_ viewController: MenusFilterViewController, didChangeMenuType string: String)

}

class MenusFilterViewController: UIViewController {
    
    let mealType = PillFilterButtonView()
    let all = PillFilterButtonView()
    let north = PillFilterButtonView()
    let west = PillFilterButtonView()
    let central = PillFilterButtonView()
    
    var selectedMenuIndex: Int?
    
    private(set) var filter = EateryFilter()
    private let filtersView = PillFiltersView()
    
    weak var delegate: MenusFilterViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        setUpConstraints()
        
        filter.north = true
        filter.west = true
        filter.central = true
        updateFilterButtonsFromState(animated: false)
    }
    
    init(currentMealType: String) {
        // TODO: This should be an enum
        
        if currentMealType == "Breakfast" {
            selectedMenuIndex = 0
        } else if currentMealType == "Lunch" {
            selectedMenuIndex = 1
        } else if currentMealType == "Dinner" {
            selectedMenuIndex = 2
        } else if currentMealType == "Late Dinner" {
            selectedMenuIndex = 3
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        view.insetsLayoutMarginsFromSafeArea = false
        view.addSubview(filtersView)
        setUpFiltersView()
    }
    
    private func setUpFiltersView() {
        filtersView.addButton(mealType)
        setUpMealType()
        
        filtersView.addButton(all)
        setUpAll()
        
        filtersView.addButton(north)
        setUpNorth()
        
        filtersView.addButton(west)
        setUpWest()
        
        filtersView.addButton(central)
        setUpCentral()
    }
    
    private func setUpMealType() {
        mealType.label.text = "Breakfast"
        mealType.imageView.isHidden = false
        mealType.tap { [self] _ in
            let viewController = UpcomingMenuPickerSheetViewController()
            viewController.setUpSheetPresentation()
            viewController.selectedMenuIndex = selectedMenuIndex
            viewController.setUp()
            viewController.delegate = self
            tabBarController?.present(viewController, animated: true)
        }
    }
    
    private func setUpAll() {
        all.label.text = "All Campus"
        all.tap { [self] _ in
            let allCampusSelected = !filter.north || !filter.central || !filter.west
            filter.north = allCampusSelected
            filter.central = allCampusSelected
            filter.west = allCampusSelected
            
            delegate?.menusFilterViewController(self, didChangeLocation: filter)
            updateFilterButtonsFromState(animated: true)
        }
    }
    
    private func setUpNorth() {
        north.label.text = "North"
        north.tap { [self] _ in
            if filter.north && filter.west && filter.central {
                filter.north = true
                filter.west = false
                filter.central = false
            } else {
                filter.north.toggle()
            }
            updateFilterButtonsFromState(animated: true)
            delegate?.menusFilterViewController(self, didChangeLocation: filter)
            if filter.north {
                AppDevAnalytics.shared.logFirebase(NorthFilterPressPayload())
            }
        }
    }
    
    private func setUpWest() {
        west.label.text = "West"
        west.tap { [self] _ in
            if filter.north && filter.west && filter.central {
                filter.north = false
                filter.west = true
                filter.central = false
            } else {
                filter.west.toggle()
            }
            updateFilterButtonsFromState(animated: true)
            delegate?.menusFilterViewController(self, didChangeLocation: filter)
            if filter.west {
                AppDevAnalytics.shared.logFirebase(WestFilterPressPayload())
            }
        }
    }
    
    private func setUpCentral() {
        central.label.text = "Central"
        central.tap { [self] _ in
            if filter.north && filter.west && filter.central {
                filter.north = false
                filter.west = false
                filter.central = true
            } else {
                filter.central.toggle()
            }
            updateFilterButtonsFromState(animated: true)
            delegate?.menusFilterViewController(self, didChangeLocation: filter)
            if filter.central {
                AppDevAnalytics.shared.logFirebase(CentralFilterPressPayload())
            }
        }
    }
    
    private func setUpConstraints() {
        filtersView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewLayoutMarginsDidChange() {
        filtersView.scrollView.contentInset = view.layoutMargins
    }
    
    private func updateFilterButtonsFromState(animated: Bool) {
        guard !animated else {
            UIView.transition(with: view, duration: 0.1, options: [.allowUserInteraction, .transitionCrossDissolve]) {
                self.updateFilterButtonsFromState(animated: false)
            }
            return
        }
        
        all.setHighlighted(filter.north && filter.west && filter.central)
        north.setHighlighted(filter.north)
        west.setHighlighted(filter.west)
        central.setHighlighted(filter.central)
        
        func setFilter(_ filter: EateryFilter, animated: Bool) {
            self.filter = filter
            updateFilterButtonsFromState(animated: animated)
        }
    }
}

extension MenusFilterViewController: UpcomingMenuPickerSheetViewControllerDelegate {
    
    func upcomingMenuPickerSheetViewController(_ vc: UpcomingMenuPickerSheetViewController, didChangeMenuChoice string: String) {
        mealType.label.text = string
        if let mealType = mealType.label.text {
            delegate?.menusFilterViewController(self, didChangeMenuType: mealType)
        }
    }
    
    func upcomingMenuPickerSheetViewController(_ viewController: UpcomingMenuPickerSheetViewController, didSelectMenuChoiceAt index: Int) { }
    
}
