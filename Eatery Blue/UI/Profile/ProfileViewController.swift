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
        case demo
        case login
    }

    private var profileNavigationController = UINavigationController()

    private var currentMode: Mode = .login

    init() {
        super.init(nibName: nil, bundle: nil)
        setMode(currentMode, animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationController()
        setUpConstraints()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didLogOut(_:)),
            name: Networking.didLogOutNotification,
            object: nil
        )
    }

    private func setUpNavigationController() {
        addChild(profileNavigationController)
        view.addSubview(profileNavigationController.view)
        profileNavigationController.didMove(toParent: self)

        profileNavigationController.delegate = self
        profileNavigationController.navigationBar.prefersLargeTitles = true
        profileNavigationController.setNavigationBarHidden(true, animated: false)
    }

    private func setUpConstraints() {
        profileNavigationController.view.snp.makeConstraints { make in
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

        case .demo:
            viewController = DemoAccountModelController()
            (viewController as? DemoAccountModelController)?.delegate = self
        }

        var viewControllers = profileNavigationController.viewControllers
        if viewControllers.isEmpty {
            viewControllers.append(viewController)
        } else {
            viewControllers[0] = viewController
        }
        DispatchQueue.main.async {
            self.profileNavigationController.setViewControllers(viewControllers, animated: animated)
        }
    }

    @objc private func didLogOut(_ notification: Notification) {
        DispatchQueue.main.async {
            self.profileNavigationController.popToRootViewController(animated: true)
            self.setMode(.login, animated: false)
        }
    }

}

extension ProfileViewController: ProfileLoginModelControllerDelegate {

    func profileLoginModelController(_ viewController: ProfileLoginModelController, didLogin sessionId: String) {
        setMode(.account, animated: true)
    }

    func demoModeDidLogin(_ viewController: ProfileLoginModelController) {
        setMode(.demo, animated: true)
    }

}

extension ProfileViewController: DemoAccountViewControllerDelegate {

    func demoModeDidLogout() {
        self.profileNavigationController.popToRootViewController(animated: true)
        self.setMode(.login, animated: true)
    }

}

extension ProfileViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let hideNavigationBar = viewController is EateryViewController
        navigationController.setNavigationBarHidden(hideNavigationBar, animated: animated)
    }

}
