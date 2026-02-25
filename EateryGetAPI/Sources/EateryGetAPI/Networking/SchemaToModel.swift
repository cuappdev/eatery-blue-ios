//
//  SchemaToModel.swift
//  Eatery Blue
//
//  Created by William Ma on 1/6/22.
//

import Foundation

internal enum SchemaToModel {

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(identifier: "America/New_York") ?? Calendar.current.timeZone
        return dateFormatter
    }()

    internal static func convert(getAccounts: [Schema.RawAccount], getTransactions: [Schema.RawTransaction]) -> [Account] {
        let transactions = convert(getTransactions)

        var accounts: [Account] = []
        
        for getAccount in getAccounts {
            guard let accountType = parseAccountType(from: getAccount.accountDisplayName) else {
                continue
            }

            accounts.append(Account(
                accountType: accountType,
                balance: getAccount.balance ?? 0
               // transactions: transactions.filter { $0.accountType == accountType }
            ))
        }

        return accounts
    }

    internal static func convert(_ getTransactions: [Schema.RawTransaction]) -> [Transaction] {
        var transactions: [Transaction] = []

        for getTransaction in getTransactions {
            guard let location = getTransaction.locationName,
                  let dateString = getTransaction.actualDate,
                  let date = dateFormatter.date(from: dateString),
                  let amount = getTransaction.amount,
                  let accountType = parseAccountType(from: getTransaction.accountName)
            else {
                continue
            }

            transactions.append(Transaction(
                amount: amount,
                accountName: accountType.description,
                date: date,
                location: location
            ))
        }

        return transactions
    }

    internal static func parseAccountType(from getAccountDisplayName: String?) -> AccountType? {
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
        
        return nil
    }
}
