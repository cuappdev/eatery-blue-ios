//
//  SchemaToModel.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import Foundation

struct SchemaToModel {

    static func convert(_ schemaEatery: Schema.Eatery) -> Eatery {
        Eatery(
            name: schemaEatery.name,
            building: nil,
            imageUrl: nil,
            menuSummary: nil,
            paymentMethods: [],
            campusArea: schemaEatery.campusArea,
            events: schemaEatery.events?.compactMap(convert) ?? [],
            latitude: schemaEatery.latitude,
            longitude: schemaEatery.longitude
        )
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
            healthy: schemaMenuItem.healthy,
            name: schemaMenuItem.name,
            description: nil,
            price: nil
        )
    }

}
