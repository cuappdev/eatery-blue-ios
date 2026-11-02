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
        if let keychainId = KeychainAccess.shared.retrieveBackendDeviceId() {
            return keychainId
        }

        if let existingId = UserDefaults.standard.string(
            forKey: UserDefaultsKeys.backendDeviceId
        ) {
            KeychainAccess.shared.saveBackendDeviceId(existingId)
            return existingId
        }

        let newId = UUID().uuidString
        KeychainAccess.shared.saveBackendDeviceId(newId)
        UserDefaults.standard.set(
            newId,
            forKey: UserDefaultsKeys.backendDeviceId
        )
        return newId
    }

    static func saveDeviceId(_ deviceId: String) {
        KeychainAccess.shared.saveBackendDeviceId(deviceId)
        UserDefaults.standard.set(deviceId, forKey: UserDefaultsKeys.backendDeviceId)
    }
}
