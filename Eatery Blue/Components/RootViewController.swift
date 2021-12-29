//
//  RootViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import UIKit

class RootViewController: UIViewController {

    private let theTabBarController = UITabBarController()

    private let home = HomeModelController()
    private let menus = MenusViewController()
    private let profile = ProfileViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpStatusBarStyleNotifications()
    }

    private func setUpView() {
        addChild(theTabBarController)
        view.addSubview(theTabBarController.view)
        theTabBarController.view.edgesToSuperview()
        theTabBarController.didMove(toParent: self)

        let homeNavigationController = UINavigationController(rootViewController: home)

        let menusNavigationController = UINavigationController(rootViewController: menus)
        menusNavigationController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "Calendar"),
            selectedImage: UIImage(named: "CalendarSelected")
        )
        menusNavigationController.navigationBar.prefersLargeTitles = true

        let profileNavigationController = UINavigationController(rootViewController: profile)
        profileNavigationController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "User"),
            selectedImage: UIImage(named: "UserSelected")
        )
        profileNavigationController.navigationBar.prefersLargeTitles = true

        theTabBarController.setViewControllers([
            homeNavigationController,
            menusNavigationController,
            profileNavigationController
        ], animated: false)
    }

    static let statusBarStyleNotification = Notification.Name("RootViewController.statusBarStyleNotification")
    private var thePreferredStatusBarStyle: UIStatusBarStyle = .lightContent
    override var preferredStatusBarStyle: UIStatusBarStyle {
        thePreferredStatusBarStyle
    }

    static func setStatusBarStyle(_ statusBarStyle: UIStatusBarStyle) {
        NotificationCenter.default.post(
            name: RootViewController.statusBarStyleNotification,
            object: nil,
            userInfo: ["statusBarStyle": statusBarStyle]
        )
    }

    private func setUpStatusBarStyleNotifications() {
        NotificationCenter.default.addObserver(
            forName: RootViewController.statusBarStyleNotification,
            object: nil,
            queue: nil
        ) { [self] notification in
            guard let style = notification.userInfo?["statusBarStyle"] as? UIStatusBarStyle else { return }

            thePreferredStatusBarStyle = style
            setNeedsStatusBarAppearanceUpdate()
        }
    }

}
