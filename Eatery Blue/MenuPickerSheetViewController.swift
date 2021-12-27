//
//  MenuPickerSheetViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/26/21.
//

import UIKit

protocol MenuPickerSheetViewControllerDelegate: AnyObject {

    func menuPickerSheetViewController(_ vc: MenuPickerSheetViewController, didSelectMenuChoiceAt index: Int)
    func menuPickerSheetViewControllerDidResetMenuChoice(_ vc: MenuPickerSheetViewController)

}

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

    private let dayPickerView = DayPickerView()

    weak var delegate: MenuPickerSheetViewControllerDelegate?

    private var days: [Day] = []
    private var selectedDayIndex: Int?

    private var menuChoices: [MenuChoice] = []
    private var selectedMenuIndex: Int?

    private var menuChoiceViews: [MenuChoiceView] = []

    func setUp(menuChoices: [MenuChoice], selectedMenuIndex: Int? = nil) {
        setState(menuChoices: menuChoices, selectedMenuIndex: selectedMenuIndex)

        addHeader(title: "Menus")
        addDayPickerView()
        addMenuChoiceViews()
        addPillButton(title: "Show menu", style: .prominent) { [self] in
            if let selectedIndex = self.selectedMenuIndex {
                delegate?.menuPickerSheetViewController(self, didSelectMenuChoiceAt: selectedIndex)
            }
        }
        addTextButton(title: "Reset") { [self] in
            delegate?.menuPickerSheetViewControllerDidResetMenuChoice(self)
        }

        updateDayPickerCellsFromState()
    }

    private func addDayPickerView() {
        dayPickerView.layoutMargins = .zero

        for (i, day) in days.enumerated() {
            let cell = DayPickerCell()
            cell.weekdayLabel.text = weekdayFormatter.string(from: day.date()).uppercased()
            cell.dayLabel.content.text = "\(day.day)"
            cell.on(UITapGestureRecognizer()) { [self] _ in
                selectedDayIndex = i
                updateDayPickerCellsFromState()
                updateMenuChoiceViewsFromState()
            }
            dayPickerView.addCell(cell)
        }

        stackView.addArrangedSubview(dayPickerView)
    }

    private func setState(menuChoices: [MenuChoice], selectedMenuIndex: Int?) {
        days = []
        for i in 0...6 {
            days.append(Day().addingDays(i))
        }

        if let selectedMenuIndex = selectedMenuIndex {
            let selectedDay = menuChoices[selectedMenuIndex].event.canonicalDay

            selectedDayIndex = days.firstIndex(where: { day in
                day == selectedDay
            })
        }

        self.menuChoices = menuChoices
        self.selectedMenuIndex = selectedMenuIndex
    }

    private func updateDayPickerCellsFromState() {
        for (i, cell) in dayPickerView.cells.enumerated() {
            let day = days[i]

            if i == selectedDayIndex {
                cell.dayLabel.content.textColor = .white
                cell.dayLabel.clippingView.backgroundColor = UIColor(named: "Black")
            } else if day == Day() {
                cell.dayLabel.content.textColor = UIColor(named: "EateryBlue")
                cell.dayLabel.clippingView.backgroundColor = nil
            } else {
                cell.dayLabel.content.textColor = UIColor(named: "Black")
                cell.dayLabel.clippingView.backgroundColor = nil
            }
        }
    }

    private func filterMenuChoices(on day: Day) -> [MenuChoice] {
        menuChoices.filter {
            $0.event.canonicalDay == day
        }.sorted { lhs, rhs in
            lhs.event.startTimestamp < rhs.event.startTimestamp
        }
    }

    private func maxMenuChoices() -> Int {
        days.map { filterMenuChoices(on: $0).count }.max() ?? 0
    }

    private func addMenuChoiceViews() {
        for i in 0..<maxMenuChoices() {
            if i != 0 {
                stackView.addArrangedSubview(HDivider())
            }

            let menuChoiceView = MenuChoiceView()
            menuChoiceView.layoutMargins = .zero
            stackView.addArrangedSubview(menuChoiceView)
            menuChoiceView.on(UITapGestureRecognizer()) { [self] _ in
                didSelectMenuChoiceView(at: i)
            }
            menuChoiceViews.append(menuChoiceView)
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
                view.descriptionLabel.text = "-"
                view.timeLabel.text = "-"
                view.imageView.image = nil
            }
        }
    }

    private func didSelectMenuChoiceView(at index: Int) {
        guard let dayIndex = selectedDayIndex else {
            return
        }

        let menuChoicesOnDay = filterMenuChoices(on: days[dayIndex])

        guard 0 <= index, index < menuChoicesOnDay.count else {
            return
        }

        let menuChoice = menuChoicesOnDay[index]
        selectedMenuIndex = menuChoices.firstIndex(where: { $0 === menuChoice })
        updateMenuChoiceViewsFromState()
    }

}
