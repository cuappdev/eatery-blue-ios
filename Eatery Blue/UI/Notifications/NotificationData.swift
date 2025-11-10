//
//  NotificationData.swift
//  Eatery Blue
//
//  Created by Hsia Lu wu on 11/9/25.
//

import Foundation

struct Notification {
    var itemName: String
    var eateries: [String]
    var date: Date
    var checked: Bool
    
    static let dummyData = [
        Notification(itemName: "Chicken Nuggets", eateries: ["Keeton House", "Okenshields", "Morrison Dining"], date: Date(), checked: false),
        Notification(itemName: "Orange Chicken", eateries: ["Becker House", "Okenshields"], date: Date(), checked: false),
        Notification(itemName: "Scrambled Eggs", eateries: ["Rose House"], date: Date(), checked: false)
    ]
}
