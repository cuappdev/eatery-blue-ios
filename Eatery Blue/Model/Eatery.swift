//
//  Eatery.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import Foundation

struct Event: Codable, Hashable {

    var canonicalDay: Day
    var startTimestamp: TimeInterval
    var endTimestamp: TimeInterval
    var description: String?
    var menu: Menu?

    var startDate: Date {
        Date(timeIntervalSince1970: startTimestamp)
    }

    var endDate: Date {
        Date(timeIntervalSince1970: endTimestamp)
    }

    init(
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

struct Eatery: Codable, Hashable {

    var name: String = ""
    var locationDescription: String?
    var imageUrl: URL?
    var menuSummary: String?
    var paymentMethods: Set<PaymentMethod> = []
    var campusArea: String?
    var events: [Event] = []
    var location: EateryLocation?
    var waitTimesByDay: [Day: WaitTimes] = [:]

}

struct Menu: Codable, Hashable {

    let categories: [MenuCategory]

}

struct MenuCategory: Codable, Hashable {

    let category: String
    let items: [MenuItem]

}

struct MenuItem: Codable, Hashable {

    let healthy: Bool
    let name: String
    let description: String?
    let price: Int?
    let isSearchable: Bool

    init(healthy: Bool, name: String, description: String? = nil, price: Int? = nil, isSearchable: Bool = true) {
        self.healthy = healthy
        self.name = name
        self.description = description
        self.price = price
        self.isSearchable = isSearchable
    }

}

enum PaymentMethod: Codable, Hashable {

    case mealSwipes
    case brbs
    case cash
    case credit

}
