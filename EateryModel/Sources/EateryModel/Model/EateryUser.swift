//
//  EateryNotification.swift
//
//
//  Created by Peter Bidoshi on 10/12/24.
//

struct EateryUser: Decodable, Identifiable {

    let id: Int
    let name: String
    let netid: String
    let is_admin: Bool
    let favorite_eateries: [Eatery]
    
}
