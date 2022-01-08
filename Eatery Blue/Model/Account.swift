//
//  Account.swift
//  Eatery Blue
//
//  Created by William Ma on 1/6/22.
//

import Foundation

struct Account: Codable {

    enum MealPlanType: String, Codable {
        case perSemester
        case perWeek
        case unlimited
    }

    struct MealSwipeTransaction: Codable {
        let location: String
        let date: String
    }

    struct CurrencyTransaction: Codable {
        let location: String
        let date: Date
        let amount: Double
    }

    var mealPlan: MealPlanType?
    var mealSwipesRemaining: Int?
    
    var brbBalance: Double?
    var cityBucksBalance: Double?
    var laundryBalance: Double?

    var mealSwipeTransactions: [MealSwipeTransaction] = []
    var brbTransactions: [CurrencyTransaction] = []
    var cityBucksTransactions: [CurrencyTransaction] = []
    var laundryTransactions: [CurrencyTransaction] = []

}
