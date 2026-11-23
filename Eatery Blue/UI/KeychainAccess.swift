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
        static let barcodeSeed = "GETBarcodeSeed"
        static let patronId = "GETPatronId"
        static let backendAccessToken = "BackendAccessToken"
        static let backendRefreshToken = "BackendRefreshToken"
        static let backendDeviceId = "BackendDeviceId"
    }

    // MARK: - GET Session

    func saveToken(sessionId: String) {
        // Clear previous user's barcode secrets on new login.
        invalidateAllGETSecrets()
        save(sessionId, account: Account.getSession)
    }

    func retrieveToken() -> String? {
        retrieve(account: Account.getSession)
    }

    func invalidateToken() {
        delete(account: Account.getSession)
    }

    // MARK: - GET Barcode

    func saveBarcodeSeed(_ seed: String) {
        save(seed, account: Account.barcodeSeed)
    }

    func retrieveBarcodeSeed() -> String? {
        retrieve(account: Account.barcodeSeed)
    }

    func savePatronId(_ patronId: String) {
        save(patronId, account: Account.patronId)
    }

    func retrievePatronId() -> String? {
        retrieve(account: Account.patronId)
    }

    func deleteBarcodeSeed() {
        delete(account: Account.barcodeSeed)
    }

    func deletePatronId() {
        delete(account: Account.patronId)
    }

    func invalidateAllGETSecrets() {
        delete(account: Account.getSession)
        delete(account: Account.barcodeSeed)
        delete(account: Account.patronId)
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

    func saveBackendDeviceId(_ deviceId: String) {
        save(deviceId, account: Account.backendDeviceId)
    }

    func retrieveBackendDeviceId() -> String? {
        retrieve(account: Account.backendDeviceId)
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
