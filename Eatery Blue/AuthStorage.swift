//
//  AuthStorage.swift
//  Eatery Blue
//
//  Created by Arielle Nudelman on 9/26/26.
//

import Foundation

struct BackendAuthTokens: Decodable, Sendable {
    let accessToken: String
    let refreshToken: String
}

enum AuthStorage {
    static var deviceId: String {
        if let existingId = UserDefaults.standard.string(
            forKey: UserDefaultsKeys.backendDeviceId
        ) {
            return existingId
        }

        let newId = UUID().uuidString
        UserDefaults.standard.set(
            newId,
            forKey: UserDefaultsKeys.backendDeviceId
        )
        return newId
    }
}
