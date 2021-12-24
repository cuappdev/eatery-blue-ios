//
//  Eatery.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import Foundation

protocol Eatery: Codable {

    var name: String { get }
    var building: String? { get }
    var imageUrl: URL? { get }
    var menuSummary: String? { get }

}

struct Cafe: Eatery {

    let name: String
    let campusArea: String
    let building: String?
    let events: [CafeEvent]
    let latitude: Double
    let longitude: Double
    let menu: Menu
    let menuSummary: String?
    let imageUrl: URL?

}

struct Day: Codable {

    let year: Int
    let month: Int
    let day: Int

}

struct CafeEvent: Codable {

    let canonicalDate: Day
    let startTimestamp: Int
    let endTimestamp: Int

}

struct DiningHall: Eatery, Codable {

    let name: String
    let campusArea: String
    let events: [DiningHallEvent]
    let latitude: Double
    let longitude: Double
    let building: String?
    let menuSummary: String?
    let imageUrl: URL?

}

struct DiningHallEvent: Codable {

    let description: String
    let canonicalDate: Day
    let startTimestamp: Int
    let endTimestamp: Int
    let menu: Menu

}

struct Menu: Codable {

    let categories: [MenuCategory]

}

struct MenuCategory: Codable {

    let category: String
    let items: [MenuItem]

}

struct MenuItem: Codable {

    let healthy: Bool
    let name: String
    let description: String?
    let price: Int?

}

enum PaymentMethod: Codable {
    case mealSwipes
    case brbs
    case cash
    case credit
}
