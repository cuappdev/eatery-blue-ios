//
//  MenuPickerSheetViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/26/21.
//

import EateryModel
import UIKit

protocol MenuPickerSheetViewControllerDelegate: AnyObject {
    func menuPickerSheetViewController(_ vc: MenuPickerSheetViewController, didSelectMenuChoiceAt index: Int?)
    func menuPickerSheetViewControllerDidResetMenuChoice(_ vc: MenuPickerSheetViewController)
}

/// Displays half-sheet for menu selection.
class MenuPickerSheetViewController: SheetViewController {
    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .eatery
        formatter.dateFormat = "EEE"
        return formatter
    }()

    class MenuChoice {
        let description: String
        let event: Event

        init(description: String, event: Event) {
            self.description = description
            self.event = event
        }
    }

    private let dayPickerView = MenuDayPickerView()

    weak var delegate: MenuPickerSheetViewControllerDelegate?

    private var days: [Day] = []
    private var selectedDayIndex: Int?

    private var menuChoices: [MenuChoice] = []
    private var selectedMenuIndex: Int?

    private var menuChoiceViews: [MenuChoiceView] = []

    // MARK: - Public helpers (for EateryModelController)

    // Used for the case when eatery has no events but you still want the selected day to appear
    var selectedCanonicalDay: Day? {
        guard let index = selectedDayIndex, index >= 0, index < days.count else {
            return nil
        }
        return days[index]
    }

    func setUp(menuChoices: [MenuChoice], selectedMenuIndex: Int? = nil) {
        setState(menuChoices: menuChoices, selectedMenuIndex: selectedMenuIndex)

        addHeader(title: "Menus")
        addDayPickerView()
        addMenuChoiceViews()
        addPillButton(title: "Show menu", style: .prominent) { [self] in
            // If there's a selected menu, use that index
            if let selectedIndex = self.selectedMenuIndex {
                delegate?.menuPickerSheetViewController(self, didSelectMenuChoiceAt: selectedIndex)
            }
            // Otherwise, use the selected day even if no menus exist
            else if let dayIndex = self.selectedDayIndex {
                // Find the first matching event for that day, if any
                if let eventIndex = menuChoices.firstIndex(where: { $0.event.canonicalDay == days[dayIndex] }) {
                    delegate?.menuPickerSheetViewController(self, didSelectMenuChoiceAt: eventIndex)
                } else {
                    // fallback for no events (error state and closed for the day state)
                    delegate?.menuPickerSheetViewController(self, didSelectMenuChoiceAt: nil)
                }
            }
        }
        addTextButton(title: "Reset") { [self] in
            delegate?.menuPickerSheetViewControllerDidResetMenuChoice(self)
        }

        updateDayPickerCellsFromState()
    }

    /// Adds calendar with selectable dates.
    private func addDayPickerView() {
        dayPickerView.layoutMargins = .zero

        for (i, day) in days.enumerated() {
            let cell = MenuDayPickerCell()
            cell.weekdayLabel.text = weekdayFormatter.string(from: day.date()).uppercased()
            cell.dayLabel.content.text = "\(day.day)"
            cell.tap { [self] _ in
                didTapDayPickerCellAt(at: i)
            }
            dayPickerView.addCell(cell)
        }

        stackView.addArrangedSubview(dayPickerView)
    }

    private func setState(menuChoices: [MenuChoice], selectedMenuIndex: Int?) {
        days = []
        for i in 0 ... 6 {
            days.append(Day().advanced(by: i))
        }

        if let selectedMenuIndex = selectedMenuIndex,
           selectedMenuIndex >= 0,
           selectedMenuIndex < menuChoices.count {
            let selectedDay = menuChoices[selectedMenuIndex].event.canonicalDay
            // Keeps the day picker selection in sync with the preselected menu
            selectedDayIndex = days.firstIndex(where: { $0 == selectedDay })
            self.selectedMenuIndex = selectedMenuIndex
        } else {
            selectedDayIndex = nil
            self.selectedMenuIndex = nil
        }

        self.menuChoices = menuChoices
    }

    private func updateDayPickerCellsFromState() {
        for (i, cell) in dayPickerView.cells.enumerated() {
            let day = days[i]

            let isSelected = i == selectedDayIndex
            let isToday = day == Day()

            if isToday {
                if isSelected {
                    cell.dayLabel.content.textColor = UIColor.Eatery.default00
                    cell.dayLabel.cornerRadiusView.backgroundColor = UIColor.Eatery.blue
                } else {
                    cell.dayLabel.content.textColor = UIColor.Eatery.blue
                    cell.dayLabel.cornerRadiusView.backgroundColor = nil
                }
            } else {
                if isSelected {
                    cell.dayLabel.content.textColor = UIColor.Eatery.default00
                    cell.dayLabel.cornerRadiusView.backgroundColor = UIColor.Eatery.primaryText
                } else {
                    cell.dayLabel.content.textColor = UIColor.Eatery.primaryText
                    cell.dayLabel.cornerRadiusView.backgroundColor = nil
                }
            }
        }
    }

    private func filterMenuChoices(on day: Day) -> [MenuChoice] {
        menuChoices.filter {
            $0.event.canonicalDay == day && $0.event.menu != nil && !($0.event.menu?.categories.isEmpty ?? true)
        }.sorted { lhs, rhs in
            lhs.event.startTimestamp < rhs.event.startTimestamp
        }
    }

    private func maxMenuChoices() -> Int {
        days.map { filterMenuChoices(on: $0).count }.max() ?? 0
    }

    private func addMenuChoiceViews() {
        if maxMenuChoices() != 1 {
            for i in 0 ..< maxMenuChoices() {
                if i != 0 {
                    stackView.addArrangedSubview(HDivider())
                }

                let menuChoiceView = MenuChoiceView()
                menuChoiceView.layoutMargins = .zero
                stackView.addArrangedSubview(menuChoiceView)
                menuChoiceView.tap { [self] _ in
                    didTapMenuChoiceView(at: i)
                }
                menuChoiceViews.append(menuChoiceView)
            }
        }

        updateMenuChoiceViewsFromState()
    }

    private func updateMenuChoiceViewsFromState() {
        let menuChoicesOnDay: [MenuChoice]
        if let index = selectedDayIndex {
            menuChoicesOnDay = filterMenuChoices(on: days[index])
        } else {
            menuChoicesOnDay = []
        }

        for (i, view) in menuChoiceViews.enumerated() {
            if i < menuChoicesOnDay.count {
                let menuChoice = menuChoicesOnDay[i]
                view.descriptionLabel.text = menuChoice.description
                view.timeLabel.text = EateryFormatter.default.formatEventTime(menuChoice.event)

                if let selectedMenuIndex = selectedMenuIndex, menuChoices[selectedMenuIndex] === menuChoice {
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

    /// Controls selection of dates.
    private func didTapDayPickerCellAt(at index: Int) {
        let menuChoicesOnDay = filterMenuChoices(on: days[index])

        if selectedDayIndex == index {
            return
        }

        selectedDayIndex = index
        // Looks at the first available menu for the tapped day
        if let menuChoice = menuChoicesOnDay.first,
           let idx = menuChoices.firstIndex(where: { $0 === menuChoice }) {
            selectedMenuIndex = idx
        } else {
            selectedMenuIndex = nil
        }

        updateDayPickerCellsFromState()
        updateMenuChoiceViewsFromState()
    }

    private func didTapMenuChoiceView(at index: Int) {
        guard let dayIndex = selectedDayIndex else {
            return
        }

        let menuChoicesOnDay = filterMenuChoices(on: days[dayIndex])

        guard index >= 0, index < menuChoicesOnDay.count else {
            return
        }

        let menuChoice = menuChoicesOnDay[index]
        selectedMenuIndex = menuChoices.firstIndex(where: { $0 === menuChoice })
        updateMenuChoiceViewsFromState()
    }
}
