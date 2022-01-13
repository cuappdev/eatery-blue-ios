//
//  MenuItem.swift
//  
//
//  Created by William Ma on 1/12/22.
//

import Foundation

public struct MenuItem: Codable, Hashable {

    public let description: String?

    public let healthy: Bool

    public let name: String

    public let price: Double?

    public init(description: String? = nil, healthy: Bool, name: String, price: Double? = nil) {
        self.description = description
        self.healthy = healthy
        self.name = name
        self.price = price
    }

}
