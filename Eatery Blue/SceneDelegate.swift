//
//  SceneDelegate.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let window = UIWindow(windowScene: windowScene)
        let rootViewController = RootModelController()
        window.rootViewController = rootViewController

        let savedStyle: UIUserInterfaceStyle
        switch UserDefaults.standard.string(forKey: "Settings.DisplayTheme") {
        case "light":
            savedStyle = .light
        case "dark":
            savedStyle = .dark
        default:
            savedStyle = .unspecified
        }
        window.overrideUserInterfaceStyle = savedStyle

        self.window = window
        window.makeKeyAndVisible()

        // Also apply to any other windows in the scene
        windowScene.windows.forEach { $0.overrideUserInterfaceStyle = savedStyle }
    }

    func sceneDidDisconnect(_: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see
        // `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let savedStyle: UIUserInterfaceStyle
        switch UserDefaults.standard.string(forKey: "Settings.DisplayTheme") {
        case "light":
            savedStyle = .light
        case "dark":
            savedStyle = .dark
        default:
            savedStyle = .unspecified
        }
        windowScene.windows.forEach { $0.overrideUserInterfaceStyle = savedStyle }
    }

    func sceneWillResignActive(_: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
