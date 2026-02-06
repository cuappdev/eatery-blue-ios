//
//  Event.swift
//
//
//  Created by William Ma on 1/12/22.
//

import Foundation

public struct Event: Codable, Hashable {
    let id: Int

    public let type: EventType

    public let startTimestamp: Date

    public let endTimestamp: Date

    let upvotes: Int

    let downvotes: Int

    let createdAt: Date

    let eateryId: Int

    public let menu: [MenuCategory]
}

public extension Event {
    var canonicalDay: Day {
        Day(date: startTimestamp)
    }
}
