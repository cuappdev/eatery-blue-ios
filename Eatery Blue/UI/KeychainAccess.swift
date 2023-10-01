//
//  KeychainAccess.swift
//  Eatery Blue
//
//  Created by Tiffany Pan on 9/28/23.
//

import Security
import Foundation
// https://developer.apple.com/documentation/security/keychain_services/keychain_items/adding_a_password_to_the_keychain

class KeychainAccess {
    
    static let shared: KeychainAccess = KeychainAccess()
    
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
    
    func invalidateToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "GETLogin"
        ]
        
        Task {
            let status = SecItemDelete(query as CFDictionary)
            guard status == errSecSuccess || status == errSecItemNotFound else { return }
            logger.info("Successfully logged out")
        }
    }
    
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
