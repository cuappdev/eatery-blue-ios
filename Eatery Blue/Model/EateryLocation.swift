//
//  EateryLocation.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import CoreLocation
import Foundation

struct EateryLocation: Codable, Hashable {

    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees

    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.latitude = latitude
        self.longitude = longitude
    }

}
