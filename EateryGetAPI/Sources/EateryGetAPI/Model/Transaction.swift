//
//  Transaction.swift
//  
//
//  Created by William Ma on 1/12/22.
//

import Foundation

public struct Transaction: Codable {

    public let amount: Double
    
    public let accountName: String
    
    public let date: Date

    public let location: String

    public init(amount: Double, accountName: String, date: Date, location: String) {
        self.amount = amount
        self.accountName = accountName
        self.date = date
        self.location = location
    }

}
