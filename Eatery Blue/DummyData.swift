//
//  DummyData.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import Foundation

enum DummyData {

    static let macs = Cafe(
        name: "Mac's Café",
        campusArea: "Central",
        building: "Statler Hall",
        events: [
            CafeEvent(
                canonicalDate: Day(year: 2021, month: 12, day: 22),
                startTimestamp: Int(Date().timeIntervalSince1970) - 60,
                endTimestamp: Int(Date().timeIntervalSince1970) + 60
            )
        ],
        latitude: 0,
        longitude: 0,
        menu: Menu(categories: [
            MenuCategory(category: "Enchilads", items: [
                MenuItem(
                    healthy: false,
                    name: "Chicken",
                    description: "A tortilla-wrapped chicken enchilada with your choice of toppings.",
                    price: 625
                ),
                MenuItem(
                    healthy: false,
                    name: "Bean & Corn",
                    description: "A tortilla-wrapped bean and corn enchilada with your choice of toppings.",
                    price: 525
                ),
            ]),
            MenuCategory(category: "Salads", items: [
                MenuItem(
                    healthy: true,
                    name: "Chopped Salad",
                    description: "A tortilla-wrapped chicken enchilada with your choice of toppings.",
                    price: 1100
                )
            ])
        ]),
        menuSummary: "Flatbreads, salads, pasta",
        imageUrl: URL(string: "https://scontent-lga3-1.xx.fbcdn.net/v/t39.30808-6/242590986_530923285010728_5264780679289653070_n.jpg?_nc_cat=104&ccb=1-5&_nc_sid=09cbfe&_nc_ohc=OnHCbEW7uqoAX8Gog9J&_nc_ht=scontent-lga3-1.xx&oh=00_AT9VUFqgCt4eTeTCoTjCKdra3nyuzL5nwX19EgqdOTQfjg&oe=61C8901A")
    )

}
