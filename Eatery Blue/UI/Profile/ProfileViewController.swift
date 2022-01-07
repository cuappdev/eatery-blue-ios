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

    private var currentViewController: UIViewController?
    private let account = AccountModelController()
    private let login = ProfileLoginModelController()

    private var currentMode: Mode = .login

    override func viewDidLoad() {
        super.viewDidLoad()

        setMode(currentMode)
        setUpAccountController()
        setUpLoginController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        RootViewController.setStatusBarStyle(.darkContent) 
    }

    private func setUpAccountController() {

    }

    private func setUpLoginController() {
        login.delegate = self
    }

    private func setMode(_ mode: Mode) {
        if let current = currentViewController {
            removeController(current)
        }

        currentMode = mode

        switch mode {
        case .login:
            addController(login)
            currentViewController = login

        case .account:
            addController(account)
            currentViewController = account
        }
    }

    private func addController(_ controller: UIViewController) {
        addChild(controller)
        view.addSubview(controller.view)
        controller.view.edgesToSuperview()
        controller.didMove(toParent: self)
    }

    private func removeController(_ controller: UIViewController) {
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
    }

}

extension ProfileViewController: ProfileLoginModelControllerDelegate {

    func profileLoginModelController(_ viewController: ProfileLoginModelController, didLogin sessionId: String) {
        account.setUp(sessionId)
        setMode(.account)
    }

}
