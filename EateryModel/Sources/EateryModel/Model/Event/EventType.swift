//
//  EventType.swift
//  EateryModel
//
//  Created by Peter Bidoshi on 1/28/26.
//

import Foundation

public enum EventType: String, Codable, CaseIterable {
    case availableAllDay = "AVAILABLE_ALL_DAY"

    case breakfast = "BREAKFAST"

    case brunch = "BRUNCH"

    case dinner = "DINNER"

    case empty = "EMPTY"

    case lateDinner = "LATE_NIGHT"

    case lateLunch = "LATE_LUNCH"

    case lunch = "LUNCH"

    case open = "OPEN"

    case general = "GENERAL" // Used for dummy event for Cafe eateries (ones with no menus)

    case pants = "PANTS" // Pants

    public var description: String {
        switch self {
        case .availableAllDay:
            return "Available All Day"
        case .breakfast:
            return "Breakfast"
        case .brunch:
            return "Brunch"
        case .dinner:
            return "Dinner"
        case .empty:
            return "No Event"
        case .lateDinner:
            return "Late Dinner"
        case .lateLunch:
            return "Late Lunch"
        case .lunch:
            return "Lunch"
        case .open:
            return "Open"
        case .general:
            return "General"
        case .pants:
            return "Pants"
        }
    }

    /**
     Determines the correct meal based on the time of day.

     This function gets the time of day from Date and returns a string of the meal type. If it is a specific meal time,
     that meal time is returned, and if it is not a specific meal time, the next meal time is returned.

     - Returns: If it is 10:30 pm - 10:29 am inclusive, breakfest is returned. If it is 10:30 am - 2:29 pm inclusive,
                lunch is returned. If it is 2:30 pm - 8:29 pm inclusive, dinner is returned.
                If it is 8:30 pm - 10:29 pm inclusive, late dinner is returned.
     */
    public static func mealFromTime() -> EventType {
        let calendar = Calendar.current
        let date = Date()

        let timeToday = { (hour: Int, minute: Int) -> Date in
            return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date
        }

        let lunchStart = timeToday(10, 30)
        let dinnerStart = timeToday(14, 30)
        let lateDinnerStart = timeToday(20, 30)
        let nextBreakfastStart = timeToday(22, 30)

        if date >= lunchStart && date < dinnerStart {
            return .lunch
        } else if date >= dinnerStart && date < lateDinnerStart {
            return .dinner
        } else if date >= lateDinnerStart && date < nextBreakfastStart {
            return .lateDinner
        } else {
            return .breakfast
        }
    }
}
