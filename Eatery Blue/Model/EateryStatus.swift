//
//  EateryStatus.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import Foundation

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
            date <= event.startDate && (day != nil ? event.canonicalDay == day : true)
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
            event.endDate <= date && (day != nil ? event.canonicalDay == day : true)
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
