//
//  Eatery.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import Foundation

public struct Event: Codable, Hashable {

    public var canonicalDay: Day

    public var startTimestamp: TimeInterval

    public var endTimestamp: TimeInterval

    public var description: String?

    public var menu: Menu?

    public var startDate: Date {
        Date(timeIntervalSince1970: startTimestamp)
    }

    public var endDate: Date {
        Date(timeIntervalSince1970: endTimestamp)
    }

    public init(
        canonicalDay: Day,
        startTimestamp: TimeInterval,
        endTimestamp: TimeInterval,
        description: String? = nil,
        menu: Menu? = nil
    ) {
        self.canonicalDay = canonicalDay
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.description = description
        self.menu = menu
    }

}

public struct Eatery: Codable, Hashable {

    public let campusArea: String?

    public let events: [Event]

    public let id: Int64

    public let imageUrl: URL?

    public let latitude: Double?

    public let locationDescription: String?

    public let longitude: Double?

    public let menuSummary: String?

    public let name: String

    public let paymentMethods: Set<PaymentMethod>

    public let waitTimesByDay: [Day: WaitTimes]

    public init(
        campusArea: String? = nil,
        events: [Event] = [],
        id: Int64,
        imageUrl: URL? = nil,
        latitude: Double? = nil,
        locationDescription: String? = nil,
        longitude: Double? = nil,
        menuSummary: String?,
        name: String,
        paymentMethods: Set<PaymentMethod> = [],
        waitTimesByDay: [Day: WaitTimes] = [:]
    ) {
        self.campusArea = campusArea
        self.events = events
        self.id = id
        self.imageUrl = imageUrl
        self.latitude = latitude
        self.locationDescription = locationDescription
        self.longitude = longitude
        self.menuSummary = menuSummary
        self.name = name
        self.paymentMethods = paymentMethods
        self.waitTimesByDay = waitTimesByDay
    }

}

public struct Menu: Codable, Hashable {

    public let categories: [MenuCategory]

    public init(categories: [MenuCategory]) {
        self.categories = categories
    }

}

public struct MenuCategory: Codable, Hashable {

    public let category: String

    public let items: [MenuItem]

    public init(category: String, items: [MenuItem]) {
        self.category = category
        self.items = items
    }

}

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

public enum PaymentMethod: Codable, Hashable {

    case mealSwipes

    case brbs

    case cash

    case credit

}
