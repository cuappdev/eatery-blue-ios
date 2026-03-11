//
//  FinancialsResponse.swift
//  EateryGetAPI
//
//  Created by Adelynn Wu on 3/6/26.
//

public struct FinancialsResponse: Decodable {
    public let accounts: Accounts
    public let transactions: [FinancialTransaction]
}
