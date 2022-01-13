//
//  EateryFilter.swift
//  Eatery Blue
//
//  Created by William Ma on 12/29/21.
//

import CoreLocation
import EateryModel
import Foundation

struct EateryFilter: Codable {

    var under10MinutesEnabled: Bool = false
    var paymentMethods: Set<PaymentMethod> = []
    var favoriteEnabled: Bool = false

    var north: Bool = false
    var west: Bool = false
    var central: Bool = false

    var isEnabled: Bool {
        under10MinutesEnabled || !paymentMethods.isEmpty || favoriteEnabled || north || west || central
    }

    func predicate(userLocation: CLLocation?) -> EateryPredicate {
        .and([
            under10MinutesPredicate(userLocation: userLocation),
            paymentMethodsPredicate(),
            favoritePredicate(),
            campusAreaPredicate()
        ])
    }

    func under10MinutesPredicate(userLocation: CLLocation?) -> EateryPredicate {
        if under10MinutesEnabled {
            if let userLocation = userLocation {
                return .underNMinutes(10, userLocation: userLocation)
            } else {
                return .false
            }
        } else {
            return .true
        }
    }

    func paymentMethodsPredicate() -> EateryPredicate {
        if paymentMethods.isEmpty {
            return .true
        } else {
            return .or(paymentMethods.map { .acceptsPaymentMethod($0) })
        }
    }

    func favoritePredicate() -> EateryPredicate {
        if favoriteEnabled {
            return .isFavorite
        } else {
            return .true
        }
    }

    func campusAreaPredicate() -> EateryPredicate {
        if north || west || central {
            return .or([
                north ? .campusArea("North") : .false,
                west ? .campusArea("West") : .false,
                central ? .campusArea("Central") : .false
            ])
        } else {
            return .true
        }
    }

}
