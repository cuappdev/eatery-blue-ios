//
//  AppDelegate.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import AppDevAnnouncements
import Firebase
import FirebaseMessaging
import Hero
import Kingfisher
import SnapKit
import Tactile
import UIKit

import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier! // Your app's bundle identifier
    static let notifications = Logger(subsystem: subsystem, category: "notifications")
}

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    static let shared: AppDelegate = {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        return delegate
    }()

    private(set) lazy var coreDataStack = CoreDataStack()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Check for updates
        Task {
            do {
                let serverVersion = try await Networking.default.getAppVersion()
                let deviceVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"

                if shouldForceUpdate(device: deviceVersion, server: serverVersion) {
                    await MainActor.run {
                        showForceUpdateAlert(
                            appStoreURL: "https://apps.apple.com/us/app/eatery-cornell-dining/id1089672962"
                        )
                    }
                }
            } catch {
                print("Version check failed: \(error)")
            }
        }

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

        return true
    }

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
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
            }
        }
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logger.notifications.error("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _: UIApplication,
        didDiscardSceneSessions _: Set<UISceneSession>
    ) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running,
        // this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_: UIApplication, supportedInterfaceOrientationsFor _: UIWindow?) -> UIInterfaceOrientationMask {
        .portrait
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        Logger.notifications.info("Foreground notification received: \(notification.request.content.userInfo)")
        completionHandler([.banner, .badge, .sound])
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        Logger.notifications.info("Notification tapped: \(response.notification.request.content.userInfo)")
        completionHandler()
    }

    // MARK: - Helper functions

    func shouldForceUpdate(device: String, server: String) -> Bool {
        let parse = { (v: String) in v.split(separator: ".").prefix(2).compactMap { Int($0) } }

        let d = parse(device)
        let s = parse(server)

        // Compare arrays: [3, 4] > [3, 3]
        return s.lexicographicallyPrecedes(d) == false && s != d
    }

    @MainActor
    private func showForceUpdateAlert(appStoreURL: String) {
        let alert = UIAlertController(
            title: "Update Required",
            message: "A new version of Eatery is available.",
            preferredStyle: .alert
        )

        let updateAction = UIAlertAction(title: "Update Now", style: .default) { _ in
            if let url = URL(string: appStoreURL) {
                UIApplication.shared.open(url)
            }

            self.showForceUpdateAlert(appStoreURL: appStoreURL)
        }

        alert.addAction(updateAction)

        // Find the current active window's rootViewController
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            // Find the top-most controller (in case a modal is already up)
            var topController = rootVC
            while let presented = topController.presentedViewController {
                topController = presented
            }
            topController.present(alert, animated: true)
        }
    }
}
