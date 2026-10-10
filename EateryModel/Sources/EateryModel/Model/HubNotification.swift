//
//  HubNotification.swift
//  EateryModel
//
//  Created by Amy Yang on 9/30/26.
//

import Foundation

public struct HubNotification: Codable, Hashable, Identifiable {
    public let id: Int
    public let title: String
    public let body: String
    public let isRead: Bool
    public let createdAt: Date

    public init(
        id: Int,
        title: String,
        body: String,
        isRead: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.isRead = isRead
        self.createdAt = createdAt
    }
}
