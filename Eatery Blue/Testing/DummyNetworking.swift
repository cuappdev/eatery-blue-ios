//
//  DummyNetworking.swift
//  Eatery Blue
//
//  Created by William Ma on 1/2/22.
//

import Combine
import Foundation

class DummyNetworking: Networking {

    var injectDummyData: Bool = false
    var delay: TimeInterval = 0

    override func fetchEateries(maxStaleness: TimeInterval = 0) -> AnyPublisher<[Eatery], Error> {
        super.fetchEateries(maxStaleness: maxStaleness)
            .map { eateries in
                [DummyData.rpcc, DummyData.macs] + eateries
            }
            .delay(for: .seconds(delay), tolerance: nil, scheduler: RunLoop.main, options: nil)
            .eraseToAnyPublisher()
    }

}
