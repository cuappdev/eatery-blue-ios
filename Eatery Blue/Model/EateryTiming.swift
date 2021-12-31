//
//  EateryTiming.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import CoreLocation
import Foundation

enum EateryTiming {

    static func timing(
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

    static func walkTime(
        eatery: Eatery,
        userLocation: CLLocation?
    ) -> TimeInterval? {
        guard let location = eatery.location, let userLocation = userLocation else {
            return nil
        }

        let distance = location.location.distance(from: userLocation)

        // https://en.wikipedia.org/wiki/Preferred_walking_speed
        let walkingSpeed = 1.42
        return distance / walkingSpeed
    }

    static func waitTime(
        eatery: Eatery,
        date: Date
    ) -> WaitTimeSample? {
        guard let waitTimes = eatery.waitTimesByDay[Day(date: date)] else {
            return nil
        }

        return waitTimes.sample(at: date)
    }

}
