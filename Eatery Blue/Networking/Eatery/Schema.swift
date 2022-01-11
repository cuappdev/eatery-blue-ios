//
//  Schema.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import Foundation

enum Schema {

    struct APIResponse: Codable {
        let success: Bool
        let data: [Eatery]
        let error: String?
    }

    struct Eatery: Codable {
        let id: Int
        let campusArea: String?
        let events: [Schema.Event]?
        let imageUrl: URL?
        let menuSummary: String?
        let latitude: Double?
        let longitude: Double?
        let location: String?
        let name: String
        let paymentMethods: [Schema.PaymentMethod]?
        let waitTimesByDay: [Schema.WaitTimesByDay]?
        let onlineOrderUrl: URL?
        let alerts: [Alert]?
    }

    enum PaymentMethod: String, Codable {
        case cash
        case brbs
        case swipes
    }

    struct WaitTimesByDay: Codable {
        let canonicalDate: String?
        let waitTimes: [Schema.WaitTimes]?
    }

    struct WaitTimes: Codable {
        let timestamp: Int
        let waitTimeLow: Int
        let waitTimeExpected: Int
        let waitTimeHigh: Int
    }

    struct Event: Codable {
        let description: String?
        let canonicalDate: String
        let startTimestamp: Int
        let endTimestamp: Int
        let menu: [Schema.MenuCategory]?
    }

    struct MenuCategory: Codable {
        let category: String
        let items: [Schema.MenuItem]
    }

    struct MenuItem: Codable {
        let healthy: Bool?
        let name: String
    }

    struct Alert: Codable {
        let id: Int
        let description: String?
        let startTimestamp: Int
        let endTimestamp: Int
    }

}
