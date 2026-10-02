//
//  SettingsPrivacyViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/24/22.
//

import Combine
import Foundation
import SwiftUI
import UserNotifications

class SettingsPrivacyViewController: UIViewController {
    private lazy var hostingController: UIHostingController<SettingsPrivacyView> = {
        let rootView = SettingsPrivacyView(
            onOpenSystemSettings: { [weak self] in
                self?.openSystemSettings()
            },
            onOpenNotificationSettings: { [weak self] in
                self?.openNotificationSettings()
            }
        )
        return UIHostingController(rootView: rootView)
    }()

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationItem()
        setUpView()
        setUpConstraints()
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.updateView()
            }
            .store(in: &cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        RootViewController.setStatusBarStyle(.darkContent)

        updateView()
    }

    private func setUpNavigationItem() {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.Eatery.primaryText as Any,
            .font: UIFont.eateryNavigationBarTitleFont
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.Eatery.blue as Any,
            .font: UIFont.eateryNavigationBarLargeTitleFont
        ]

        navigationItem.title = "Privacy"

        let standardAppearance = appearance.copy()
        standardAppearance.configureWithDefaultBackground()
        navigationItem.standardAppearance = standardAppearance

        let scrollEdgeAppearance = appearance.copy()
        scrollEdgeAppearance.configureWithTransparentBackground()
        navigationItem.scrollEdgeAppearance = scrollEdgeAppearance

        let backButton = UIBarButtonItem(
            image: UIImage(named: "ArrowLeft"),
            style: .plain,
            target: self,
            action: #selector(didTapBackButton)
        )
        backButton.tintColor = UIColor.Eatery.primaryText
        navigationItem.leftBarButtonItem = backButton
    }

    private func setUpView() {
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        hostingController.rootView.viewModel.$isAnalyticsEnabled
            .dropFirst() // Drop the first element that comes from the initial value
            .sink { isAnalyticsEnabled in
                UserDefaults.standard.set(isAnalyticsEnabled, forKey: UserDefaultsKeys.isAnalyticsEnabled)
            }
            .store(in: &cancellables)
    }

    private func setUpConstraints() {
        hostingController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }

    private func updateView() {
        let isLocationAllowed: Bool
        switch LocationManager.shared.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isLocationAllowed = true
        default:
            isLocationAllowed = false
        }

        hostingController.rootView.viewModel.isLocationAllowed = isLocationAllowed

        let isAnalyticsEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isAnalyticsEnabled)
        hostingController.rootView.viewModel.isAnalyticsEnabled = isAnalyticsEnabled

        Task { @MainActor [weak self] in
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            self?.hostingController.rootView.viewModel.isNotificationAllowed =
                settings.authorizationStatus == .authorized
                    || settings.authorizationStatus == .provisional
                    || settings.authorizationStatus == .ephemeral
        }
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func openNotificationSettings() {
        navigationController?.pushViewController(
            SettingsNotificationsViewController(),
            animated: true
        )
    }
}
