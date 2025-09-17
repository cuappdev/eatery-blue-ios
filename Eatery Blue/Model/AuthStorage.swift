//
//  AuthStorage.swift
//  Eatery Blue
//
//  Created by Adelynn Wu on 9/16/25.
//

import Foundation
import Swift

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
            // pin has been created already
            return existing
        }
        
        let newPin = UUID().uuidString
        UserDefaults.standard.set(newPin, forKey: UserDefaultsKeys.pin)
        
        return newPin
    }
}
