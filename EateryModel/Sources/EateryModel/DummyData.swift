//
//  DummyData.swift
//  EateryModel
//
//  Created by Peter Bidoshi on 1/29/26.
//

import Foundation

public extension Eatery {
    static let dummyEateries: [Eatery] = [
        // MARK: - Mac's Café (Statler Hall)

        Eatery(
            id: 1,
            cornellId: 1001,
            announcements: ["Smoothie bar is open until 2pm!"],
            name: "Mac's Café",
            shortName: "Mac's",
            about:
            "Mac's Café offers made-to-order salads, sandwiches, and flatbreads in Statler Hall.",
            shortAbout: "Salads, sandwiches, and flatbreads.",
            cornellDining: true,
            menuSummary: "Flatbreads • Salads • Smoothies",
            imageUrl: "https://example.com/macs.jpg",
            campusArea: CampusArea.central,
            onlineOrderUrl: "https://get.cbord.com/cornell",
            contactPhone: "607-255-0000",
            contactEmail: "dining@cornell.edu",
            latitude: 42.4446,
            longitude: -76.4823,
            location: "Statler Hall",
            paymentMethods: [.brbs, .card],
            eateryTypes: [.cafe],
            createdAt: Date(),
            events: [
                Event(
                    id: 101,
                    type: .lunch,
                    startTimestamp: Date(),
                    endTimestamp: Date().addingTimeInterval(3600 * 4),
                    upvotes: 24,
                    downvotes: 2,
                    createdAt: Date(),
                    eateryId: 1,
                    menu: [
                        MenuCategory(
                            id: 1001,
                            name: "Flatbreads",
                            createdAt: Date(),
                            eventId: 101,
                            items: [
                                MenuItem(
                                    id: 1,
                                    name: "Buffalo Chicken Flatbread",
                                    basePrice: 8.50,
                                    createdAt: Date(),
                                    categoryId: 1001,
                                    dietaryPreferences: [],
                                    allergens: [
                                        Allergen(name: "Gluten"),
                                        Allergen(name: "Dairy")
                                    ]
                                ),
                                MenuItem(
                                    id: 2,
                                    name: "Margherita Flatbread",
                                    basePrice: 7.50,
                                    createdAt: Date(),
                                    categoryId: 1001,
                                    dietaryPreferences: [
                                        DietaryPreference(name: "Vegetarian")
                                    ],
                                    allergens: [
                                        Allergen(name: "Gluten"),
                                        Allergen(name: "Dairy")
                                    ]
                                )
                            ]
                        )
                    ]
                )
            ]
        ),

        // MARK: - The Terrace (Statler Hall)

        Eatery(
            id: 2,
            cornellId: 1002,
            announcements: [],
            name: "The Terrace",
            shortName: "Terrace",
            about:
            "The Terrace Restaurant serves burritos, bowls, and salads with a view.",
            shortAbout: "Burritos, bowls, and salads.",
            cornellDining: true,
            menuSummary: "Burritos • Pho • Salads",
            imageUrl: "https://example.com/terrace.jpg",
            campusArea: .central,
            onlineOrderUrl: nil,
            contactPhone: "607-255-0000",
            contactEmail: "dining@cornell.edu",
            latitude: 42.4447,
            longitude: -76.4825,
            location: "Statler Hall",
            paymentMethods: [.brbs, .card],
            eateryTypes: [.cafe],
            createdAt: Date(),
            events: [
                Event(
                    id: 201,
                    type: .lunch,
                    startTimestamp: Date(),
                    endTimestamp: Date().addingTimeInterval(3600 * 3),
                    upvotes: 45,
                    downvotes: 1,
                    createdAt: Date(),
                    eateryId: 2,
                    menu: [
                        MenuCategory(
                            id: 2001,
                            name: "Burrito Station",
                            createdAt: Date(),
                            eventId: 201,
                            items: [
                                MenuItem(
                                    id: 3,
                                    name: "Chicken Burrito",
                                    basePrice: 9.00,
                                    createdAt: Date(),
                                    categoryId: 2001,
                                    dietaryPreferences: [],
                                    allergens: [Allergen(name: "Gluten")]
                                ),
                                MenuItem(
                                    id: 4,
                                    name: "Tofu Bowl",
                                    basePrice: 8.50,
                                    createdAt: Date(),
                                    categoryId: 2001,
                                    dietaryPreferences: [
                                        DietaryPreference(name: "Vegan")
                                    ],
                                    allergens: [Allergen(name: "Soy")]
                                )
                            ]
                        )
                    ]
                )
            ]
        ),

        // MARK: - Rose House Dining Room (West Campus)

        Eatery(
            id: 3,
            cornellId: 1003,
            announcements: ["Chef's Table tonight: Pasta Night"],
            name: "Rose House Dining Room",
            shortName: "Rose",
            about:
            "All-you-care-to-eat dining room located in Flora Rose House on West Campus.",
            shortAbout: "West Campus Dining Hall.",
            cornellDining: true,
            menuSummary: "Hot Traditional • Grill • Salad Bar",
            imageUrl: "https://example.com/rose.jpg",
            campusArea: .west,
            onlineOrderUrl: nil,
            contactPhone: nil,
            contactEmail: nil,
            latitude: 42.4460,
            longitude: -76.4900,
            location: "Flora Rose House",
            paymentMethods: [.mealSwipe, .brbs],
            eateryTypes: [.diningRoom],
            createdAt: Date(),
            events: [
                Event(
                    id: 301,
                    type: .dinner,
                    startTimestamp: Date().addingTimeInterval(3600 * 6),
                    endTimestamp: Date().addingTimeInterval(3600 * 9),
                    upvotes: 12,
                    downvotes: 5,
                    createdAt: Date(),
                    eateryId: 3,
                    menu: [
                        MenuCategory(
                            id: 3001,
                            name: "Chef's Table",
                            createdAt: Date(),
                            eventId: 301,
                            items: [
                                MenuItem(
                                    id: 5,
                                    name: "Penne alla Vodka",
                                    basePrice: nil,
                                    createdAt: Date(),
                                    categoryId: 3001,
                                    dietaryPreferences: [
                                        DietaryPreference(name: "Vegetarian")
                                    ],
                                    allergens: [
                                        Allergen(name: "Gluten"),
                                        Allergen(name: "Dairy")
                                    ]
                                ),
                                MenuItem(
                                    id: 6,
                                    name: "Garlic Bread",
                                    basePrice: nil,
                                    createdAt: Date(),
                                    categoryId: 3001,
                                    dietaryPreferences: [
                                        DietaryPreference(name: "Vegetarian")
                                    ],
                                    allergens: [Allergen(name: "Gluten")]
                                )
                            ]
                        )
                    ]
                )
            ]
        )
    ]
}
