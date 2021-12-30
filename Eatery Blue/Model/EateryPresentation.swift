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

    static func index(_ events: [Event], filter isIncluded: (Event) -> Bool, min isLessThan: (Event, Event) -> Bool) -> Int? {
        events.enumerated().filter {
            isIncluded($0.element)
        }.min {
            isLessThan($0.element, $1.element)
        }?.offset
    }

    static func indexOfCurrentEvent(_ events: [Event], date: Date = Date(), on day: Day? = nil) -> Int? {
        events.firstIndex { event in
            event.startDate <= date && date <= event.endDate && (day != nil ? event.canonicalDay == day : true)
        }
    }

    static func currentEvent(_ events: [Event], date: Date = Date(), on day: Day? = nil) -> Event? {
        if let index = indexOfCurrentEvent(events, date: date, on: day) {
            return events[index]
        } else {
            return nil
        }
    }

    static func indexOfNextEvent(_ events: [Event], date: Date = Date(), on day: Day? = nil) -> Int? {
        index(events) { event in
            event.endDate < date && (day != nil ? event.canonicalDay == day : true)
        } min: { lhs, rhs in
            lhs.startDate < rhs.startDate
        }
    }

    static func nextEvent(_ events: [Event], date: Date = Date(), on day: Day? = nil) -> Event? {
        if let index = indexOfNextEvent(events, date: date, on: day) {
            return events[index]
        } else {
            return nil
        }
    }

    static func indexOfPreviousEvent(_ events: [Event], date: Date = Date(), on day: Day? = nil) -> Int? {
        index(events) { event in
            date < event.startDate && (day != nil ? event.canonicalDay == day : true)
        } min: { lhs, rhs in
            rhs.endDate < lhs.endDate
        }
    }

    static func indexOfSalientEvent(_ events: [Event], date: Date = Date(), on day: Day? = nil) -> Int? {
        indexOfCurrentEvent(events, date: date, on: day)
            ?? indexOfNextEvent(events, date: date, on: day)
            ?? indexOfPreviousEvent(events, date: date, on: day)
    }

    case closed
    case openingSoon(Event)
    case open(Event)
    case closingSoon(Event)

    init(_ events: [Event], date: Date = Date()) {
        let timestamp = date.timeIntervalSince1970

        if let event = EateryStatus.currentEvent(events, date: date) {
            // The eatery is open. Is it closing soon?
            let timeUntilClose = event.endTimestamp - timestamp

            if timeUntilClose <= 60 * 60 {
                self = .closingSoon(event)
            } else {
                self = .open(event)
            }

        } else if let event = EateryStatus.nextEvent(events, date: date) {
            // The eatery is closed. Is it opening soon?
            let timeUntilOpen = event.startTimestamp - timestamp

            if timeUntilOpen <= 60 * 60 {
                self = .openingSoon(event)
            } else {
                self = .closed
            }

        } else {
            self = .closed

        }
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

    func formatEventTimes(_ events: [Event]) -> String {
        if events.isEmpty {
            return "Closed"
        } else {
            return events.map(formatEventTime(_:)).joined(separator: ", ")
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

    func formatPaymentMethod(_ paymentMethod: PaymentMethod) -> String {
        switch paymentMethod {
        case .mealSwipes: return "Meal swipes"
        case .brbs: return "BRBs"
        case .cash: return "Cash"
        case .credit: return "Credit"
        }
    }

    func formatPaymentMethods(_ paymentMethods: Set<PaymentMethod>) -> String {
        var components: [String] = []
        
        if paymentMethods.contains(.mealSwipes) {
            components.append("Meal swipes")
        }
        if paymentMethods.contains(.brbs) {
            components.append("BRBs")
        }
        if paymentMethods.contains(.cash) {
            components.append("Cash")
        }
        if paymentMethods.contains(.credit) {
            components.append("Credit")
        }

        return components.joined(separator: ", ")
    }

}
