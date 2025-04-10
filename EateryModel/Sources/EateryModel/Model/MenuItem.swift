//
//  MenuItem.swift
//  
//
//  Created by William Ma on 1/12/22.
//

import Foundation

public struct MenuItem: Codable, Hashable {

    public let id: Int

    public let description: String?

    public let healthy: Bool

    public let name: String

    public let price: Double?

    public let allergens: [String]

    public let dietaryPreferences: [String]

    public init(id: Int, description: String? = nil, healthy: Bool, name: String, price: Double? = nil, allergens: [String] = [], dietaryPreferences: [String] = []) {
        self.id = id
        self.description = description
        self.healthy = healthy
        self.name = name
        self.price = price
        self.allergens = allergens
        self.dietaryPreferences = dietaryPreferences
    }

}
