//
//  Account.swift
//  Eatery Blue
//
//  Created by William Ma on 1/6/22.
//

import Foundation

public struct AccountsResponse: Codable {
    public let accounts: [String : Account?]
    
    public let transactions: [Transaction]
}

public struct Account: Codable {

    public let accountType: AccountType
    public let balance: Double

    enum CodingKeys: String, CodingKey {
        case name
        case balance
    }

    public init(accountType: AccountType, balance: Double) {
        self.accountType = accountType
        self.balance = balance
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode balance normally
        balance = try container.decode(Double.self, forKey: .balance)

        // Decode the string "name" → convert to enum
        let nameString = try container.decode(String.self, forKey: .name)
        guard let type = AccountType.fromBackendName(nameString) else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [CodingKeys.name],
                      debugDescription: "Unknown account name: \(nameString)")
            )
        }
        self.accountType = type
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(balance, forKey: .balance)
        try container.encode(accountType.description, forKey: .name)
    }
    
}
