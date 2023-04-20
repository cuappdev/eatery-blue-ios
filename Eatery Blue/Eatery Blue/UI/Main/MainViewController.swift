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
        theTabBarController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        theTabBarController.didMove(toParent: self)
        theTabBarController.delegate = self

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

extension MainViewController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        // If the home view controller is re-selected, scroll it to the top
        if tabBarController.selectedViewController == viewController,
           let navigationController = viewController as? UINavigationController,
           navigationController.viewControllers.count == 1,
           navigationController.viewControllers.first === home {

            home.scrollToTop()
        }

        return true
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 0 {
            AppDevAnalytics.shared.logFirebase(EateryPressPayload())
        } else if tabBarController.selectedIndex == 1 {
            AppDevAnalytics.shared.logFirebase(AccountPressPayload())
        }
    }

}
