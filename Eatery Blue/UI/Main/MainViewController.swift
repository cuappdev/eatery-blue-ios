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

        theTabBarController.setViewControllers([
            homeNavigationController
        ], animated: false)

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        theTabBarController.tabBar.standardAppearance = tabBarAppearance
        theTabBarController.tabBar.scrollEdgeAppearance = tabBarAppearance
    }

}
