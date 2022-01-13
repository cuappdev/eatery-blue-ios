//
//  AccountType.swift
//  
//
//  Created by William Ma on 1/12/22.
//

public enum AccountType: Codable {

    case bearBasic

    case bearChoice

    case bearTraditional

    case bigRedBucks

    case cityBucks

    case flex

    case laundry

    case offCampusValue

    case unlimited

    public var isMealPlan: Bool {
        switch self {
        case .unlimited, .bearTraditional, .bearChoice, .bearBasic, .offCampusValue, .flex: return true
        case .cityBucks, .bigRedBucks, .laundry: return false
        }
    }

}
