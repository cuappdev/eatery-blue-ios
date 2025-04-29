//
//  FavoriteItemNotif.swift
//  Eatery Blue
//
//  Created by Cindy Liang on 2/22/25.
//

import Foundation
class FavoriteItemNotif {
    var itemName: String
    var date: String
    
    //eateries mjight need to be stored in a list
    //handle the cases where it is 1 eatery, 2 eateries, 3+ eateries (they will have diff text)
    var availableEateries: String
    var isSelected: Bool

    init (name:String, date:String,eateries:String) {
        self.itemName = name
        self.date = date
        self.availableEateries = eateries
        self.isSelected = false
    }
}
