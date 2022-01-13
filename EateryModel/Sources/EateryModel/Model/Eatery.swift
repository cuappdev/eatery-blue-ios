//
//  Eatery.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import Foundation

public struct Eatery: Codable, Hashable {

    public let campusArea: String?

    public let events: [Event]

    public let id: Int64

    public let imageUrl: URL?

    public let latitude: Double?

    public let locationDescription: String?

    public let longitude: Double?

    public let menuSummary: String?

    public let name: String

    public let paymentMethods: Set<PaymentMethod>

    public let waitTimesByDay: [Day: WaitTimes]

    public init(
        campusArea: String? = nil,
        events: [Event] = [],
        id: Int64,
        imageUrl: URL? = nil,
        latitude: Double? = nil,
        locationDescription: String? = nil,
        longitude: Double? = nil,
        menuSummary: String?,
        name: String,
        paymentMethods: Set<PaymentMethod> = [],
        waitTimesByDay: [Day: WaitTimes] = [:]
    ) {
        self.campusArea = campusArea
        self.events = events
        self.id = id
        self.imageUrl = imageUrl
        self.latitude = latitude
        self.locationDescription = locationDescription
        self.longitude = longitude
        self.menuSummary = menuSummary
        self.name = name
        self.paymentMethods = paymentMethods
        self.waitTimesByDay = waitTimesByDay
    }

}
