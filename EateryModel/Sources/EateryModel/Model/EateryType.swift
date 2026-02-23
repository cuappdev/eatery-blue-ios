//
//  EateryType.swift
//  EateryModel
//
//  Created by Peter Bidoshi on 1/28/26.
//

public enum EateryType: String, Codable, Hashable {
    case diningRoom = "DINING_ROOM"

    case cafe = "CAFE"

    case coffeeShop = "COFFEE_SHOP"

    case foodCourt = "FOOD_COURT"

    case convenienceStore = "CONVENIENCE_STORE"

    case cart = "CART"

    case general = "GENERAL"

    public var description: String {
        switch self {
        case .diningRoom:
            return "Dining Room"
        case .cafe:
            return "Cafe"
        case .coffeeShop:
            return "Coffee Shop"
        case .foodCourt:
            return "Food Court"
        case .convenienceStore:
            return "Convenience Store"
        case .cart:
            return "Foot Cart"
        case .general:
            return "Other Eatery"
        }
    }
}
