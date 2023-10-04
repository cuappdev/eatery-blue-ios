//
//  UpcomingMenuPickerSheetViewController.swift
//  Eatery Blue
//
//  Created by Tiffany Pan on 9/29/23.
//


import EateryModel
import UIKit

protocol UpcomingMenuPickerSheetViewControllerDelegate: AnyObject {

    func menuPickerSheetViewController(menuChoice: String)

}

// MARK: - Displays half-sheet for menu selection.

class UpcomingMenuPickerSheetViewController: SheetViewController {

    private let dayPickerView = MenuDayPickerView()

//    weak var delegate: UpcomingMenuPickerSheetViewControllerDelegate?

    private var menuChoices = ["Breakfast", "Lunch", "Dinner"]
    private var menuTimes = ["10:00am - 2:00pm", "5:30pm - 9:00pm", "9:00pm - 10:30pm"]
    
    private var menuChoiceViews: [UpcomingMenuChoiceView] = []
    private var selectedMenuIndex: Int?
    
    weak var delegate: UpcomingMenuPickerSheetViewControllerDelegate?

    func setUp() {
        addHeader(title: "Menus")
        addMenuChoiceViews()
        addPillButton(title: "Show menu", style: .prominent) { [self] in
            print("Tapped pill button")
        }
        addTextButton(title: "Reset") { [self] in
            print("Tapped reset button")
        }
//        updateDayPickerCellsFromState()
    }

    private func addMenuChoiceViews() {
        for i in 0..<menuChoices.count {
            if i != 0 {
                stackView.addArrangedSubview(HDivider())
            }
            
            let menuChoiceView = UpcomingMenuChoiceView()
            menuChoiceView.setup(description: menuChoices[i], time: menuTimes[i])
            menuChoiceView.layoutMargins = .zero
            stackView.addArrangedSubview(menuChoiceView)
            menuChoiceView.tap { [self] _ in
                didTapMenuChoiceView(at: i)
            }
            menuChoiceViews.append(menuChoiceView)
        }   
        updateMenuChoiceViewsFromState()
    }

    private func updateMenuChoiceViewsFromState() {
//        let menuChoicesOnDay: [MenuChoice]
//        if let index = selectedDayIndex {
//            menuChoicesOnDay = filterMenuChoices(on: days[index])
//        } else {
//            menuChoicesOnDay = []
//        }
//
        for (i, view) in menuChoiceViews.enumerated() {
            if i < menuChoices.count {
                let menuChoice = menuChoices[i]
                view.descriptionLabel.text = menuChoice.description
//                view.timeLabel.text = EateryFormatter.default.formatEventTime(menuChoice.event)

                if let selectedMenuIndex = selectedMenuIndex, menuChoices[selectedMenuIndex] == menuChoice {
                    view.imageView.image = UIImage(named: "CheckboxFilled")
                } else {
                    view.imageView.image = UIImage(named: "CheckboxUnfilled")
                }

            } else {
                view.descriptionLabel.text = " "
                view.timeLabel.text = " "
                view.imageView.image = nil
            }
        }
    }

    // MARK: Controls selection of dates.
//    private func didTapDayPickerCellAt(at index: Int) {
//        let menuChoicesOnDay = filterMenuChoices(on: days[index])
//
//        if menuChoicesOnDay.isEmpty {
//            return
//        }
//
//        if selectedDayIndex == index {
//            return
//        }
//
//        selectedDayIndex = index
//
//        if let menuChoice = menuChoicesOnDay.first {
//            selectedMenuIndex = menuChoices.firstIndex { $0 === menuChoice }
//        }
//
//        updateDayPickerCellsFromState()
//        updateMenuChoiceViewsFromState()
//    }

    private func didTapMenuChoiceView(at index: Int) {
//        guard let dayIndex = selectedDayIndex else {
//            return
//        }
//
//        let menuChoicesOnDay = filterMenuChoices(on: days[dayIndex])

//        guard 0 <= index, index < menuChoicesOnDay.count else {
//            return
//        }
//
//        let menuChoice = menuChoicesOnDay[index]
//        selectedMenuIndex = menuChoices.firstIndex(where: { $0 === menuChoice })
        updateMenuChoiceViewsFromState()
    }

}

