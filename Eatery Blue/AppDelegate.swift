//
//  AppDelegate.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import AppDevAnnouncements
import Firebase
import Hero
import Kingfisher
import SnapKit
import Tactile
import UIKit
import FirebaseMessaging

import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier! // Your app's bundle identifier
    static let notifications = Logger(subsystem: subsystem, category: "notifications")
}

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    static let shared = UIApplication.shared.delegate as! AppDelegate

    private(set) lazy var coreDataStack = CoreDataStack()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()

        // Request notification permissions
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if let error = error {
                Logger.notifications.error("Failed to request notification permissions: \(error.localizedDescription)")
            } else {
                Logger.notifications.info("Notification permissions granted: \(granted)")
            }
        }

        application.registerForRemoteNotifications()

        // Setup AppDevAnnouncements
        AnnouncementNetworking.setupConfig(
            scheme: EateryEnvironment.announcementsScheme,
            host: EateryEnvironment.announcementsHost,
            commonPath: EateryEnvironment.announcementsCommonPath,
            announcementPath: EateryEnvironment.announcementsPath
        )

        // restore saved fcm token
        PushNotificationManager.shared.loadSavedToken()
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Set APNs token for Firebase Messaging
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Logger.notifications.info("APNs device token received: \(tokenString)")
        Messaging.messaging().apnsToken = deviceToken

        // Fetch FCM token once APNs token is set
        Messaging.messaging().token { token, error in
            if let error = error {
                Logger.notifications.error("Error fetching FCM token: \(error.localizedDescription)")
            } else if let token = token {
                Logger.notifications.info("FCM registration token: \(token)")
                PushNotificationManager.shared.updateFCMToken(token)
            }
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logger.notifications.error("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        .portrait
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Logger.notifications.info("Foreground notification received: \(notification.request.content.userInfo)")
        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        Logger.notifications.info("Notification tapped: \(response.notification.request.content.userInfo)")
        completionHandler()
    }
}
