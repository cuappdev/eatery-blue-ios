//
//  AccountData.swift
//
//
//  Created by Arielle Nudelman on 9/18/26.
//

// Accounts for the UI, plus the cashless key used later to generate barcodes.
// patronId must not be shown on screen or logged.
public struct AccountData {
    public let accounts: [Account]

    // Numeric GET account id, taken from any transaction. nil if there are none.
    public let patronId: String?

    public init(accounts: [Account], patronId: String?) {
        self.accounts = accounts
        self.patronId = patronId
    }
}
