//
//  Account.swift
//  Eatery Blue
//
//  Created by William Ma on 1/6/22.
//

import Foundation

struct Account: Codable {

    enum AccountType: Codable {

        case cityBucks
        case bigRedBucks
        case laundry

        case unlimited
        case bearTraditional
        case bearChoice
        case bearBasic

        case offCampusValue
        case flex

        var isMealPlan: Bool {
            switch self {
            case .unlimited, .bearTraditional, .bearChoice, .bearBasic, .offCampusValue, .flex: return true
            case .cityBucks, .bigRedBucks, .laundry: return false
            }
        }

    }

    enum TransactionType: Codable {
        case mealSwipe
        case currency
    }

    struct Transaction: Codable {
        let location: String
        let date: Date
        let amount: Double
        let accountType: AccountType
    }

    let accountType: AccountType
    var balance: Double?
    var transactions: [Transaction]

}
