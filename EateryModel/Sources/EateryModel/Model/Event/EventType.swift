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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        guard let hour = Int(dateFormatter.string(from: Date())) else { return .breakfast }
        dateFormatter.dateFormat = "mm"
        guard let minute = Int(dateFormatter.string(from: Date())) else { return .breakfast }
        if hour < 10 || hour == 10 && minute < 30 || hour >= 23 || hour == 22 && minute >= 30 {
            return .breakfast
        } else if hour == 10 && minute >= 30 || hour > 10 && hour < 14 || hour == 14 && minute < 30 {
            return .lunch
        } else if hour == 14 && minute >= 30 || hour > 14 && hour < 20 || hour == 20 && minute < 30 {
            return .dinner
        } else {
            return .lateDinner
        }
    }
}
