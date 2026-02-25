//
//  AccountType.swift
//  
//
//  Created by William Ma on 1/12/22.
//

public enum AccountType: Codable {
    
    case mealPlan
    case bigRedBucks
    case cityBucks
    case laundry

    var description: String {
        switch self {
        case .mealPlan: return "Meal Swipes"
        case .bigRedBucks: return "Big Red Bucks"
        case .cityBucks: return "City Bucks"
        case .laundry: return "Laundry"
        }
    }

    static func fromBackendName(_ name: String) -> AccountType? {
        switch name {
        case "Meal Swipes": return .mealPlan
        case "Big Red Bucks": return .bigRedBucks
        case "City Bucks": return .cityBucks
        case "Laundry": return .laundry
        default: return nil
        }
    }
}
