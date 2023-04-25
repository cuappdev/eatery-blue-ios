//
//  EateryPredicate.swift
//  Eatery Blue
//
//  Created by William Ma on 12/29/21.
//

import CoreLocation
import EateryModel
import Foundation

indirect enum EateryPredicate {

    case bool(Bool)
    case `true`
    case `false`

    case not(EateryPredicate)
    case and([EateryPredicate])
    case or([EateryPredicate])

    case acceptsPaymentMethod(_ paymentMethod: PaymentMethod)
    case campusArea(String)
    case isFavorite
    case isOpen
    case underNMinutes(_ n: Int, userLocation: CLLocation, departureDate: Date)

    func isSatisfied(by eatery: Eatery, metadata: EateryMetadata?) -> Bool {
        if let metadata = metadata, metadata.eateryId != eatery.id {
            logger.warning("\(#function): eatery.id (\(eatery.id)) does not match metadata.eateryId (\(metadata.eateryId))")
        }

        switch self {
        case .bool(let bool):
            return bool

        case .true:
            return true

        case .false:
            return false

        case .not(let predicate):
            return !predicate.isSatisfied(by: eatery, metadata: metadata)

        case .and(let predicates):
            return predicates.allSatisfy { $0.isSatisfied(by: eatery, metadata: metadata) }

        case .or(let predicates):
            return predicates.contains { $0.isSatisfied(by: eatery, metadata: metadata) }

        case .underNMinutes(let n, let userLocation, let departureDate):
            guard let totalTime = eatery.expectedTotalTime(userLocation: userLocation, departureDate: departureDate) else {
                return false
            }

            return totalTime < TimeInterval(60 * n)

        case .acceptsPaymentMethod(let paymentMethod):
            return eatery.paymentMethods.contains(paymentMethod)

        case .campusArea(let campusArea):
            return eatery.campusArea == campusArea

        case .isFavorite:
            if let metadata = metadata {
                return metadata.isFavorite
            } else {
                return false
            }

        case .isOpen:
            return eatery.isOpen
        }
    }

}
