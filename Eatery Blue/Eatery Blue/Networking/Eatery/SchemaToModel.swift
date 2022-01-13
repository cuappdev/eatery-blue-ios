//
//  SchemaToModel.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import EateryModel
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
            paymentMethods: convert(schemaEatery.paymentMethods),
            waitTimesByDay: convert(schemaEatery.waitTimesByDay)
        )
    }

    static func convert(_ schemaPaymentMethods: [Schema.PaymentMethod]?) -> Set<PaymentMethod> {
        guard let schemaPaymentMethods = schemaPaymentMethods else {
            return []
        }

        var paymentMethods: Set<PaymentMethod> = []
        for schemaPaymentMethod in schemaPaymentMethods {
            switch schemaPaymentMethod {
            case .brbs:
                paymentMethods.insert(.brbs)
            case .cash:
                paymentMethods.insert(.cash)
                paymentMethods.insert(.credit)
            case .swipes:
                paymentMethods.insert(.mealSwipes)
            }
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
            startTimestamp: TimeInterval(schemaEvent.startTimestamp),
            endTimestamp: TimeInterval(schemaEvent.endTimestamp),
            description: schemaEvent.description,
            menu: menu
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
                  let waitTimes = schemaWaitTimesByDay.waitTimes,
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
