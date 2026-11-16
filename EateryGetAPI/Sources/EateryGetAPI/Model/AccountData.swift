//
//  AccountData.swift
//
//
//  Created by Arielle Nudelman on 9/18/26.
//

/// Accounts for the UI, plus optional cashless `patronId` for barcode generation.
/// `patronId` must not be shown on screen or logged.
public struct AccountData {
    public let accounts: [Account]

    /// Numeric GET account id from any transaction; nil if none are available.
    public let patronId: String?

    public init(accounts: [Account], patronId: String?) {
        self.accounts = accounts
        self.patronId = patronId
    }
}
