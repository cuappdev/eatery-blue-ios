//
//  NotificationManager.swift
//  Eatery Blue
//
//  Created by Adelynn Wu on 9/16/25.
//

import Foundation
import FirebaseMessaging

class PushNotificationManager {
    static let shared = PushNotificationManager()

    private init() {}

    private(set) var fcmToken: String?

    func updateFCMToken(_ token: String) {
        fcmToken = token
        UserDefaults.standard.set(token, forKey: "fcmToken")
    }

    func loadSavedToken() {
        fcmToken = UserDefaults.standard.string(forKey: "fcmToken")
    }
}
