//
//  EateryPredicate.swift
//  Eatery Blue
//
//  Created by William Ma on 12/29/21.
//

import Foundation
import CoreLocation

indirect enum EateryPredicate {

    case underNMinutes(_ n: Int, userLocation: CLLocation)
    case acceptsPaymentMethod(_ paymentMethod: PaymentMethod)
    case isFavorite
    case campusAreaEqualTo(String)

    case and([EateryPredicate])
    case or([EateryPredicate])

    case `true`
    case `false`

    func isSatisfiedBy(_ eatery: Eatery) -> Bool {
        switch self {
        case .true:
            return true

        case .false:
            return false

        case .and(let predicates):
            return predicates.allSatisfy { $0.isSatisfiedBy(eatery) }

        case .or(let predicates):
            return predicates.contains { $0.isSatisfiedBy(eatery) }

        case .underNMinutes(let n, let location):
            guard let latitude = eatery.latitude, let longitude = eatery.longitude else {
                return false
            }

            let eateryLocation = CLLocation(latitude: latitude, longitude: longitude)
            let distance = location.distance(from: eateryLocation)

            // https://en.wikipedia.org/wiki/Preferred_walking_speed
            let walkingSpeed = 1.42
            let seconds = distance / walkingSpeed
            let minutes = seconds / 60

            return Int(minutes) <= n

        case .acceptsPaymentMethod(let paymentMethod):
            return eatery.paymentMethods.contains(paymentMethod)

        case .campusAreaEqualTo(let campusArea):
            return eatery.campusArea == campusArea

        case .isFavorite:
            return false

        }
    }

}
