//
//  MenuItem.swift
//  EateryModel
//
//  Created by Peter Bidoshi on 1/28/26.
//

import Foundation

public struct MenuItem: Codable, Hashable {
    let id: Int

    public let name: String

    public let basePrice: Double?

    let createdAt: Date

    let categoryId: Int

    public let dietaryPreferences: [DietaryPreference]

    public let allergens: [Allergen]
}
