//
//  DummyLocationManager.swift
//  Eatery Blue
//
//  Created by William Ma on 1/3/22.
//

import Foundation
import CoreLocation

class DummyLocationManager: LocationManager {

    static let urisHall = CLLocation(latitude: 42.4475128, longitude: -76.4822937)

    override func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = DummyLocationManager.urisHall
    }

}
