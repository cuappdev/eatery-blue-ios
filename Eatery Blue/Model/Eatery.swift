//
//  Eatery.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//
//  This file is intended to house pure data structs relating to eateries. 

import os.log
import Foundation

// A day, specifically in New York timezone
struct Day: Codable, Hashable {

    let year: Int
    let month: Int
    let day: Int

    init(date: Date = Date()) {
        let components = Calendar.eatery.dateComponents([.year, .month, .day], from: date)
        self.year = components.year ?? 0
        self.month = components.month ?? 0
        self.day = components.day ?? 0
    }

    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    func date(hour: Int? = nil, minute: Int? = nil) -> Date {
        let components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)

        guard let date = Calendar.eatery.date(from: components) else {
            os_log(.fault, "Day: could not form date from components %@", String(reflecting: components))
            return Date()
        }

        return date
    }

    func addingDays(_ days: Int) -> Day {
        let currentDate = date()

        guard let date = Calendar.eatery.date(byAdding: .day, value: days, to: currentDate) else {
            os_log(.fault, "Day: could not add %d days to %@", days, String(reflecting: currentDate))
            return self
        }

        return Day(date: date)
    }

    func startOfWeek() -> Day {
        let components = DateComponents(weekday: 0)

        guard let date = Calendar.eatery.nextDate(
            after: date(),
            matching: components,
            matchingPolicy: .nextTime,
            direction: .backward
        ) else {
            os_log(.fault, "Day: could not find start of week for %@", String(reflecting: self))
            return self
        }

        return Day(date: date)
    }

    func weekday() -> Int {
        Calendar.eatery.component(.weekday, from: date())
    }

}

// To deal with different time zones, we should only ever perform arithmetic and comparisons using the start and end
// timestamps, which are UTC Unix epoch timestamps. Think carefully about different timezones when using the
// canonicalDay, as tempting (and convenient) as it may be.

class Event {

    var canonicalDay: Day
    var startTimestamp: TimeInterval
    var endTimestamp: TimeInterval
    var description: String?
    var menu: Menu?

    var startDate: Date {
        Date(timeIntervalSince1970: startTimestamp)
    }

    var endDate: Date {
        Date(timeIntervalSince1970: endTimestamp)
    }

    init(
        canonicalDay: Day,
        startTimestamp: TimeInterval,
        endTimestamp: TimeInterval,
        description: String? = nil,
        menu: Menu? = nil
    ) {
        self.canonicalDay = canonicalDay
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.description = description
        self.menu = menu
    }

}

class Eatery {

    var name: String = ""
    var building: String?
    var imageUrl: URL?
    var menuSummary: String?
    var paymentMethods: Set<PaymentMethod> = []
    var campusArea: String?
    var events: [Event] = []
    var latitude: Double?
    var longitude: Double?

    var schedule: Schedule {
        Schedule(events)
    }

}

struct Menu: Codable {

    let categories: [MenuCategory]

}

struct MenuCategory: Codable {

    let category: String
    let items: [MenuItem]

}

struct MenuItem: Codable {

    let healthy: Bool
    let name: String
    let description: String?
    let price: Int?

    init(healthy: Bool, name: String, description: String? = nil, price: Int? = nil) {
        self.healthy = healthy
        self.name = name
        self.description = description
        self.price = price
    }

}

enum PaymentMethod: Codable {

    case mealSwipes
    case brbs
    case cash
    case credit

}
