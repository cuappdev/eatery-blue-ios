//
//  RootViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import UIKit

class RootViewController: UIViewController {

    private let theTabBarController = UITabBarController()

    private let homeViewController = HomeViewController()
    private let menusViewController = MenusViewController()
    private let profileViewController = ProfileViewController()

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

        let homeNavigationController = UINavigationController(rootViewController: homeViewController)

        let menusNavigationController = UINavigationController(rootViewController: menusViewController)
        menusNavigationController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "Calendar"),
            selectedImage: UIImage(named: "CalendarSelected")
        )
        menusNavigationController.navigationBar.prefersLargeTitles = true

        let profileNavigationController = UINavigationController(rootViewController: profileViewController)
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
        ) { [weak self] notification in
            guard let self = self else { return }
            guard let style = notification.userInfo?["statusBarStyle"] as? UIStatusBarStyle else { return }

            self.thePreferredStatusBarStyle = style
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

}
