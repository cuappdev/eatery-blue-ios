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

    static let macs: Cafe = {
        let macs = Cafe()
        macs.name = "Mac's Café"
        macs.campusArea = "Central"
        macs.building = "Statler Hall"
        macs.cafeEvents = [
            Event(
                canonicalDay: Day(),
                startTimestamp: Date().timeIntervalSince1970 - 60 * 60,
                endTimestamp: Date().timeIntervalSince1970 + 60 * 60
            ),
            Event(
                canonicalDay: Day(),
                startTimestamp: Date().timeIntervalSince1970 + 120 * 60,
                endTimestamp: Date().timeIntervalSince1970 + 180 * 60
            )
        ]
        macs.latitude = 0
        macs.longitude = 0
        macs.menu = macsMenu
        macs.menuSummary = "Flatbreads, salads, pasta"
        macs.paymentMethods = [.brbs, .cash, .credit]
        macs.imageUrl = URL(string: "https://scontent-lga3-1.xx.fbcdn.net/v/t39.30808-6/242590986_530923285010728_5264780679289653070_n.jpg?_nc_cat=104&ccb=1-5&_nc_sid=09cbfe&_nc_ohc=OnHCbEW7uqoAX8Gog9J&_nc_ht=scontent-lga3-1.xx&oh=00_AT9VUFqgCt4eTeTCoTjCKdra3nyuzL5nwX19EgqdOTQfjg&oe=61C8901A")
        return macs
    }()

    static let macsOpenSoon: Cafe = {
        let macs = Cafe()
        macs.name = "Mac's Café - Open Soon"
        macs.campusArea = "Central"
        macs.building = "Statler Hall"
        macs.cafeEvents = [
            Event(
                canonicalDay: Day(),
                startTimestamp: Date().timeIntervalSince1970 + 30 * 60,
                endTimestamp: Date().timeIntervalSince1970 + 60 * 60
            )
        ]
        macs.latitude = 0
        macs.longitude = 0
        macs.menu = macsMenu
        macs.menuSummary = "Flatbreads, salads, pasta"
        macs.paymentMethods = [.brbs, .cash, .credit]
        macs.imageUrl = URL(string: "https://scontent-lga3-1.xx.fbcdn.net/v/t39.30808-6/242590986_530923285010728_5264780679289653070_n.jpg?_nc_cat=104&ccb=1-5&_nc_sid=09cbfe&_nc_ohc=OnHCbEW7uqoAX8Gog9J&_nc_ht=scontent-lga3-1.xx&oh=00_AT9VUFqgCt4eTeTCoTjCKdra3nyuzL5nwX19EgqdOTQfjg&oe=61C8901A")
        return macs
    }()

    static let macsClosed: Cafe = {
        let macs = Cafe()
        macs.name = "Mac's Café - Closed"
        macs.campusArea = "Central"
        macs.building = "Statler Hall"
        macs.cafeEvents = [
            Event(
                canonicalDay: Day(),
                startTimestamp: Date().timeIntervalSince1970 - 180 * 60,
                endTimestamp: Date().timeIntervalSince1970 - 120 * 60
            )
        ]
        macs.latitude = 0
        macs.longitude = 0
        macs.menu = macsMenu
        macs.menuSummary = "Flatbreads, salads, pasta"
        macs.paymentMethods = [.brbs, .cash, .credit]
        macs.imageUrl = URL(string: "https://scontent-lga3-1.xx.fbcdn.net/v/t39.30808-6/242590986_530923285010728_5264780679289653070_n.jpg?_nc_cat=104&ccb=1-5&_nc_sid=09cbfe&_nc_ohc=OnHCbEW7uqoAX8Gog9J&_nc_ht=scontent-lga3-1.xx&oh=00_AT9VUFqgCt4eTeTCoTjCKdra3nyuzL5nwX19EgqdOTQfjg&oe=61C8901A")
        return macs
    }()

    static let macsClosingSoon: Cafe = {
        let macs = Cafe()
        macs.name = "Mac's Café - Closing Soon"
        macs.campusArea = "Central"
        macs.building = "Statler Hall"
        macs.cafeEvents = [
            Event(
                canonicalDay: Day(),
                startTimestamp: Date().timeIntervalSince1970 - 30 * 60,
                endTimestamp: Date().timeIntervalSince1970 + 30 * 60
            )
        ]
        macs.latitude = 0
        macs.longitude = 0
        macs.menu = macsMenu
        macs.menuSummary = "Flatbreads, salads, pasta"
        macs.paymentMethods = [.brbs, .cash, .credit]
        macs.imageUrl = URL(string: "https://scontent-lga3-1.xx.fbcdn.net/v/t39.30808-6/242590986_530923285010728_5264780679289653070_n.jpg?_nc_cat=104&ccb=1-5&_nc_sid=09cbfe&_nc_ohc=OnHCbEW7uqoAX8Gog9J&_nc_ht=scontent-lga3-1.xx&oh=00_AT9VUFqgCt4eTeTCoTjCKdra3nyuzL5nwX19EgqdOTQfjg&oe=61C8901A")
        return macs
    }()

    static let rpcc: DiningHall = {
        let eatery = DiningHall()
        eatery.name = "RPCC"
        eatery.paymentMethods = [.cash, .credit, .brbs, .mealSwipes]
        eatery.campusArea = "North"
        eatery.building = "Robert Purcell Community Center"
        eatery.longitude = -76.477354
        eatery.latitude = 42.455973
        eatery.menuSummary = "Cornell Dining"
        eatery.imageUrl = URL(string: "https://resizer.otstatic.com/v2/photos/wide-huge/1/31826674.jpg")

        let breakfast = DiningHallEvent(
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

        let lunch = DiningHallEvent(
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
                MenuItem(healthy: true, name: "Honey SOy Baked Chicken with Peppers")
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

        let dinner = DiningHallEvent(
            canonicalDay: Day(),
            startTimestamp: Day().date(hour: 17, minute: 0).timeIntervalSince1970,
            endTimestamp: Day().date(hour: 19, minute: 30).timeIntervalSince1970
        )
        dinner.description = "Dinner"

        eatery.diningHallEvents = [
            breakfast, lunch, dinner
        ]
        return eatery
    }()

}
