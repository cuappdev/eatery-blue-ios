//
//  EateryPresentation.swift
//  Eatery Blue
//
//  Created by William Ma on 12/26/21.
//
//  This file is intended to hold any logic related to the presentation of eateries, things that can mostly be derived
//  from the data stored in each eatery.

import UIKit

enum EateryStatus {

    case closed
    case openingSoon(Event)
    case open(Event)
    case closingSoon(Event)

}

struct Schedule {

    let events: [Event]

    var isEmpty: Bool {
        events.isEmpty
    }

    init(_ array: [Event]) {
        self.events = array
    }

    func at(_ date: Date) -> Event? {
        if let i = indexOfEvent(at: date) {
            return events[i]
        } else {
            return nil
        }
    }

    func indexOfEvent(at date: Date) -> Int? {
        let timestamp = date.timeIntervalSince1970
        return events.firstIndex { event in
            event.startTimestamp <= timestamp && timestamp <= event.endTimestamp
        }
    }

    func indexOfCurrent() -> Int? {
        indexOfEvent(at: Date())
    }

    func current() -> Event? {
        at(Date())
    }

    func onDay(_ day: Day) -> Schedule {
        Schedule(events.filter { event in
            event.canonicalDay == day
        })
    }

    func indexOfNextEvent(_ date: Date = Date()) -> Int? {
        let timestamp = date.timeIntervalSince1970

        return events.enumerated().filter {
            timestamp < $0.element.startTimestamp
        }.min { lhs, rhs in
            lhs.element.startTimestamp < rhs.element.startTimestamp
        }?.offset
    }

    func nextEvent(_ date: Date = Date()) -> Event? {
        if let index = indexOfNextEvent(date) {
            return events[index]
        } else {
            return nil
        }
    }

    func indexOfSalientEvent(_ date: Date = Date()) -> Int? {
        indexOfEvent(at: date) ?? indexOfNextEvent(date) ?? (!events.isEmpty ? events.count - 1 : nil)
    }

    func statusAt(_ date: Date) -> EateryStatus {
        let timestamp = date.timeIntervalSince1970

        if let event = at(date) {
            // The eatery is open. Is it closing soon?
            let timeUntilClose = event.endTimestamp - timestamp

            if timeUntilClose <= 60 * 60 {
                return .closingSoon(event)
            } else {
                return .open(event)
            }

        } else if let event = nextEvent(date) {
            // The eatery is closed. Is it opening soon?

            let timeUntilOpen = event.startTimestamp - timestamp

            if timeUntilOpen <= 60 * 60 {
                return .openingSoon(event)
            } else {
                return .closed
            }

        } else {
            return .closed

        }
    }

    func currentStatus() -> EateryStatus {
        statusAt(Date())
    }

}

class EateryFormatter {

    static let `default` = EateryFormatter()

    private let timeFormatter = DateFormatter()

    init() {
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        timeFormatter.calendar = .eatery
    }

    func formatStatus(_ status: EateryStatus) -> NSAttributedString {
        switch status {
        case .open(let event):
            let timeString = timeFormatter.string(from: event.endDate)
            return NSAttributedString(
                string: "Open until \(timeString)",
                attributes: [.foregroundColor: UIColor(named: "EateryOrange") as Any]
            )

        case .closed:
            return NSAttributedString(
                string: "Closed",
                attributes: [.foregroundColor: UIColor(named: "EateryRed") as Any]
            )

        case .openingSoon(let event):
            let timeString = timeFormatter.string(from: event.startDate)
            return NSAttributedString(
                string: "Opening at \(timeString)",
                attributes: [.foregroundColor: UIColor(named: "EateryOrange") as Any]
            )

        case .closingSoon(let event):
            let timeString = timeFormatter.string(from: event.endDate)
            return NSAttributedString(
                string: "Closing at \(timeString)",
                attributes: [.foregroundColor: UIColor(named: "EateryOrange") as Any]
            )

        }
    }

    func formatEventTime(_ event: Event) -> String {
        "\(timeFormatter.string(from: event.startDate)) - \(timeFormatter.string(from: event.endDate))"
    }

    func formatSchedule(_ schedule: Schedule) -> String {
        if schedule.isEmpty {
            return "Closed"
        } else {
            return schedule.events.map(formatEventTime(_:)).joined(separator: ", ")
        }
    }

    func formatEatery(_ eatery: Eatery, font: UIFont) -> NSAttributedString {
        let text = NSMutableAttributedString()
        text.append(NSAttributedString(string: eatery.building ?? "--"))
        text.append(NSAttributedString(string: " · "))
        text.append(NSAttributedString(string: "Meal swipes allowed"))
        text.addAttribute(.font, value: font, range: NSRange(location: 0, length: text.length))
        return text
    }

    func formatTimingInfo(_ eatery: Eatery, font: UIFont) -> NSAttributedString {
        let text = NSMutableAttributedString()
        text.append(NSAttributedString(attachment: NSTextAttachment(
            image: UIImage(named: "Watch"),
            scaledToMatch: font
        )))
        text.append(NSAttributedString(string: " 12 min walk"))
        text.append(NSAttributedString(string: " · "))
        text.append(NSAttributedString(string: "4-7 min wait"))
        text.addAttribute(.font, value: font, range: NSRange(location: 0, length: text.length))
        return text
    }

}
