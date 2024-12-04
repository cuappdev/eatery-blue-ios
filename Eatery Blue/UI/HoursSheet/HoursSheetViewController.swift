//
//  HoursSheetViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/25/21.
//

import EateryModel
import UIKit

class HoursSheetViewController: SheetViewController {

    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .eatery
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    func setUp(_ eateryId: Int64, _ events: [Event]) {
        addHeader(title: "Hours", image: UIImage(named: "Clock"))
        
        UIHelper.addStatusLabel(to: stackView, attributedText: EateryFormatter.default.formatStatus(EateryStatus(events)))
        UIHelper.addSchedule(events: events, to: self)
                
        setCustomSpacing(24)
        addPillButton(title: "Close", style: .regular) { [self] in
            dismiss(animated: true)
        }
        addTextButton(title: "Report an issue") { [self] in
            let viewController = ReportIssueViewController(eateryId: eateryId)
            viewController.setSelectedIssueType(.incorrectHours)
            present(viewController, animated: true)
        }
    }

    func addSchedule(_ events: [Event]) {
        let current = Day()

        var dayToDescription: [Day: String] = [:]
        for day in stride(from: current, to: current.advanced(by: 7), by: 1) {
            dayToDescription[day] = EateryFormatter.default.formatEventTimes(events.filter {
                $0.canonicalDay == day
            }.sorted(by: { lhs, rhs in
                lhs.startDate < rhs.startDate
            }))
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

}

class UIHelper: SheetViewController {
    static func addStatusLabel(to stackView: UIStackView, attributedText: NSAttributedString) {
        let label = UILabel()
        label.attributedText = attributedText
        label.font = .preferredFont(for: .body, weight: .semibold)
        stackView.addArrangedSubview(label)
    }
    
    static func addSchedule(events: [Event], to viewController: SheetViewController) {
            let current = Day()
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.dateFormat = "EEEE"

            var dayToDescription: [Day: String] = [:]
            for day in stride(from: current, to: current.advanced(by: 7), by: 1) {
                dayToDescription[day] = EateryFormatter.default.formatEventTimes(events.filter {
                    $0.canonicalDay == day
                }.sorted(by: { lhs, rhs in
                    lhs.startDate < rhs.startDate
                }))
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
                    viewController.addTextSection(title: weekday, description: description)
                } else {
                    let start = weekdayFormatter.string(from: start.date())
                    let end = weekdayFormatter.string(from: end.date())

                    if weekdays.count == 2 {
                        viewController.addTextSection(title: "\(start), \(end)", description: description)
                    } else {
                        viewController.addTextSection(title: "\(start) to \(end)", description: description)
                    }
                }
            }
        }
    
    
}
