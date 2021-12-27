//
//  HoursSheetViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/25/21.
//

import UIKit

class HoursSheetViewController: SheetViewController {

    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .eatery
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    func setUp(_ schedule: Schedule<Event>) {
        addHeader(title: "Hours", image: UIImage(named: "Clock"))
        addStatusLabel(EateryFormatter.default.formatStatus(schedule.currentStatus()))
        addSchedule(schedule)
        setCustomSpacing(24)
        addPillButton(title: "Close", style: .regular) { [self] in
            dismiss(animated: true)
        }
        addTextButton(title: "Report an issue") {
        }
    }

    private func addSchedule(_ schedule: Schedule<Event>) {
        let current = Day()

        var dayToDescription: [Day: String] = [:]
        for offset in 0...6 {
            dayToDescription[current.addingDays(offset)] =
                EateryFormatter.default.formatSchedule(schedule.onDay(current.addingDays(offset)))
        }

        var weekdayToDay: [Int: Day] = [:]
        for day in dayToDescription.keys {
            weekdayToDay[day.weekday()] = day
        }

        var consolidated: [(start: Day, end: Day, String)] = []
        var i = 0
        let weekdays = weekdayToDay.keys.sorted()
        while i < weekdays.count {
            let start = i
            let description = dayToDescription[weekdayToDay[weekdays[i]]!]!

            while i + 1 < weekdays.count, dayToDescription[weekdayToDay[weekdays[i + 1]]!]! == description {
                i += 1
            }

            let end = i
            consolidated.append((start: weekdayToDay[weekdays[start]]!, end: weekdayToDay[weekdays[end]]!, description))

            i += 1
        }

        for (start, end, description) in consolidated {
            if start == end {
                let weekday = weekdayFormatter.string(from: start.date())
                addTextSection(title: weekday, description: description)

            } else {
                let start = weekdayFormatter.string(from: start.date())
                let end = weekdayFormatter.string(from: end.date())

                if weekdays.count == 2 {    
                    addTextSection(title: "\(start), \(end)", description: description)
                } else {
                    addTextSection(title: "\(start) to \(end)", description: description)
                }
            }
        }
    }

    private func addStatusLabel(_ attributedText: NSAttributedString) {
        let label = UILabel()
        label.attributedText = attributedText
        label.font = .preferredFont(for: .body, weight: .semibold)
        stackView.addArrangedSubview(label)
    }

}
