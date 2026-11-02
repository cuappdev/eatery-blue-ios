//
//  FavoriteAPIModels.swift
//  Eatery Blue
//
//  Created by Arielle Nudelman on 11/2/26.
//

import Foundation

struct FavoriteEateryRequest: Encodable {
    let cornellId: Int
}

struct BackendUserResponse: Decodable {
    let user: BackendUser
}

struct BackendUser: Decodable {
    let deviceUuid: String
    let favoritedEateries: [BackendFavoriteEatery]
    let favoritedItemNames: [String]
}

struct BackendFavoriteEatery: Decodable {
    let cornellId: Int
}

struct BackendFavorites: Sendable {
    let itemNames: Set<String>
    let eateryIds: Set<Int>
}
