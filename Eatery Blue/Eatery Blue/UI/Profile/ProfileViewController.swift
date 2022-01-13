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

    private var currentMode: Mode = .login

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationController()
        setUpConstraints()

        setMode(currentMode, animated: false)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didLogOut(_:)),
            name: Networking.didLogOutNotification,
            object: nil
        )
    }

    private func setUpNavigationController() {
        addChild(theNavigationController)
        view.addSubview(theNavigationController.view)
        theNavigationController.didMove(toParent: self)

        theNavigationController.delegate = self
        theNavigationController.navigationBar.prefersLargeTitles = true
    }

    private func setUpConstraints() {
        theNavigationController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setMode(_ mode: Mode, animated: Bool) {
        currentMode = mode

        let viewController: UIViewController
        switch mode {
        case .login:
            let login = ProfileLoginModelController()
            login.delegate = self
            viewController = login

        case .account:
            viewController = AccountModelController()
        }

        var viewControllers = theNavigationController.viewControllers
        if viewControllers.isEmpty {
            viewControllers.append(viewController)
        } else {
            viewControllers[0] = viewController
        }
        theNavigationController.setViewControllers(viewControllers, animated: animated)
    }

    @objc private func didLogOut(_ notification: Notification) {
        setMode(.login, animated: false)
        theNavigationController.popToRootViewController(animated: true)
    }

}

extension ProfileViewController: ProfileLoginModelControllerDelegate {

    func profileLoginModelController(_ viewController: ProfileLoginModelController, didLogin sessionId: String) {
        setMode(.account, animated: true)
    }

}

extension ProfileViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let hideNavigationBar = viewController is ProfileLoginViewController
        navigationController.setNavigationBarHidden(hideNavigationBar, animated: animated)
    }

}
