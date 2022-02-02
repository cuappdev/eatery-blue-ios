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

    internal struct APIResponse: Codable {

        internal let data: [Eatery]

        internal let error: String?

        internal let success: Bool

    }

    internal struct Eatery: Codable {

        internal let alerts: [Alert]?

        internal let campusArea: String?

        internal let id: Int64

        internal let events: [Schema.Event]?
        
        internal let imageUrl: URL?

        internal let latitude: Double?

        internal let location: String?

        internal let longitude: Double?

        internal let menuSummary: String?

        internal let name: String

        internal let onlineOrderUrl: URL?

        internal let paymentAcceptsCash: Bool?

        internal let paymentAcceptsBrbs: Bool?

        internal let paymentAcceptsMealSwipes: Bool?

        internal let waitTimes: [Schema.WaitTimesByDay]?

    }

    internal struct Event: Codable {

        internal let canonicalDate: String

        internal let description: String?

        internal let endTimestamp: Int

        internal let startTimestamp: Int

        internal let menu: [Schema.MenuCategory]?

    }

    internal struct MenuCategory: Codable {

        internal let category: String

        internal let items: [Schema.MenuItem]

    }

    internal struct MenuItem: Codable {

        internal let healthy: Bool?

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
