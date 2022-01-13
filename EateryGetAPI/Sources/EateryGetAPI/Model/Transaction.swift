//
//  Transaction.swift
//  
//
//  Created by William Ma on 1/12/22.
//

import Foundation

public struct Transaction: Codable {

    public let accountType: AccountType

    public let amount: Double

    public let date: Date

    public let location: String

}
