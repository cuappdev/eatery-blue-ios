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
    case campusArea(CampusArea)
    case isFavorite
    case isOpen
    case underNMinutes(_ n: Int, userLocation: CLLocation, departureDate: Date)
    case isSelected([Eatery])

    func isSatisfied(by eatery: Eatery, metadata: EateryMetadata?) -> Bool {
        if let metadata = metadata, metadata.eateryId != eatery.id {
            logger
                .warning(
                    "\(#function): eatery.id (\(eatery.id)) does not match metadata.eateryId (\(metadata.eateryId))"
                )
        }

        switch self {
        case let .bool(bool):
            return bool

        case .true:
            return true

        case .false:
            return false

        case let .not(predicate):
            return !predicate.isSatisfied(by: eatery, metadata: metadata)

        case let .and(predicates):
            return predicates.allSatisfy { $0.isSatisfied(by: eatery, metadata: metadata) }

        case let .or(predicates):
            return predicates.contains { $0.isSatisfied(by: eatery, metadata: metadata) }

        case let .underNMinutes(n, userLocation, departureDate):
            guard let totalTime = eatery.walkTime(userLocation: userLocation)
            else {
                return false
            }

            return totalTime < TimeInterval(60 * n)

        case let .acceptsPaymentMethod(paymentMethod):
            return eatery.paymentMethods.contains(paymentMethod)

        case let .campusArea(campusArea):
            return eatery.campusArea == campusArea

        case .isFavorite:
            if let metadata = metadata {
                return metadata.isFavorite
            } else {
                return false
            }

        case .isOpen:
            return eatery.isOpen

        case let .isSelected(eateries):
            return eateries.contains(eatery)
        }
    }
}
