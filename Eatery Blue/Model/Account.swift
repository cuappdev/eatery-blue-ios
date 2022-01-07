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
    
    var brbBalance: Double = 0
    var cityBucksBalance: Double = 0
    var laundryBalance: Double = 0

    var mealSwipeTransactions: [MealSwipeTransaction] = []
    var brbTransactions: [CurrencyTransaction] = []
    var cityBucksTransactions: [CurrencyTransaction] = []
    var laundryTransactions: [CurrencyTransaction] = []

}
