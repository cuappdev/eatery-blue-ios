//
//  String+Extension.swift
//  Eatery Blue
//
//  Created by Jayson Hahn on 10/17/23.
//

import Foundation

extension String {
    static let Eatery = String()

    /**
     Determines the correct meal based on the time of day.

     This function gets the time of day from Date and returns a string of the meal type. If it is a specific meal time,
     that meal time is returned, and if it is not a specific meal time, the next meal time is returned.

     - Returns: If it is 10:30 pm - 10:29 am inclusive, breakfest is returned. If it is 10:30 am - 2:29 pm inclusive,
                lunch is returned. If it is 2:30 pm - 8:29 pm inclusive, dinner is returned.
                If it is 8:30 pm - 10:29 pm inclusive, late dinner is returned.
     */
    func mealFromTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        guard let hour = Int(dateFormatter.string(from: Date())) else { return "Breakfast" }
        dateFormatter.dateFormat = "mm"
        guard let minute = Int(dateFormatter.string(from: Date())) else { return "Breakfast" }
        if hour < 10 || hour == 10 && minute < 30 || hour >= 23 || hour == 22 && minute >= 30 {
            return "Breakfast"
        } else if hour == 10 && minute >= 30 || hour > 10 && hour < 14 || hour == 14 && minute < 30 {
            return "Lunch"
        } else if hour == 14 && minute >= 30 || hour > 14 && hour < 20 || hour == 20 && minute < 30 {
            return "Dinner"
        } else {
            return "Late Dinner"
        }
    }
}
