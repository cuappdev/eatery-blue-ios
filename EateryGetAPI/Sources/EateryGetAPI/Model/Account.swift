//
//  Account.swift
//  Eatery Blue
//
//  Created by William Ma on 1/6/22.
//

public struct Account: Codable {

    public let accountType: AccountType

    public let balance: Double?

    public let transactions: [Transaction]

    public init(accountType: AccountType, balance: Double?, transactions: [Transaction]) {
        self.accountType = accountType
        self.balance = balance
        self.transactions = transactions
    }

}
