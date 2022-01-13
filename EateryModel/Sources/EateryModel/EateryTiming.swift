//
//  EateryTiming.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import CoreLocation
import Foundation

public enum EateryTiming {

    public static func timing(
        eatery: Eatery,
        userLocation: CLLocation?,
        departureDate: Date
    ) -> (walkTime: TimeInterval?, waitTime: WaitTimeSample?) {
        if let walkTime = walkTime(eatery: eatery, userLocation: userLocation) {
            return (walkTime: walkTime, waitTime: waitTime(eatery: eatery, date: departureDate + walkTime))
        } else {
            return (walkTime: nil, waitTime: waitTime(eatery: eatery, date: departureDate))
        }
    }

    public static func walkTime(
        eatery: Eatery,
        userLocation: CLLocation?
    ) -> TimeInterval? {
        guard let latitude = eatery.latitude, let longitude = eatery.longitude, let userLocation = userLocation else {
            return nil
        }

        let distance = userLocation.distance(from: CLLocation(latitude: latitude, longitude: longitude))

        // https://en.wikipedia.org/wiki/Preferred_walking_speed
        let walkingSpeed = 1.42
        return distance / walkingSpeed
    }

    public static func waitTime(
        eatery: Eatery,
        date: Date
    ) -> WaitTimeSample? {
        guard let waitTimes = eatery.waitTimesByDay[Day(date: date)] else {
            return nil
        }

        return waitTimes.sample(at: date)
    }

}
