//
//  EateryFilter.swift
//  Eatery Blue
//
//  Created by William Ma on 12/29/21.
//

import Foundation

enum EateryFilter: Hashable {

    static func filter(
        _ filter: EateryFilter,
        matches eatery: Eatery
    ) -> Bool {
        switch filter {
        case .underNMinutes: return false
        case .paymentMethods(let paymentMethods): return eatery.paymentMethods.isSuperset(of: paymentMethods)
        case .favorites: return false
        case .north: return eatery.campusArea == "North"
        case .west: return eatery.campusArea == "West"
        case .central: return eatery.campusArea == "Central"
        }
    }

    case underNMinutes(Int)
    case paymentMethods(Set<PaymentMethod>)
    case favorites
    case north
    case west
    case central

}
