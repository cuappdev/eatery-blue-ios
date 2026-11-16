//
//  AccountData.swift
//
//
//  Created by Arielle Nudelman on 9/18/26.
//

public struct AccountData {
    public let accounts: [Account]
    public let patronId: String?

    public init(accounts: [Account], patronId: String?) {
        self.accounts = accounts
        self.patronId = patronId
    }
}
