//
//  LocationManager.swift
//  Eatery Blue
//
//  Created by William Ma on 1/3/22.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {

    private let locationManager: CLLocationManager

    @Published var userLocation: CLLocation?

    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
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
        logger.debug("\(#function): Fetched location")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.error("\(#function): \(error)")
    }

}
