//
//  EateryFilter.swift
//  Eatery Blue
//
//  Created by William Ma on 12/29/21.
//

import Foundation
import CoreLocation

enum EateryFilter: Hashable {

    static func filter(
        _ filter: EateryFilter,
        matches eatery: Eatery,
        currentLocation: CLLocation? = nil
    ) -> Bool {
        switch filter {
        case .underNMinutes(let n):
            guard let currentLocation = currentLocation else {
                return false
            }

            guard let latitude = eatery.latitude, let longitude = eatery.longitude else {
                return false
            }

            let eateryLocation = CLLocation(latitude: latitude, longitude: longitude)
            let distance = currentLocation.distance(from: eateryLocation)

            // https://en.wikipedia.org/wiki/Preferred_walking_speed
            let walkingSpeed = 1.42
            let seconds = distance / walkingSpeed
            let minutes = seconds / 60

            return Int(minutes) <= n

        case .paymentMethod(let paymentMethod):
            return eatery.paymentMethods.contains(paymentMethod)

        case .favorites:
            return false

        case .north:
            return eatery.campusArea == "North"

        case .west:
            return eatery.campusArea == "West"

        case .central:
            return eatery.campusArea == "Central"
        }
    }

    case underNMinutes(Int)
    case paymentMethod(PaymentMethod)
    case favorites
    case north
    case west
    case central

}
