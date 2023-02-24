//
//  DummyData.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import EateryModel
import Foundation

enum DummyData {
    
    static let eateries = [macs, terrace, rose]

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
                description: "A chopped salad with your choice of toppings.",
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
                endTimestamp: Day().advanced(by: offset).date(hour: 17, minute: 30).timeIntervalSince1970,
                menu: macsMenu,
                startTimestamp: Day().advanced(by: offset).date(hour: 7, minute: 0).timeIntervalSince1970
            )
        },
        id: 1001,
        imageUrl: nil,
        latitude: nil,
        locationDescription: "Statler Hall",
        longitude: nil,
        menuSummary: "Flatbreads, salads, pasta",
        name: "Mac's Café",
        onlineOrderUrl: nil,
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
    
    static let terraceMenu = Menu(categories: [
        MenuCategory(category: "Pho Bar", items: [
            MenuItem(
                description: "A pho bowl with your choice of toppings.",
                healthy: false,
                name: "Pho Bowl",
                price: 1025
            ),
            MenuItem(
                description: "A rice bowl with your choice of toppings.",
                healthy: false,
                name: "Rice Bowl",
                price: 1025
            ),
        ]),
        MenuCategory(category: "Salads", items: [
            MenuItem(
                description: "A mixed salad with your choice of toppings.",
                healthy: true,
                name: "Mixed Salad",
                price: 1100
            )
        ])
    ])

    static let terrace = Eatery(
        campusArea: "Central",
        events: (0..<5).map { offset in
            Event(
                canonicalDay: Day().advanced(by: offset),
                endTimestamp: Day().advanced(by: offset).date(hour: 15, minute: 0).timeIntervalSince1970,
                menu: terraceMenu,
                startTimestamp: Day().advanced(by: offset).date(hour: 8, minute: 0).timeIntervalSince1970
            )
        },
        id: 1002,
        imageUrl: nil,
        latitude: nil,
        locationDescription: "Statler Hall",
        longitude: nil,
        menuSummary: "Burrito bowls, pho and ramen, salads",
        name: "The Terrace Restaurant",
        onlineOrderUrl: nil,
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
    
    static let roseMenu = Menu(categories: [
        MenuCategory(category: "Taco Bar", items: [
            MenuItem(
                description: "Filling for your taco.",
                healthy: false,
                name: "Southwest chicken"
            ),
            MenuItem(
                description: "Filling for your taco.",
                healthy: false,
                name: "Corn & Beans"
            ),
        ]),
        MenuCategory(category: "Desserts", items: [
            MenuItem(
                description: "A chocolate chip cookie.",
                healthy: false,
                name: "Cookie"
            )
        ])
    ])

    static let rose = Eatery(
        campusArea: "West",
        events: (0..<5).map { offset in
            Event(
                canonicalDay: Day().advanced(by: offset),
                endTimestamp: Day().advanced(by: offset).date(hour: 20, minute: 0).timeIntervalSince1970,
                menu: roseMenu,
                startTimestamp: Day().advanced(by: offset).date(hour: 7, minute: 0).timeIntervalSince1970
            )
        },
        id: 1003,
        imageUrl: nil,
        latitude: nil,
        locationDescription: "West Campus",
        longitude: nil,
        menuSummary: "Chef's choice",
        name: "Rose Dining Hall",
        onlineOrderUrl: nil,
        paymentMethods: [.credit, .mealSwipes],
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
