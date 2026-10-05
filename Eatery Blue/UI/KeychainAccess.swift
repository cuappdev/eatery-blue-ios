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
    static let shared = KeychainAccess()

    private enum Account {
        static let getSession = "GETLogin"
        static let backendAccessToken = "BackendAccessToken"
        static let backendRefreshToken = "BackendRefreshToken"
    }

    // MARK: - GET Session

    func saveToken(sessionId: String) {
        save(sessionId, account: Account.getSession)
    }

    func retrieveToken() -> String? {
        retrieve(account: Account.getSession)
    }

    func invalidateToken() {
        delete(account: Account.getSession)
    }

    // MARK: - Backend Authentication

    func saveBackendTokens(accessToken: String, refreshToken: String) {
        save(accessToken, account: Account.backendAccessToken)
        save(refreshToken, account: Account.backendRefreshToken)
    }

    func retrieveBackendAccessToken() -> String? {
        retrieve(account: Account.backendAccessToken)
    }

    func retrieveBackendRefreshToken() -> String? {
        retrieve(account: Account.backendRefreshToken)
    }

    func invalidateBackendTokens() {
        delete(account: Account.backendAccessToken)
        delete(account: Account.backendRefreshToken)
    }

    // MARK: - Keychain Helpers

    private func save(_ value: String, account: String) {
        guard let data = value.data(using: .utf8) else { return }

        delete(account: account)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecValueData as String: data
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            let message = SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error"
            logger.error("Failed to save Keychain item for \(account): \(message) (\(status))")
            return
        }
    }

    private func retrieve(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    private func delete(account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account
        ]

        SecItemDelete(query as CFDictionary)
    }
}
