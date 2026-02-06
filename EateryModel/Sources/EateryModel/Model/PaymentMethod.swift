//
//  PaymentMethod.swift
//
//
//  Created by Peter Bidoshi on 1/28/26.
//

import Foundation

public enum PaymentMethod: String, Codable, Hashable {
    case mealSwipe = "MEAL_SWIPE"

    case cash = "CASH"

    case card = "CARD"

    case brbs = "BRB"

    case free = "FREE"

    public var description: String {
        switch self {
        case .mealSwipe:
            return "Meal Swipe"
        case .cash:
            return "Cash"
        case .card:
            return "Card"
        case .brbs:
            return "BRBs"
        case .free:
            return "Free"
        }
    }
}
