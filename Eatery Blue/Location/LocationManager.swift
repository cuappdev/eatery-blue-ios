//
//  LocationManager.swift
//  Eatery Blue
//
//  Created by William Ma on 1/3/22.
//

import Combine
import CoreLocation
import Foundation

class LocationManager: NSObject, CLLocationManagerDelegate {

    private let locationManager: CLLocationManager

    @Published var userLocation: CLLocation?

    /// Sends a value after userLocation on this location manager has been updated.
    ///
    /// This is necessary since the userLocation publisher only publishes willChange events.
    var userLocationDidChange = PassthroughSubject<CLLocation?, Never>()

    var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }

    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        userLocation = locationManager.location
    }

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        locationManager.requestLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
        userLocationDidChange.send(userLocation)
        logger.debug("\(#function): Fetched location")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.error("\(#function): \(error)")
    }

}
