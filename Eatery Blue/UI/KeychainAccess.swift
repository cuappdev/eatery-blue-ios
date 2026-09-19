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

    private enum Item {
        static let session = "GETLogin"
        static let barcodeSeed = "GETBarcodeSeed"
        static let patronId = "GETPatronId"
    }

    /// Saves session token to Keychain under "GETLogin", access with KeychainAccess.shared.retrieveToken
    func saveToken(sessionId: String) {
        // New login must not keep the previous user's barcode secrets.
        invalidateAllGETSecrets()
        save(sessionId, account: Item.session)
    }

    func retrieveToken() -> String? {
        retrieve(account: Item.session)
    }

    func saveBarcodeSeed(_ seed: String) {
        save(seed, account: Item.barcodeSeed)
    }

    func retrieveBarcodeSeed() -> String? {
        retrieve(account: Item.barcodeSeed)
    }

    func savePatronId(_ patronId: String) {
        save(patronId, account: Item.patronId)
    }

    func retrievePatronId() -> String? {
        retrieve(account: Item.patronId)
    }

    func deleteBarcodeSeed() {
        delete(account: Item.barcodeSeed)
    }

    func deletePatronId() {
        delete(account: Item.patronId)
    }

    // Session + seed + patron ID. Used on logout and dead GET session.
    func invalidateAllGETSecrets() {
        delete(account: Item.session)
        delete(account: Item.barcodeSeed)
        delete(account: Item.patronId)
    }

    private func save(_ value: String, account: String) {
        delete(account: account)
        guard let data = value.data(using: .utf8) else {
            return
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        _ = SecItemAdd(query as CFDictionary, nil)
    }

    private func retrieve(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        guard status == errSecSuccess, let data = dataTypeRef as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    private func delete(account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            return
        }
    }
}
