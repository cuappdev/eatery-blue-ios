//
//  MenuCategory.swift
//  EateryModel
//
//  Created by Peter Bidoshi on 1/28/26.
//

import Foundation

public struct MenuCategory: Codable, Hashable {
    let id: Int

    public let name: String

    let createdAt: Date

    let eventId: Int

    public let items: [MenuItem]
}
