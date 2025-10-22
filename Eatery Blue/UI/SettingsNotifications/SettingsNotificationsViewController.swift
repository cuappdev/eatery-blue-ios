//
//  SettingsNotificationsViewController.swift
//  Eatery Blue
//
//  Created by Arielle Nudelman on 10/11/25.
//

import Combine
import SwiftUI

final class SettingsNotificationsViewController: UIViewController {
    private lazy var hostingController: UIHostingController<SettingsNotificationsView> = {
        let view = SettingsNotificationsView(onTapPrivacy: { [weak self] in
            self?.pushPrivacy()
        })
        let hc = UIHostingController(rootView: view)
        return hc
    }()

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigation()
        setUpView()
        setUpConstraints()
        bindToggles()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        RootViewController.setStatusBarStyle(.darkContent)
        loadInitialState()
    }

    // MARK: UI

    private func setUpNavigation() {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.Eatery.black as Any,
            .font: UIFont.eateryNavigationBarTitleFont
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.Eatery.blue as Any,
            .font: UIFont.eateryNavigationBarLargeTitleFont
        ]
        navigationItem.title = "Notifications"

        let standard = appearance.copy(); standard.configureWithDefaultBackground()
        navigationItem.standardAppearance = standard

        let scrollEdge = appearance.copy(); scrollEdge.configureWithTransparentBackground()
        navigationItem.scrollEdgeAppearance = scrollEdge

        let back = UIBarButtonItem(
            image: UIImage(named: "ArrowLeft"),
            style: .plain,
            target: self,
            action: #selector(didTapBack)
        )
        back.tintColor = UIColor.Eatery.black
        navigationItem.leftBarButtonItem = back
    }

    private func setUpView() {
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }

    private func setUpConstraints() {
        hostingController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: Bindings (stubs only)

    private func bindToggles() {
        let vm = hostingController.rootView.viewModel

        vm.$pauseAll
            .dropFirst()
            .sink { [weak self] isOn in
                self?.handlePauseAllChanged(isOn)
            }
            .store(in: &cancellables)

        vm.$favoriteItems
            .dropFirst()
            .sink { [weak self] isOn in
                self?.handleFavoriteItemsChanged(isOn)
            }
            .store(in: &cancellables)

        vm.$appDev
            .dropFirst()
            .sink { [weak self] isOn in
                self?.handleAppDevChanged(isOn)
            }
            .store(in: &cancellables)

        vm.$dining
            .dropFirst()
            .sink { [weak self] isOn in
                self?.handleDiningChanged(isOn)
            }
            .store(in: &cancellables)

        vm.$account
            .dropFirst()
            .sink { [weak self] isOn in
                self?.handleAccountChanged(isOn)
            }
            .store(in: &cancellables)
    }

    // MARK: Load initial values (optional defaults for now)

    private func loadInitialState() {
        // If you later persist to UserDefaults, read them here.
        // For now we just use the defaults from the ViewModel.
    }

    // MARK: Actions — STUBS

    private func handlePauseAllChanged(_ isOn: Bool) {
        // Implement a global notifications pause/disable.
        // e.g., NotificationManager.shared.setPaused(isOn)
        print("Pause all toggled: \(isOn)")
    }

    private func handleFavoriteItemsChanged(_ isOn: Bool) {
        // Subscribe/unsubscribe from favorite-item topics.
        print("Favorite Item Notifications: \(isOn)")
    }

    private func handleAppDevChanged(_ isOn: Bool) {
        // Subscribe/unsubscribe from AppDev topics.
        print("Cornell AppDev Notifications: \(isOn)")
    }

    private func handleDiningChanged(_ isOn: Bool) {
        // Subscribe/unsubscribe from Dining topics.
        print("Cornell Dining Notifications: \(isOn)")
    }

    private func handleAccountChanged(_ isOn: Bool) {
        // Subscribe/unsubscribe from account/security topics.
        print("Account Notifications: \(isOn)")
    }

    // MARK: Navigation

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    private func pushPrivacy() {
        navigationController?.pushViewController(SettingsPrivacyViewController(), animated: true)
    }
}
