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
        let campusArea: String?
        let events: [Schema.Event]?
        let latitude: Double?
        let longitude: Double?
        let name: String
        let waitTimesByDay: [Schema.WaitTimesByDay]?
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
        let healthy: Bool
        let name: String
    }

}
