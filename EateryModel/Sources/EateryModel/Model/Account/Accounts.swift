//
//  File.swift
//  EateryGetAPI
//
//  Created by Adelynn Wu on 3/5/26.
//

public struct Accounts: Decodable {
    public let brb: FinancialAccount?
    public let cityBucks: FinancialAccount?
    public let laundry: FinancialAccount?
    
    enum CodingKeys: String, CodingKey {
        case brb = "brb"
        case cityBucks = "city_bucks"
        case laundry = "laundry"
    }
}
