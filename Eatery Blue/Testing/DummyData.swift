//
//  DummyData.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import Foundation

enum DummyData {

    static let macsMenu = Menu(categories: [
        MenuCategory(category: "Enchiladas", items: [
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
    ])

    static let macs: Eatery = {
        var macs = Eatery()
        macs.name = "Mac's Café"
        macs.campusArea = "Central"
        macs.building = "Statler Hall"
        macs.events = (0..<5).map { offset in
            Event(
                canonicalDay: Day().advanced(by: offset),
                startTimestamp: Day().advanced(by: offset).date(hour: 7, minute: 0).timeIntervalSince1970,
                endTimestamp: Day().advanced(by: offset).date(hour: 17, minute: 30).timeIntervalSince1970,
                menu: macsMenu
            )
        }
        macs.menuSummary = "Flatbreads, salads, pasta"
        macs.paymentMethods = [.brbs, .cash, .credit]
        macs.imageUrl = URL(string: "https://scontent-lga3-1.xx.fbcdn.net/v/t39.30808-6/242590986_530923285010728_5264780679289653070_n.jpg?_nc_cat=104&ccb=1-5&_nc_sid=09cbfe&_nc_ohc=OnHCbEW7uqoAX8Gog9J&_nc_ht=scontent-lga3-1.xx&oh=00_AT9VUFqgCt4eTeTCoTjCKdra3nyuzL5nwX19EgqdOTQfjg&oe=61C8901A")
        return macs
    }()

    static let macsOpen: Eatery = {
        var macs = Eatery()
        macs.name = "Mac's Café - Open"
        macs.campusArea = "Central"
        macs.building = "Statler Hall"
        macs.events = [
            Event(
                canonicalDay: Day(),
                startTimestamp: Date().timeIntervalSince1970 - 30 * 60,
                endTimestamp: Date().timeIntervalSince1970 + 120 * 60,
                menu: macsMenu
            )
        ]
        macs.menuSummary = "Flatbreads, salads, pasta"
        macs.paymentMethods = [.brbs, .cash, .credit]
        macs.imageUrl = URL(string: "https://scontent-lga3-1.xx.fbcdn.net/v/t39.30808-6/242590986_530923285010728_5264780679289653070_n.jpg?_nc_cat=104&ccb=1-5&_nc_sid=09cbfe&_nc_ohc=OnHCbEW7uqoAX8Gog9J&_nc_ht=scontent-lga3-1.xx&oh=00_AT9VUFqgCt4eTeTCoTjCKdra3nyuzL5nwX19EgqdOTQfjg&oe=61C8901A")
        return macs
    }()

    static let macsOpenSoon: Eatery = {
        var macs = Eatery()
        macs.name = "Mac's Café - Open Soon"
        macs.campusArea = "Central"
        macs.building = "Statler Hall"
        macs.events = [
            Event(
                canonicalDay: Day(),
                startTimestamp: Date().timeIntervalSince1970 + 30 * 60,
                endTimestamp: Date().timeIntervalSince1970 + 60 * 60,
                menu: macsMenu
            )
        ]
        macs.menuSummary = "Flatbreads, salads, pasta"
        macs.paymentMethods = [.brbs, .cash, .credit]
        macs.imageUrl = URL(string: "https://scontent-lga3-1.xx.fbcdn.net/v/t39.30808-6/242590986_530923285010728_5264780679289653070_n.jpg?_nc_cat=104&ccb=1-5&_nc_sid=09cbfe&_nc_ohc=OnHCbEW7uqoAX8Gog9J&_nc_ht=scontent-lga3-1.xx&oh=00_AT9VUFqgCt4eTeTCoTjCKdra3nyuzL5nwX19EgqdOTQfjg&oe=61C8901A")
        return macs
    }()

    static let macsClosed: Eatery = {
        var macs = Eatery()
        macs.name = "Mac's Café - Closed"
        macs.campusArea = "Central"
        macs.building = "Statler Hall"
        macs.events = [
            Event(
                canonicalDay: Day(),
                startTimestamp: Date().timeIntervalSince1970 - 180 * 60,
                endTimestamp: Date().timeIntervalSince1970 - 120 * 60,
                menu: macsMenu
            )
        ]
        macs.menuSummary = "Flatbreads, salads, pasta"
        macs.paymentMethods = [.brbs, .cash, .credit]
        macs.imageUrl = URL(string: "https://scontent-lga3-1.xx.fbcdn.net/v/t39.30808-6/242590986_530923285010728_5264780679289653070_n.jpg?_nc_cat=104&ccb=1-5&_nc_sid=09cbfe&_nc_ohc=OnHCbEW7uqoAX8Gog9J&_nc_ht=scontent-lga3-1.xx&oh=00_AT9VUFqgCt4eTeTCoTjCKdra3nyuzL5nwX19EgqdOTQfjg&oe=61C8901A")
        return macs
    }()

    static let macsClosingSoon: Eatery = {
        var macs = Eatery()
        macs.name = "Mac's Café - Closing Soon"
        macs.campusArea = "Central"
        macs.building = "Statler Hall"
        macs.events = [
            Event(
                canonicalDay: Day(),
                startTimestamp: Date().timeIntervalSince1970 - 30 * 60,
                endTimestamp: Date().timeIntervalSince1970 + 30 * 60,
                menu: macsMenu
            )
        ]
        macs.menuSummary = "Flatbreads, salads, pasta"
        macs.paymentMethods = [.brbs, .cash, .credit]
        macs.imageUrl = URL(string: "https://scontent-lga3-1.xx.fbcdn.net/v/t39.30808-6/242590986_530923285010728_5264780679289653070_n.jpg?_nc_cat=104&ccb=1-5&_nc_sid=09cbfe&_nc_ohc=OnHCbEW7uqoAX8Gog9J&_nc_ht=scontent-lga3-1.xx&oh=00_AT9VUFqgCt4eTeTCoTjCKdra3nyuzL5nwX19EgqdOTQfjg&oe=61C8901A")
        return macs
    }()

    static let rpcc: Eatery = {
        var eatery = Eatery()
        eatery.name = "RPCC"
        eatery.paymentMethods = [.cash, .credit, .brbs, .mealSwipes]
        eatery.campusArea = "North"
        eatery.building = "Robert Purcell Community Center"
        eatery.location = EateryLocation(latitude: 42.455973, longitude: -76.477354)
        eatery.menuSummary = "Cornell Dining"
        eatery.imageUrl = URL(string: "https://resizer.otstatic.com/v2/photos/wide-huge/1/31826674.jpg")

        var breakfast = Event(
            canonicalDay: Day(),
            startTimestamp: Day().date(hour: 7, minute: 0).timeIntervalSince1970,
            endTimestamp: Day().date(hour: 10, minute: 30).timeIntervalSince1970
        )
        breakfast.description = "Breakfast"
        breakfast.menu = Menu(categories: [
            MenuCategory(category: "Breakfast Station - Hot", items: [
                MenuItem(healthy: true, name: "Scrambled Eggs"),
                MenuItem(healthy: true, name: "Hard Boiled Eggs"),
                MenuItem(healthy: false, name: "Pork Breakfast Sausage"),
                MenuItem(healthy: true, name: "Home Fries"),
                MenuItem(healthy: false, name: "Pancakes with Syrup"),
                MenuItem(healthy: false, name: "French Toast Sticks"),
                MenuItem(healthy: false, name: "Steamed Jasmine Rice")
            ]),
            MenuCategory(category: "Grill Station", items: [
                MenuItem(healthy: true, name: "Scrambled Tofu"),
                MenuItem(healthy: true, name: "Sauteed Vegetables")
            ]),
            MenuCategory(category: "Specialty Station", items: [
                MenuItem(healthy: true, name: "Fresh Fruit Slices"),
                MenuItem(healthy: true, name: "Fresh Whole Fruit"),
                MenuItem(healthy: true, name: "Fruit & Yogurt Bar"),
                MenuItem(healthy: true, name: "Oatmeal with Brown Sugar & Raisins"),
                MenuItem(healthy: false, name: "Waffle Bar"),
                MenuItem(healthy: false, name: "Assorted Cereal"),
                MenuItem(healthy: false, name: "Bagels & Baked Goods")
            ])
        ])

        var lunch = Event(
            canonicalDay: Day(),
            startTimestamp: Day().date(hour: 10, minute: 30).timeIntervalSince1970,
            endTimestamp: Day().date(hour: 14, minute: 30).timeIntervalSince1970
        )
        lunch.description = "Lunch"
        lunch.menu = Menu(categories: [
            MenuCategory(category: "Soup Station", items: [
                MenuItem(healthy: true, name: "Beef Vegetable Soup")
            ]),
            MenuCategory(category: "Salad Bar Station", items: [
                MenuItem(healthy: true, name: "Salad Bar"),
                MenuItem(healthy: true, name: "Grains For Brains"),
                MenuItem(healthy: false, name: "House Made Dressings")
            ]),
            MenuCategory(category: "Hot Traditional Station - Entrees", items: [
                MenuItem(healthy: false, name: "Pasta Primavera"),
                MenuItem(healthy: true, name: "Honey Soy Baked Chicken with Peppers")
            ]),
            MenuCategory(category: "Hot Tranditional Station - Sides", items: [
                MenuItem(healthy: false, name: "Potato Tots"),
                MenuItem(healthy: true, name: "Calabacitas"),
                MenuItem(healthy: true, name: "Sauteed Broccoli")
            ]),
            MenuCategory(category: "Grill Station", items: [
                MenuItem(healthy: false, name: "Hacienda Cheese Quesadilla"),
                MenuItem(healthy: false, name: "Grilled Cheese Sandwich")
            ])
        ])

        var dinner = Event(
            canonicalDay: Day(),
            startTimestamp: Day().date(hour: 17, minute: 0).timeIntervalSince1970,
            endTimestamp: Day().date(hour: 19, minute: 30).timeIntervalSince1970
        )
        dinner.description = "Dinner"

        let breakfastTomorrow = Event(
            canonicalDay: breakfast.canonicalDay.advanced(by: 1),
            startTimestamp: breakfast.startTimestamp + 24 * 60 * 60,
            endTimestamp: breakfast.endTimestamp + 24 * 60 * 60,
            description: nil,
            menu: breakfast.menu
        )

        eatery.events = [
            breakfast, lunch, dinner, breakfastTomorrow
        ]
        return eatery
    }()

}
