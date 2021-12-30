//
//  EateryFilter.swift
//  Eatery Blue
//
//  Created by William Ma on 12/29/21.
//

import Foundation
import CoreLocation

struct EateryFilter {

    var userLocation: CLLocation?

    var under10MinutesEnabled: Bool = false
    var paymentMethods: Set<PaymentMethod> = []
    var favoriteEnabled: Bool = false

    var north: Bool = false
    var west: Bool = false
    var central: Bool = false

    var isEnabled: Bool {
        under10MinutesEnabled || !paymentMethods.isEmpty || favoriteEnabled || north || west || central
    }

    func predicate() -> EateryPredicate {
        .and([
            under10MinutesPredicate,
            paymentMethodsPredicate,
            favoritePredicate,
            campusAreaPredicate
        ])
    }

    private var under10MinutesPredicate: EateryPredicate {
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

    private var paymentMethodsPredicate: EateryPredicate {
        if paymentMethods.isEmpty {
            return .true
        } else {
            return .or(paymentMethods.map { .acceptsPaymentMethod($0) })
        }
    }

    private var favoritePredicate: EateryPredicate {
        if favoriteEnabled {
            return .isFavorite
        } else {
            return .true
        }
    }

    private var campusAreaPredicate: EateryPredicate {
        if north || west || central {
            return .or([
                north ? .campusAreaEqualTo("North") : .false,
                west ? .campusAreaEqualTo("West") : .false,
                central ? .campusAreaEqualTo("Central") : .false
            ])
        } else {
            return .true
        }
    }

}
