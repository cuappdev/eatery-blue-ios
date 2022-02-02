//
//  SchemaToModel.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import Foundation

enum SchemaToModel {

    static func convert(_ schemaEatery: Schema.Eatery) -> Eatery {
        Eatery(
            campusArea: schemaEatery.campusArea,
            events: convert(schemaEatery.events),
            id: schemaEatery.id,
            imageUrl: schemaEatery.imageUrl,
            latitude: schemaEatery.latitude,
            locationDescription: schemaEatery.location,
            longitude: schemaEatery.longitude,
            menuSummary: schemaEatery.menuSummary,
            name: schemaEatery.name,
            onlineOrderUrl: schemaEatery.onlineOrderUrl,
            paymentMethods: convert(
                acceptsBrbs: schemaEatery.paymentAcceptsBrbs,
                acceptsCash: schemaEatery.paymentAcceptsCash,
                acceptsMealSwipes: schemaEatery.paymentAcceptsMealSwipes
            ),
            waitTimesByDay: convert(schemaEatery.waitTimes)
        )
    }

    static func convert(acceptsBrbs: Bool?, acceptsCash: Bool?, acceptsMealSwipes: Bool?) -> Set<PaymentMethod> {
        var paymentMethods: Set<PaymentMethod> = []

        if acceptsBrbs ?? false {
            paymentMethods.insert(.brbs)
        }

        if acceptsCash ?? false {
            paymentMethods.insert(.cash)
        }

        if acceptsMealSwipes ?? false {
            paymentMethods.insert(.mealSwipes)
        }

        return paymentMethods
    }

    static func convert(_ schemaEvents: [Schema.Event]?) -> [Event] {
        guard let schemaEvents = schemaEvents else {
            return []
        }

        return schemaEvents.compactMap(convert)
    }

    static func convert(_ schemaEvent: Schema.Event) -> Event? {
        guard let day = Day(string: schemaEvent.canonicalDate) else {
            return nil
        }

        let menu: Menu?
        if let schemaMenuCategories = schemaEvent.menu {
            menu = Menu(categories: schemaMenuCategories.map(convert))
        } else {
            menu = nil
        }

        return Event(
            canonicalDay: day,
            description: schemaEvent.description,
            endTimestamp: TimeInterval(schemaEvent.endTimestamp),
            menu: menu,
            startTimestamp: TimeInterval(schemaEvent.startTimestamp)
        )
    }

    static func convert(_ schemaMenuCategory: Schema.MenuCategory) -> MenuCategory {
        MenuCategory(
            category: schemaMenuCategory.category,
            items: schemaMenuCategory.items.map(convert)
        )
    }

    static func convert(_ schemaMenuItem: Schema.MenuItem) -> MenuItem {
        MenuItem(
            description: nil,
            healthy: schemaMenuItem.healthy ?? false,
            name: schemaMenuItem.name,
            price: nil
        )
    }

    static func convert(_ schemaWaitTimesByDay: [Schema.WaitTimesByDay]?) -> [Day: WaitTimes] {
        guard let schemaWaitTimesByDay = schemaWaitTimesByDay else {
            return [:]
        }

        if schemaWaitTimesByDay.isEmpty {
            return [:]
        }

        var waitTimesByDay: [Day: WaitTimes] = [:]
        for schemaWaitTimesByDay in schemaWaitTimesByDay {
            guard let dayString = schemaWaitTimesByDay.canonicalDate,
                  let day = Day(string: dayString),
                  let waitTimes = schemaWaitTimesByDay.data,
                  !waitTimes.isEmpty
            else {
                continue
            }

            waitTimesByDay[day] = WaitTimes(samples: waitTimes.map(convert), samplingMethod: .nearestNeighbor)
        }

        return waitTimesByDay
    }

    static func convert(_ schemaWaitTimes: Schema.WaitTimes) -> WaitTimeSample {
        WaitTimeSample(
            timestamp: TimeInterval(schemaWaitTimes.timestamp),
            low: TimeInterval(schemaWaitTimes.waitTimeLow),
            expected: TimeInterval(schemaWaitTimes.waitTimeExpected),
            high: TimeInterval(schemaWaitTimes.waitTimeHigh)
        )
    }

}
