//
//  KeychainAccess.swift
//  Eatery Blue
//
//  Created by Tiffany Pan on 9/28/23.
//

import Foundation
import Security

// https://developer.apple.com/documentation/security/keychain_services/keychain_items/adding_a_password_to_the_keychain

class KeychainAccess {
    static let shared: KeychainAccess = .init()

    /// Saves the token to Keychain under account, access with KeychainAccess.shared.retrieveToken
    /// account = "SessionId" for sessionId, "AccessToken" for access token, and "RefreshToken" for refresh token
    func saveToken(token: String, account: String) {
        // Invalidate old token if exists
        invalidateToken(account: account)

        // Create the add query with the token as a password
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecValueData as String: token.data(using: .utf8)!
        ]
        _ = SecItemAdd(keychainQuery as CFDictionary, nil)
    }

    /// Deletes token under account if it exists
    func invalidateToken(account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account
        ]

        Task {
            let status = SecItemDelete(query as CFDictionary)
            guard status == errSecSuccess || status == errSecItemNotFound else { return }
        }
    }

    /// Returns token under account if it exists, nil otherwise
    func retrieveToken(account: String) -> String? {
        // Retrieve token back from Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let retrieveStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if retrieveStatus == errSecSuccess, let data = dataTypeRef as? Data {
            let retrievedToken = String(data: data, encoding: .utf8)
            if let retrievedToken = retrievedToken {
                return retrievedToken
            }
        }
        return nil
    }
}
