//
//  Day.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import os.log
import Foundation

// A day, specifically in New York timezone
struct Day {

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

    init?(string: String) {
        let components = string.split(separator: "-", maxSplits: 2).map(String.init).map(Int.init)
        guard components.count == 3,
              let year = components[0],
              let month = components[1],
              let day = components[2]
        else {
            return nil
        }

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

extension Day: Codable {

}

extension Day: Hashable {

}

extension Day: Strideable {

    func advanced(by n: Int) -> Day {
        let currentDate = date()

        guard let date = Calendar.eatery.date(byAdding: .day, value: n, to: currentDate) else {
            os_log(.error, "%@: could not add %d days to %@", #file, n, String(reflecting: currentDate))
            return self
        }

        return Day(date: date)
    }

    func distance(to other: Day) -> Int {
        if let day = Calendar.eatery.dateComponents([.day], from: date(), to: other.date()).day {
            return day
        } else {
            os_log(
                .error,
                "%@: Unable to compute distance between %@ and %@",
                #file,
                String(reflecting: date()),
                String(reflecting: other.date())
            )
            return 0
        }
    }

}