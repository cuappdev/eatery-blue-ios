//
//  EateryPredicate.swift
//  Eatery Blue
//
//  Created by William Ma on 12/29/21.
//

import CoreLocation
import Foundation

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

        case .underNMinutes(let n, let userLocation):
            let (walkTime, waitTime) = EateryTiming.timing(
                eatery: eatery,
                userLocation: userLocation,
                departureDate: Date()
            )

            if let waitTime = waitTime {
                let totalTime = (walkTime ?? 0) + waitTime.expected
                return totalTime <= TimeInterval(60 * n)
            } else {
                return false
            }

        case .acceptsPaymentMethod(let paymentMethod):
            return eatery.paymentMethods.contains(paymentMethod)

        case .campusAreaEqualTo(let campusArea):
            return eatery.campusArea == campusArea

        case .isFavorite:
            return false

        }
    }

}