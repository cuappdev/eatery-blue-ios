//
//  WaitTimes.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import Foundation

struct WaitTimes: Codable, Hashable {

    // In case we ever add more in the future...
    enum SamplingMethod: String, Codable {
        case nearestNeighbor
    }

    let samples: [WaitTimeSample]

    let samplingMethod: SamplingMethod

    func sample(at date: Date) -> WaitTimeSample? {
        switch samplingMethod {
        case .nearestNeighbor:
            let timestamp = date.timeIntervalSince1970
            return samples.min { lhs, rhs in
                abs(lhs.timestamp - timestamp) < abs(rhs.timestamp - timestamp)
            }

        }
    }

}

struct WaitTimeSample: Codable, Hashable {

    let timestamp: TimeInterval

    let low: TimeInterval
    let expected: TimeInterval
    let high: TimeInterval

}
