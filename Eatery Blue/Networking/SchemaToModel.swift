//
//  SchemaToModel.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import os.log
import Foundation

struct SchemaToModel {

    static func convert(_ schemaEatery: Schema.Eatery) -> Eatery {
        Eatery(
            name: schemaEatery.name,
            building: nil,
            imageUrl: nil,
            menuSummary: nil,
            paymentMethods: convert(schemaEatery.paymentMethods),
            campusArea: schemaEatery.campusArea,
            events: schemaEatery.events?.compactMap(convert) ?? [],
            location: convert(latitude: schemaEatery.latitude, longitude: schemaEatery.longitude),
            waitTimesByDay: schemaEatery.waitTimesByDay.map(convert) ?? [:]
        )
    }

    static func convert(_ schemaPaymentMethods: [Schema.PaymentMethod]) -> Set<PaymentMethod> {
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

    static func convert(latitude: Double?, longitude: Double?) -> EateryLocation? {
        if let latitude = latitude, let longitude = longitude {
            return EateryLocation(latitude: latitude, longitude: longitude)
        } else {
            return nil
        }
    }

    static func convert(_ schemaMenuCategory: Schema.MenuCategory) -> MenuCategory {
        MenuCategory(
            category: schemaMenuCategory.category,
            items: schemaMenuCategory.items.map(convert)
        )
    }

    static func convert(_ schemaMenuItem: Schema.MenuItem) -> MenuItem {
        MenuItem(
            healthy: schemaMenuItem.healthy,
            name: schemaMenuItem.name,
            description: nil,
            price: nil
        )
    }

    static func convert(_ schemaWaitTimesByDay: [Schema.WaitTimesByDay]) -> [Day: WaitTimes] {
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
