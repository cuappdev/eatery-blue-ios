//
//  RootViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import Combine
import UIKit

class RootViewController: UIViewController {

    enum Mode {
        case splash
        case onboarding
        case main
    }

    static let statusBarStyleNotification = Notification.Name("RootViewController.statusBarStyleNotification")

    private(set) var currentMode: Mode?
    private var currentViewController: UIViewController?
    private(set) lazy var splash = SplashViewController()
    private(set) lazy var onboarding = OnboardingViewController()
    private(set) lazy var main = MainViewController()

    private var thePreferredStatusBarStyle: UIStatusBarStyle = .lightContent
    override var preferredStatusBarStyle: UIStatusBarStyle {
        thePreferredStatusBarStyle
    }

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpStatusBarStyleNotifications()
    }

    func setMode(_ mode: Mode) {
        logger.info("\(#function): Set mode \(mode)")

        if let currentViewController = currentViewController {
            removeController(currentViewController)
        }

        currentMode = mode

        switch mode {
        case .onboarding:
            addToForeground(onboarding)
            currentViewController = onboarding

        case .splash:
            addToForeground(splash)
            currentViewController = splash

        case .main:
            addToForeground(main)
            currentViewController = main
        }
    }

    func transitionTo(_ mode: Mode) {
        let previousMode = currentMode
        currentMode = mode

        logger.info("\(#function): Transition from \(previousMode.map({ "\($0)" }) ?? "nil") to \(mode)")

        switch (previousMode, mode) {
        case (nil, .splash):
            addToForeground(splash)
            currentViewController = splash

        case (nil, .onboarding):
            addToForeground(onboarding)
            currentViewController = onboarding

        case (nil, .main):
            addToForeground(main)
            currentViewController = main

        case (.splash, .onboarding):
            removeController(splash)
            addToForeground(onboarding)
            currentViewController = onboarding

        case (.splash, .main):
            removeController(splash)
            addToForeground(main)
            currentViewController = main

        case (.onboarding, .main):
            removeController(onboarding)
            addToForeground(main)
            currentViewController = main

        default:
            break
        }
    }

    private func addToForeground(_ controller: UIViewController) {
        addChild(controller)
        view.addSubview(controller.view)
        controller.didMove(toParent: self)


    }

    private func addToBackground(_ controller: UIViewController) {
        addChild(controller)
        view.insertSubview(controller.view, at: 0)
        controller.didMove(toParent: self)

        controller.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func removeController(_ controller: UIViewController) {
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
    }

    static func setStatusBarStyle(_ statusBarStyle: UIStatusBarStyle) {
        NotificationCenter.default.post(
            name: RootViewController.statusBarStyleNotification,
            object: nil,
            userInfo: ["statusBarStyle": statusBarStyle]
        )
    }

    private func setUpStatusBarStyleNotifications() {
        NotificationCenter.default
            .publisher(for: RootViewController.statusBarStyleNotification)
            .sink { [self] notification in
                guard let style = notification.userInfo?["statusBarStyle"] as? UIStatusBarStyle else { return }

                thePreferredStatusBarStyle = style
                setNeedsStatusBarAppearanceUpdate()
            }
            .store(in: &cancellables)
    }

}
