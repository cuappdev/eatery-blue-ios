//
//  RootModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/4/22.
//

import Combine
import UIKit

class RootModelController: RootViewController {

    static let didFinishOnboardingNotification = Notification.Name("RootModelController.didFinishOnboardingNotification")

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setMode(.splash)

        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.didOnboard) {
            transitionTo(.main)
        } else {
            transitionTo(.onboarding)
        }

        NotificationCenter
            .default
            .publisher(for: RootModelController.didFinishOnboardingNotification, object: nil)
            .sink { [self] notification in
                didFinishOnboarding(notification)
            }
            .store(in: &cancellables)
    }

    @objc private func didFinishOnboarding(_ notification: Notification) {
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.didOnboard)
        transitionTo(.main)
    }

}
