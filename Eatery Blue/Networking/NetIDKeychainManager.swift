//
//  NetIDKeychainManager.swift
//  Eatery Blue
//
//  Created by William Ma on 1/6/22.
//

import Foundation

struct NetIDKeychainManager {
    struct Credentials {
        var netId: String
        var password: String
    }

    enum KeychainError: Error {
        case stringEncodingError
        case notFound
        case unexpectedPasswordData
        case unhandledError(status: OSStatus)
    }

    static let shared = NetIDKeychainManager()

    private static let server = "https://shibidp.cit.cornell.edu/"

    func save(_ credentials: Credentials) throws {
        try delete()

        guard let passwordData = credentials.password.data(using: .utf8) else {
            throw KeychainError.stringEncodingError
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: credentials.netId,
            kSecAttrServer as String: NetIDKeychainManager.server,
            kSecValueData as String: passwordData
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    func get() throws -> Credentials {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: NetIDKeychainManager.server,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else {
            throw KeychainError.notFound
        }
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }

        guard let existingItem = item as? [String: Any],
              let passwordData = existingItem[kSecValueData as String] as? Data,
              let password = String(data: passwordData, encoding: .utf8),
              let account = existingItem[kSecAttrAccount as String] as? String
        else {
            throw KeychainError.unexpectedPasswordData
        }

        return Credentials(netId: account, password: password)
    }

    func delete() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: NetIDKeychainManager.server
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }
}
