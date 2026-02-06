//
//  Eatery.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 01/29/26.
//

import CoreLocation
import Foundation

public struct Eatery: Codable, Hashable {
    public let id: Int

    let cornellId: Int?

    public let announcements: [String]

    public let name: String

    let shortName: String

    let about: String

    let shortAbout: String

    let cornellDining: Bool

    public let menuSummary: String

    public let imageUrl: String

    public let campusArea: CampusArea

    public let onlineOrderUrl: String?

    let contactPhone: String?

    let contactEmail: String?

    public let latitude: Float

    public let longitude: Float

    public let location: String

    public let paymentMethods: [PaymentMethod]

    let eateryTypes: [EateryType]

    let createdAt: Date

    public let events: [Event]
}

public extension Eatery {
    func walkTime(userLocation: CLLocation?) -> TimeInterval? {
        guard let userLocation = userLocation else {
            return nil
        }

        let distance = userLocation.distance(from: CLLocation(latitude: Double(latitude), longitude: Double(longitude)))

        // https://en.wikipedia.org/wiki/Preferred_walking_speed
        let walkingSpeed = 1.42
        return distance / walkingSpeed
    }
}

public extension Eatery {
    var status: EateryStatus {
        EateryStatus(events)
    }

    var isOpen: Bool {
        status.isOpen
    }
}
