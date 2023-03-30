//
//  SchemaToModel.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import Foundation

internal enum SchemaToModel {

    internal static func convert(_ schemaEatery: Schema.Eatery) -> Eatery {
        Eatery(
            alerts: convert(schemaEatery.alerts),
            campusArea: schemaEatery.campusArea,
            events: convert(schemaEatery.events),
            id: schemaEatery.id,
            imageUrl: convert(schemaEatery.imageUrl),
            latitude: schemaEatery.latitude,
            locationDescription: schemaEatery.location,
            longitude: schemaEatery.longitude,
            menuSummary: schemaEatery.menuSummary,
            name: schemaEatery.name ?? "",
            onlineOrderUrl: schemaEatery.onlineOrderUrl,
            paymentMethods: convert(
                acceptsBrbs: schemaEatery.paymentAcceptsBrbs,
                acceptsCash: schemaEatery.paymentAcceptsCash,
                acceptsMealSwipes: schemaEatery.paymentAcceptsMealSwipes
            ),
            waitTimesByDay: convert(schemaEatery.waitTimes)
        )
    }

    internal static func convert(_ schemaUrl: String?) -> URL? {
        guard let url = schemaUrl else {
            return nil
        }

        return URL(string: url)
    }

    internal static func convert(_ schemaAlerts: [Schema.Alert]?) -> [EateryAlert] {
        guard let schemaAlerts = schemaAlerts else {
            return []
        }

        return schemaAlerts.map(convert)
    }

    internal static func convert(_ schemaAlert: Schema.Alert) -> EateryAlert {
        EateryAlert(
            description: schemaAlert.description,
            endTimestamp: schemaAlert.endTimestamp,
            id: schemaAlert.id,
            startTimestamp: schemaAlert.startTimestamp
        )
    }

    internal static func convert(acceptsBrbs: Bool?, acceptsCash: Bool?, acceptsMealSwipes: Bool?) -> Set<PaymentMethod> {
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

    internal static func convert(_ schemaEvents: [Schema.Event]?) -> [Event] {
        guard let schemaEvents = schemaEvents else {
            return []
        }

        return schemaEvents.compactMap(convert)
    }

    internal static func convert(_ schemaEvent: Schema.Event) -> Event? {
        let df = ISO8601DateFormatter()
        guard let start = schemaEvent.start, let end = schemaEvent.end, let startDate = df.date(from: start), let endDate = df.date(from: end) else {
            return nil
        }
        
        func getTimeInSeconds(from date : Date) -> Int {
            let calendar = Calendar.eatery
            return calendar.component(.hour, from: date) * 360 + calendar.component(.minute, from: date) * 60 + calendar.component(.second, from: date)
        }
        
        let startTime = getTimeInSeconds(from: startDate)
        let endTime = getTimeInSeconds(from: endDate)

        let menu: Menu?
        if let schemaMenuCategories = schemaEvent.menu {
            menu = Menu(categories: schemaMenuCategories.map(convert))
        } else {
            menu = nil
        }

        return Event(
            canonicalDay: Day(date: startDate),
            description: schemaEvent.eventDescription,
            endTimestamp: TimeInterval(startTime),
            menu: menu,
            startTimestamp: TimeInterval(endTime)
        )
    }

    internal static func convert(_ schemaMenuCategory: Schema.MenuCategory) -> MenuCategory {
        MenuCategory(
            category: schemaMenuCategory.category,
            items: schemaMenuCategory.items.map(convert)
        )
    }

    internal static func convert(_ schemaMenuItem: Schema.MenuItem) -> MenuItem {
        MenuItem(
            description: nil,
            healthy: schemaMenuItem.healthy ?? false,
            name: schemaMenuItem.name,
            price: nil
        )
    }

    internal static func convert(_ schemaWaitTimesByDay: [Schema.WaitTimesByDay]?) -> [Day: WaitTimes] {
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

    internal static func convert(_ schemaWaitTimes: Schema.WaitTimes) -> WaitTimeSample {
        WaitTimeSample(
            timestamp: TimeInterval(schemaWaitTimes.timestamp),
            low: TimeInterval(schemaWaitTimes.waitTimeLow),
            expected: TimeInterval(schemaWaitTimes.waitTimeExpected),
            high: TimeInterval(schemaWaitTimes.waitTimeHigh)
        )
    }

}
