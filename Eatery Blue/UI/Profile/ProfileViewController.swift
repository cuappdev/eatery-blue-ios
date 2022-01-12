//
//  ProfileViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/7/22.
//

import UIKit

class ProfileViewController: UIViewController {

    enum Mode {
        case account
        case login
    }

    private var theNavigationController = UINavigationController()
    private let account = AccountModelController()
    private let login = ProfileLoginModelController()

    private var currentMode: Mode = .login

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationController()
        setUpAccountController()
        setUpLoginController()
        setUpConstraints()

        setMode(currentMode)
    }

    private func setUpNavigationController() {
        addChild(theNavigationController)
        view.addSubview(theNavigationController.view)
        theNavigationController.didMove(toParent: self)

        // Pick a view controller to be the root, doesn't matter which in particular
        theNavigationController.viewControllers = [login]

        theNavigationController.delegate = self
        theNavigationController.navigationBar.prefersLargeTitles = true
    }

    private func setUpAccountController() {
    }

    private func setUpLoginController() {
        login.delegate = self
    }

    private func setUpConstraints() {
        theNavigationController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setMode(_ mode: Mode) {
        currentMode = mode

        switch mode {
        case .login:
            theNavigationController.viewControllers[0] = login

        case .account:
            theNavigationController.viewControllers[0] = account
        }
    }

}

extension ProfileViewController: ProfileLoginModelControllerDelegate {

    func profileLoginModelController(_ viewController: ProfileLoginModelController, didLogin sessionId: String) {
        setMode(.account)
    }

}

extension ProfileViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let hideNavigationBar = viewController is ProfileLoginViewController
        navigationController.setNavigationBarHidden(hideNavigationBar, animated: animated)
    }

}
