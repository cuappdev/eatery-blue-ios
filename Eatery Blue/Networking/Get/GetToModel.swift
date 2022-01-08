//
//  GetToModel.swift
//  Eatery Blue
//
//  Created by William Ma on 1/6/22.
//

import Foundation

enum GetToModel {

    static func convert(getAccounts: [Get.RawAccount], getTransactions: [Get.RawTransaction]) -> Account {
        var account = Account()
        populateMealPlan(&account, getAccounts: getAccounts)
        populateBalances(&account, getAccounts: getAccounts)
        populateTransactions(&account, getTransactions: getTransactions)
        return account
    }

    private static func populateMealPlan(_ account: inout Account, getAccounts: [Get.RawAccount]) {
        let perWeekPlans: [String] = ["Basic", "Choice", "Traditional"]
        let perSemesterPlans: [String] = ["Flex", "Off"] // Off is for Off-Campus
        let unlimitedPlans: [String] = ["Unlimited"]
        let swipePlans: [String] = perWeekPlans + perSemesterPlans + unlimitedPlans

        let mealPlans = getAccounts.filter { getAccount in
            guard let name = getAccount.accountDisplayName,
                  let balance = getAccount.balance,
                  balance >= 0
            else {
                return false
            }

            return swipePlans.contains { swipePlan in
                name.contains(swipePlan)
            }
        }

        // Choose the meal plan with the lowest balance. Break ties by the account name.
        let mealPlan = mealPlans.min { lhs, rhs in
            guard let lhsBalance = lhs.balance, let rhsBalance = rhs.balance,
                  let lhsName = lhs.accountDisplayName, let rhsName = lhs.accountDisplayName
            else {
                return false
            }

            if lhsBalance != rhsBalance {
                return lhsBalance < rhsBalance
            } else {
                return lhsName < rhsName
            }
        }

        if let mealPlan = mealPlan, let name = mealPlan.accountDisplayName, let balance = mealPlan.balance {
            account.mealSwipesRemaining = Int(balance)

            if perWeekPlans.contains(where: { name.contains($0) }) {
                account.mealPlan = .perWeek
            } else if perSemesterPlans.contains(where: { name.contains($0) }) {
                account.mealPlan = .perSemester
            } else if unlimitedPlans.contains(where: { name.contains($0) }) {
                account.mealPlan = .unlimited
            }
        }
    }

    private static func populateBalances(_ account: inout Account, getAccounts: [Get.RawAccount]) {
        for getAccount in getAccounts {
            guard let name = getAccount.accountDisplayName,
                  let balance = getAccount.balance
            else {
                continue
            }

            if name.contains("City Bucks") {
                if let existingBalance = account.cityBucksBalance {
                    account.cityBucksBalance = min(balance, existingBalance)
                } else {
                    account.cityBucksBalance = balance
                }
            } else if name.contains("Laundry") {
                if let existingBalance = account.laundryBalance {
                    account.laundryBalance = min(balance, existingBalance)
                } else {
                    account.laundryBalance = balance
                }
            } else if name.contains("Big Red Bucks") {
                if let existingBalance = account.brbBalance {
                    account.brbBalance = min(balance, existingBalance)
                } else {
                    account.brbBalance = balance
                }
            }
        }
    }

    private static func populateTransactions(_ account: inout Account, getTransactions: [Get.RawTransaction]) {

    }

}
