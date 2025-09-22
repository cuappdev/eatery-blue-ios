//
//  Schema.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import Foundation

enum Schema {
    struct Alert: Codable {
        let description: String?

        let endTimestamp: Int

        let id: Int64

        let startTimestamp: Int
    }

    struct Eatery: Codable {
        let alerts: [Alert]?

        let campusArea: String?

        let events: [Schema.Event]?

        let id: Int64

        let imageUrl: String?

        let latitude: Double?

        let location: String?

        let longitude: Double?

        let menuSummary: String?

        let name: String?

        let onlineOrderUrl: URL?

        let paymentAcceptsCash: Bool?

        let paymentAcceptsBrbs: Bool?

        let paymentAcceptsMealSwipes: Bool?

        let waitTime: [Schema.WaitTime]?
    }

    struct Event: Codable {
        let eatery: Int? // Need to communicate with backend about purpose of this var

        let end: Int?

        let eventDescription: String?

        let id: Int?

        let start: Int?

        let menu: [Schema.MenuCategory]?
    }

    struct MenuCategory: Codable {
        let category: String

        let event: Int? // Need to communciate about purpose of this var

        let id: Int? // And this

        let items: [Schema.MenuItem]
    }

    struct MenuItem: Codable {
        let category: Int?

        let healthy: Bool?

        let id: Int

        let name: String

        let allergens: [String]

        let dietaryPreferences: [String]
    }

    struct WaitTime: Codable {
        let day: String

        let eatery: Int // Not sure why this is needed

        let hour: Int

        let id: Int // Not sure why this is needed

        let trials: Int // Not sure what this is for

        let waitTimeExpected: Int

        let waitTimeHigh: Int

        let waitTimeLow: Int
    }

    // MARK: - WaitTimesByDay (uncomment and modify once implemented)

//    internal struct WaitTimesByDay: Codable {
//
//        internal let canonicalDate: String?
//
//        internal let data: [Schema.WaitTimes]?
//
//    }
}
