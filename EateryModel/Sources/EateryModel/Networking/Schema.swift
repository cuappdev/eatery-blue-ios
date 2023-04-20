//
//  Schema.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import Foundation

internal enum Schema {

    internal struct Alert: Codable {

        internal let description: String?

        internal let endTimestamp: Int

        internal let id: Int64

        internal let startTimestamp: Int

    }

    internal struct Eatery: Codable {

        internal let alerts: [Alert]?

        internal let campusArea: String?

        internal let events: [Schema.Event]?
        
        internal let id: Int64
        
        internal let imageUrl: String?

        internal let latitude: Double?

        internal let location: String?

        internal let longitude: Double?

        internal let menuSummary: String?

        internal let name: String?

        internal let onlineOrderUrl: URL?

        internal let paymentAcceptsCash: Bool?

        internal let paymentAcceptsBrbs: Bool?

        internal let paymentAcceptsMealSwipes: Bool?

        internal let waitTimes: [Schema.WaitTimesByDay]? // Not implemeneted on backend currently, will always be nil

    }

    internal struct Event: Codable {
        
        internal let eatery: Int? // Need to communicate with backend about purpose of this var

        internal let end: Int?

        internal let eventDescription: String?

        internal let id: Int

        internal let start: Int?

        internal let menu: [Schema.MenuCategory]?

    }

    internal struct MenuCategory: Codable {

        internal let category: String

        internal let event: Int? // Need to communciate about purpose of this var

        internal let id: Int // And this

        internal let items: [Schema.MenuItem]

    }

    internal struct MenuItem: Codable {

        internal let category: Int

        internal let healthy: Bool?

        internal let id: Int

        internal let name: String

    }

    internal struct WaitTimes: Codable {

        internal let timestamp: Int

        internal let waitTimeLow: Int

        internal let waitTimeExpected: Int

        internal let waitTimeHigh: Int

    }

    internal struct WaitTimesByDay: Codable {

        internal let canonicalDate: String?

        internal let data: [Schema.WaitTimes]?

    }

}
