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

    static let macsBreakfastMenu = Menu(categories: [
        MenuCategory(category: "Meat", items: [
            MenuItem(
                description: "A bacon strip.",
                healthy: false,
                name: "Bacon",
                price: 625
            ),
            MenuItem(
                description: "Pork sausage link.",
                healthy: false,
                name: "Pork",
                price: 525
            ),
        ]),
        MenuCategory(category: "Egg", items: [
            MenuItem(
                description: "Scrambled egg.",
                healthy: true,
                name: "Egg",
                price: 1100
            )
        ])
    ])
    
    static let macsLunchMenu = Menu(categories: [
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
    
    static let macsDinnerMenu = Menu(categories: [
        MenuCategory(category: "Grill", items: [
            MenuItem(
                description: "Carolina BBQ Pulled Pork with Coleslaw.",
                healthy: false,
                name: "BBQ",
                price: 625
            ),
            MenuItem(
                description: "French fries.",
                healthy: false,
                name: "Potatoes",
                price: 525
            ),
        ]),
        MenuCategory(category: "Chef's Table", items: [
            MenuItem(
                description: "Vegan tofu chili.",
                healthy: true,
                name: "Chili",
                price: 1100
            )
        ])
    ])

    static let macs = Eatery(
        campusArea: "Central",
        events: [
            Event(
                canonicalDay: Day().advanced(by: 0),
                description: "Breakfast",
                endTimestamp: Day().advanced(by: 0).date(hour: 24, minute: 0).timeIntervalSince1970,
                menu: macsBreakfastMenu,
                startTimestamp: Day().advanced(by: 0).date(hour: 7, minute: 0).timeIntervalSince1970
            ),
            Event(
                canonicalDay: Day().advanced(by: 1),
                description: "Lunch",
                endTimestamp: Day().advanced(by: 1).date(hour: 24, minute: 0).timeIntervalSince1970,
                menu: macsLunchMenu,
                startTimestamp: Day().advanced(by: 1).date(hour: 7, minute: 0).timeIntervalSince1970
            ),
            Event(
                canonicalDay: Day().advanced(by: 2),
                description: "Dinner",
                endTimestamp: Day().advanced(by: 2).date(hour: 24, minute: 0).timeIntervalSince1970,
                menu: macsDinnerMenu,
                startTimestamp: Day().advanced(by: 2).date(hour: 7, minute: 0).timeIntervalSince1970
            )
        ],
        id: 1001,
        imageUrl: nil,
        latitude: nil,
        locationDescription: "Statler Hall",
        longitude: nil,
        menuSummary: "Flatbreads, salads, pasta",
        name: "Mac's Café",
        onlineOrderUrl: nil,
        paymentMethods: [.brbs, .cash, .credit, .mealSwipes],
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
    
    static let terraceBreakfastMenu = Menu(categories: [
        MenuCategory(category: "Potato", items: [
            MenuItem(
                description: "Fried potato puffs.",
                healthy: false,
                name: "Potato",
                price: 1025
            )
        ]),
        MenuCategory(category: "Bread", items: [
            MenuItem(
                description: "Chocolate bread pudding.",
                healthy: true,
                name: "Chocolate Bread",
                price: 1100
            )
        ])
    ])
    
    static let terraceLunchMenu = Menu(categories: [
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
    
    static let terraceDinnerMenu = Menu(categories: [
        MenuCategory(category: "Chef's Table - Sides", items: [
            MenuItem(
                description: "Papas Bravas - spicy potatoes.",
                healthy: false,
                name: "Potato",
                price: 1025
            ),
            MenuItem(
                description: "Steamed fresh broccoli.",
                healthy: false,
                name: "Broccoli",
                price: 1025
            ),
        ]),
        MenuCategory(category: "Salads", items: [
            MenuItem(
                description: "Traditional hummus.",
                healthy: true,
                name: "Hummus",
                price: 1100
            )
        ])
    ])

    static let terrace = Eatery(
        campusArea: "Central",
        events: [
            Event(
                canonicalDay: Day().advanced(by: 0),
                description: "Breakfast",
                endTimestamp: Day().advanced(by: 0).date(hour: 24, minute: 0).timeIntervalSince1970,
                menu: terraceBreakfastMenu,
                startTimestamp: Day().advanced(by: 0).date(hour: 7, minute: 0).timeIntervalSince1970
            ),
            Event(
                canonicalDay: Day().advanced(by: 1),
                description: "Lunch",
                endTimestamp: Day().advanced(by: 1).date(hour: 24, minute: 0).timeIntervalSince1970,
                menu: terraceLunchMenu,
                startTimestamp: Day().advanced(by: 1).date(hour: 7, minute: 0).timeIntervalSince1970
            ),
            Event(
                canonicalDay: Day().advanced(by: 2),
                description: "Dinner",
                endTimestamp: Day().advanced(by: 2).date(hour: 24, minute: 0).timeIntervalSince1970,
                menu: terraceDinnerMenu,
                startTimestamp: Day().advanced(by: 2).date(hour: 7, minute: 0).timeIntervalSince1970
            )
        ],
        id: 1002,
        imageUrl: nil,
        latitude: nil,
        locationDescription: "Statler Hall",
        longitude: nil,
        menuSummary: "Burrito bowls, pho and ramen, salads",
        name: "The Terrace Restaurant",
        onlineOrderUrl: nil,
        paymentMethods: [.brbs, .cash, .credit, .mealSwipes],
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
    
    static let roseBreakfastMenu = Menu(categories: [
        MenuCategory(category: "Taco Breakfast", items: [
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
        MenuCategory(category: "Desserts Breakfast", items: [
            MenuItem(
                description: "A chocolate chip cookie.",
                healthy: false,
                name: "Cookie"
            )
        ])
    ])
    
    static let roseLunchMenu = Menu(categories: [
        MenuCategory(category: "Taco Lunch", items: [
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
        MenuCategory(category: "Dessert Lunch", items: [
            MenuItem(
                description: "A chocolate chip cookie.",
                healthy: false,
                name: "Cookie"
            )
        ])
    ])
    
    static let roseDinnerMenu = Menu(categories: [
        MenuCategory(category: "Taco Dinner", items: [
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
        MenuCategory(category: "Desserts Dinner", items: [
            MenuItem(
                description: "A chocolate chip cookie.",
                healthy: false,
                name: "Cookie"
            )
        ])
    ])

    static let rose = Eatery(
        campusArea: "West",
        events: [
            Event(
                canonicalDay: Day().advanced(by: 0),
                description: "Breakfast",
                endTimestamp: Day().advanced(by: 0).date(hour: 24, minute: 0).timeIntervalSince1970,
                menu: roseBreakfastMenu,
                startTimestamp: Day().advanced(by: 0).date(hour: 7, minute: 0).timeIntervalSince1970
            ),
            Event(
                canonicalDay: Day().advanced(by: 1),
                description: "Lunch",
                endTimestamp: Day().advanced(by: 1).date(hour: 24, minute: 0).timeIntervalSince1970,
                menu: roseLunchMenu,
                startTimestamp: Day().advanced(by: 1).date(hour: 7, minute: 0).timeIntervalSince1970
            ),
            Event(
                canonicalDay: Day().advanced(by: 2),
                description: "Dinner",
                endTimestamp: Day().advanced(by: 2).date(hour: 24, minute: 0).timeIntervalSince1970,
                menu: roseDinnerMenu,
                startTimestamp: Day().advanced(by: 2).date(hour: 7, minute: 0).timeIntervalSince1970
            )
        ],
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
