//
//  Analytics.swift
//  AppDevAnalytics
//
//  Created by Kevin Chan on 9/4/19.
//  Copyright © 2019 Kevin Chan. All rights reserved.
//

import FirebaseAnalytics

protocol Payload {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
}

extension Payload {
    var parameters: [String: Any]? {
        nil
    }
}

enum AnalyticsError: Error {
    case unnaccountedEvent(String)
}

class AppDevAnalytics {
    static let shared = AppDevAnalytics()

    private init() {}

    func logFirebase(_ payload: Payload) {
        #if DEBUG
            logger.debug("Log Event: \(payload.eventName), parameters: \(payload.parameters?.description ?? "nil")")
        #else
            Analytics.logEvent(payload.eventName, parameters: payload.parameters)
        #endif
    }
}

// MARK: Event Payloads

/// Log whenever Eatery tab bar button is pressed
struct EateryPressPayload: Payload {
    let eventName = "eatery_tab_press"
}

/// Log whenever BRB Account tab bar button is pressed
struct AccountPressPayload: Payload {
    let eventName = "brb_tab_press"
}

/// Log whenever the Nearest filter is pressed (on x view)
struct NearestFilterPressPayload: Payload {
    let eventName = "nearest_filter_press"
}

/// Log whenever the Favorite Items filter is pressed
struct FavoriteItemsPressPayload: Payload {
    let eventName = "favorite_items_filter_press"
}

/// Log whenever the North filter is pressed
struct NorthFilterPressPayload: Payload {
    let eventName = "north_filter_press"
}

/// Log whenever the West filter is pressed
struct WestFilterPressPayload: Payload {
    let eventName = "west_filter_press"
}

/// Log whenever the Central filter is pressed
struct CentralFilterPressPayload: Payload {
    let eventName = "central_filter_press"
}

/// Log whenever the Swipes filter is pressed
struct SwipesFilterPressPayload: Payload {
    let eventName = "swipes_filter_press"
}

/// Log whenever the BRB filter is pressed
struct BRBFilterPressPayload: Payload {
    let eventName = "brb_filter_press"
}

/// Log whenever BRB Account login is attempted
struct AccountLoginPayload: Payload {
    let eventName = "user_brb_login"
}

/// Log whenever any Campus dining cell is pressed
struct CampusDiningCellPressPayload: Payload {
    let eventName = "campus_dining_hall_press"
    let diningHallName: String
    var parameters: [String: Any]? {
        ["dining_hall_name": diningHallName]
    }
}

/// Log whenever any Campus cafe (no swipes) cell is pressed
struct CampusCafeCellPressPayload: Payload {
    let eventName = "campus_cafe_press"
    let cafeName: String
    var parameters: [String: Any]? {
        ["cafe_name": cafeName]
    }
}

/// Log whenever compare menus button is pressed
struct CompareMenusButtonPressPayload: Payload {
    let eventName = "compare_menus_button_press"
    let entryPage: String
    var parameters: [String: Any]? {
        ["entry_page": entryPage]
    }
}

/// Log whenever compare menus button is pressed
struct CompareMenusStartComparingPayload: Payload {
    let eventName = "compare_menus_start_comparing"
    let eateries: [String]
    var parameters: [String: Any]? {
        ["eateries": eateries]
    }
}
