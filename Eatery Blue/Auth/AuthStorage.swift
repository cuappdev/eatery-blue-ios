//
//  AuthStorage.swift
//  Eatery Blue
//
//  Created by Adelynn Wu on 3/4/26.
//

import Foundation

enum AuthStorage {
    static var deviceId: String {
        if let existing = UserDefaults.standard.string(forKey: UserDefaultsKeys.deviceId) {
            // device id has been created already
            return existing
        }
        
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: UserDefaultsKeys.deviceId)
        return newId
    }
    
    static var pin: String {
        if let existing = UserDefaults.standard.string(forKey: UserDefaultsKeys.pin) {
            return existing
        }
        
        let newPin = "1234"
        // GET login requires a user pin but we do not ask users to set a pin on frontend so here we are just using a dummy pin value
        UserDefaults.standard.set(newPin, forKey: UserDefaultsKeys.pin)
        
        return newPin
    }
}

