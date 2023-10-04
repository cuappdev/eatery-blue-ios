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
    
    static let shared: KeychainAccess = KeychainAccess()

    /// Saves session token to Keychain under "GETLogin", access with KeychainAccess.shared.retrieveToken
    func saveToken(sessionId: String) {
        // Invalidate old token if exists
        invalidateToken()
        
        // Save session token to Keychain
        let token = sessionId
        
        // Create the add query with the token as a password
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "GETLogin",
            kSecValueData as String: token.data(using: .utf8)!,
        ]
        let _ = SecItemAdd(keychainQuery as CFDictionary, nil)
    }
    
    /// Deletes token under "GETLogin" if it exists
    func invalidateToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "GETLogin"
        ]
        
        Task {
            let status = SecItemDelete(query as CFDictionary)
            guard status == errSecSuccess || status == errSecItemNotFound else { return }
        }
    }
    
    /// Returns token under "GETLogin" if it exists, nil otherwise
    func retrieveToken() -> String? {
        // Retrieve session token back from Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "GETLogin",
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
