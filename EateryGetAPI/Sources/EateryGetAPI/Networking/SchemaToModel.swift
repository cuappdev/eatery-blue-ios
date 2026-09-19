//
//  SchemaToModel.swift
//  Eatery Blue
//
//  Created by William Ma on 1/6/22.
//

import Foundation

enum SchemaToModel {
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(identifier: "America/New_York") ?? Calendar.current.timeZone
        return dateFormatter
    }()

    // GET wraps every payload like: { "response": { ...actual fields... } }
    private struct NativeStartupResponseWrapper: Decodable {
        let response: Schema.RawNativeStartup
    }

    // Turns GET's JSON bytes into BarcodeConfig.
    // Used by the network call and by tests (tests pass fake JSON, not a live request).
    // Do not log `data` — it contains barcodeSeed.
    static func barcodeConfig(fromNativeStartupData data: Data) throws -> BarcodeConfig {
        let wrapper = try JSONDecoder().decode(NativeStartupResponseWrapper.self, from: data)
        return convert(wrapper.response)
    }

    // Copy the two fields we care about into the public model.
    // Empty seed → nil. Missing offline flag → false (don't show a barcode).
    static func convert(_ raw: Schema.RawNativeStartup) -> BarcodeConfig {
        let seed = raw.barcodeSeed.flatMap { $0.isEmpty ? nil : $0 }
        return BarcodeConfig(
            barcodeSeed: seed,
            enableOfflineBarcodeGeneration: raw.enableOfflineBarcodeGeneration ?? false
        )
    }

    static func convert(getAccounts: [Schema.RawAccount], getTransactions: [Schema.RawTransaction]) -> AccountData {
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

        return AccountData(accounts: accounts, patronId: patronId(from: getTransactions))
    }

    // Use the first non-empty patronId on any raw row, even if that row is not shown.
    static func patronId(from rawTransactions: [Schema.RawTransaction]) -> String? {
        rawTransactions.lazy.compactMap { $0.patronId?.string }.first
    }

    static func convert(_ getTransactions: [Schema.RawTransaction]) -> [Transaction] {
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
                accountType: accountType,
                amount: amount,
                date: date,
                location: location
            ))
        }

        return transactions
    }

    static func parseAccountType(from getAccountDisplayName: String?) -> AccountType? {
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
