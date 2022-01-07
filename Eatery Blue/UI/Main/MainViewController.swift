//
//  MainViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/4/22.
//

import UIKit

class MainViewController: UIViewController {

    private let theTabBarController = UITabBarController()
    private let home = HomeModelController()
    private let profile = ProfileViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
    }

    private func setUpView() {
        addChild(theTabBarController)
        view.addSubview(theTabBarController.view)
        theTabBarController.view.edgesToSuperview()
        theTabBarController.didMove(toParent: self)

        let homeNavigationController = UINavigationController(rootViewController: home)
        homeNavigationController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "Home"),
            selectedImage: UIImage(named: "HomeSelected")
        )
        homeNavigationController.setNavigationBarHidden(true, animated: false)

        let profileNavigationController = UINavigationController(rootViewController: profile)
        profileNavigationController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "User"),
            selectedImage: UIImage(named: "UserSelected")
        )
        profileNavigationController.setNavigationBarHidden(true, animated: false)

        theTabBarController.setViewControllers([
            homeNavigationController,
            profileNavigationController
        ], animated: false)

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        theTabBarController.tabBar.standardAppearance = tabBarAppearance
        theTabBarController.tabBar.scrollEdgeAppearance = tabBarAppearance
    }

}
