//
//  ProfileViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/7/22.
//

import UIKit

class ProfileViewController: UIViewController {

    private let account = AccountViewController()
    private let login = ProfileLoginViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigation()

        addChild(login)
        view.addSubview(login.view)
        login.view.edgesToSuperview()
        login.didMove(toParent: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        RootViewController.setStatusBarStyle(.darkContent) 
    }

    private func setUpNavigation() {
        navigationController?.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "User"),
            selectedImage: UIImage(named: "UserSelected")
        )
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

}
