//
//  ProfileViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/7/22.
//

import UIKit

class ProfileViewController: UIViewController {

    private var profileNavigationController = UINavigationController()

    init() {
        super.init(nibName: nil, bundle: nil)
        setMode(animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationController()
        setUpConstraints()
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

    func setMode(animated: Bool) {
        let viewController = AccountModelController()

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

}

extension ProfileViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let hideNavigationBar = viewController is EateryViewController
        navigationController.setNavigationBarHidden(hideNavigationBar, animated: animated)
    }

}
