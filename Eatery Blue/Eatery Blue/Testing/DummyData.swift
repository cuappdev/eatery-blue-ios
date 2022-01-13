//
//  DummyData.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import EateryModel
import Foundation

enum DummyData {

    static let macsMenu = Menu(categories: [
        MenuCategory(category: "Enchiladas", items: [
            MenuItem(
                description: "A tortilla-wrapped chicken enchilada with your choice of toppings.",
                healthy: false,
                name: "Chicken",
                price: 625
            ),
            MenuItem(
                description: "A tortilla-wrapped bean and corn enchilada with your choice of toppings.",
                healthy: false,
                name: "Bean & Corn",
                price: 525
            ),
        ]),
        MenuCategory(category: "Salads", items: [
            MenuItem(
                description: "A tortilla-wrapped chicken enchilada with your choice of toppings.",
                healthy: true,
                name: "Chopped Salad",
                price: 1100
            )
        ])
    ])

    static let macs = Eatery(
        campusArea: "Central",
        events: (0..<5).map { offset in
            Event(
                canonicalDay: Day().advanced(by: offset),
                startTimestamp: Day().advanced(by: offset).date(hour: 7, minute: 0).timeIntervalSince1970,
                endTimestamp: Day().advanced(by: offset).date(hour: 17, minute: 30).timeIntervalSince1970,
                menu: macsMenu
            )
        },
        id: 1001,
        imageUrl: nil,
        latitude: nil,
        locationDescription: "Statler Hall",
        longitude: nil,
        menuSummary: "Flatbreads, salads, pasta",
        name: "Mac's Café",
        paymentMethods: [.brbs, .cash, .credit],
        waitTimesByDay:  [
            Day(): WaitTimes(
                samples: (0..<15).map({ (index: Int) -> WaitTimeSample in
                    WaitTimeSample(
                        timestamp: Date().timeIntervalSince1970 + TimeInterval(index) * 60 * 15,
                        low: TimeInterval(index + 1) * 60,
                        expected: TimeInterval(index + 2) * 60,
                        high: TimeInterval(index + 3) * 60
                    )
                }),
                samplingMethod: .nearestNeighbor
            )
        ]
    )

}
