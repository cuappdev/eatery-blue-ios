//
//  GetToModel.swift
//  Eatery Blue
//
//  Created by William Ma on 1/6/22.
//

import Foundation

enum GetToModel {

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.calendar = .eatery
        return dateFormatter
    }()

    static func convert(getAccounts: [Get.RawAccount], getTransactions: [Get.RawTransaction]) -> [Account] {
        let transactions = convert(getTransactions)

        var accounts: [Account] = []
        
        for getAccount in getAccounts {
            guard let accountType = parseAccountType(from: getAccount.accountDisplayName) else {
                continue
            }

            accounts.append(Account(
                accountType: accountType,
                balance: getAccount.balance,
                transactions: transactions.filter { $0.accountType == accountType }
            ))
        }

        return accounts
    }

    static func convert(_ getTransactions: [Get.RawTransaction]) -> [Account.Transaction] {
        var transactions: [Account.Transaction] = []

        for getTransaction in getTransactions {
            guard let location = getTransaction.locationName,
                  let dateString = getTransaction.actualDate,
                  let date = dateFormatter.date(from: dateString),
                  let amount = getTransaction.amount,
                  let accountType = parseAccountType(from: getTransaction.accountName)
            else {
                continue
            }

            transactions.append(Account.Transaction(
                location: location,
                date: date,
                amount: amount,
                accountType: accountType
            ))
        }

        return transactions
    }

    static func parseAccountType(from getAccountDisplayName: String?) -> Account.AccountType? {
        guard let name = getAccountDisplayName else {
            return nil
        }

        if name.contains("City Bucks") {
            return .cityBucks
        }
        if name.contains("Big Red Bucks") {
            return .bigRedBucks
        }
        if name.contains("Laundry") {
            return .laundry
        }

        if name.contains("Unlimited") {
            return .unlimited
        }
        if name.contains("Traditional") {
            return .bearTraditional
        }
        if name.contains("Choice") {
            return .bearChoice
        }
        if name.contains("Basic") {
            return .bearBasic
        }

        if name.contains("Off") {
            return .offCampusValue
        }
        if name.contains("Flex") {
            return .flex
        }

        return nil
    }

}
