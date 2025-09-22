//
//  OnboardingViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/3/22.
//

import UIKit

class OnboardingViewController: UIViewController {
    private let theNavigationController = UINavigationController()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpNavigationController()

        RootViewController.setStatusBarStyle(.darkContent)
    }

    private func setUpView() {
        addChild(theNavigationController)
        view.addSubview(theNavigationController.view)
        theNavigationController.didMove(toParent: self)

        theNavigationController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setUpNavigationController() {
        theNavigationController.viewControllers = [OnboardingStartViewController()]
        theNavigationController.setNavigationBarHidden(true, animated: false)
    }
}
