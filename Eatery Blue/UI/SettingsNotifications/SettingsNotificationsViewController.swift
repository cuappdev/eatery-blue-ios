//
//  SettingsNotificationsViewController.swift
//  Eatery Blue
//
//  Created by Arielle Nudelman on 10/11/25.
//

import Combine
import SwiftUI
import UserNotifications

final class SettingsNotificationsViewController: UIViewController {
    private lazy var hostingController: UIHostingController<SettingsNotificationsView> = {
        let rootView = SettingsNotificationsView(onOpenSystemSettings: { [weak self] in
            self?.openSystemSettings()
        })
        let hc = UIHostingController(rootView: rootView)
        hc.view.backgroundColor = UIColor.Eatery.default00
        return hc
    }()

    private var cancellables: Set<AnyCancellable> = []
    private var isApplyingServerState = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.Eatery.default00
        setUpNavigationItem()
        setUpView()
        setUpConstraints()
        bindToggles()
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.refreshSettings()
            }
            .store(in: &cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        RootViewController.setStatusBarStyle(.darkContent)
        refreshSettings()
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

        navigationItem.title = "Notifications"
        navigationItem.largeTitleDisplayMode = .always

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

    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: UI

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

    // MARK: Bindings

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
    }

    private func refreshSettings() {
        Task { @MainActor in
            await refreshSystemPermission()
            await loadSettingsFromServer()
        }
    }

    private func loadSettingsFromServer() async {
        do {
            let settings = try await Networking.default.fetchUserNotificationSettings()
            apply(settings)
        } catch {
            logger.error("Failed to load notification settings: \(error)")
        }
    }

    private func apply(_ settings: UserNotificationSettings) {
        isApplyingServerState = true
        viewModel.favoriteItems = settings.favoriteItemPushNotifications
        viewModel.appDev = settings.cornellAppdevPushNotifications
        viewModel.pauseAll = !settings.favoriteItemPushNotifications
            && !settings.cornellAppdevPushNotifications
        isApplyingServerState = false
    }

    private func refreshSystemPermission() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        viewModel.systemNotificationsDenied = settings.authorizationStatus == .denied
    }

    private func ensureNotificationPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            viewModel.systemNotificationsDenied = false
            return true
        case .denied:
            viewModel.systemNotificationsDenied = true
            return false
        case .notDetermined:
            let granted = await withCheckedContinuation { continuation in
                center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                    continuation.resume(returning: granted)
                }
            }
            viewModel.systemNotificationsDenied = !granted
            return granted
        @unknown default:
            viewModel.systemNotificationsDenied = true
            return false
        }
    }

    private func handlePauseAllChanged(_ isOn: Bool) {
        guard !isApplyingServerState else { return }

        let previousFavorite = viewModel.favoriteItems
        let previousAppDev = viewModel.appDev
        Task { @MainActor in
            if !isOn {
                let allowed = await self.ensureNotificationPermission()
                if !allowed {
                    self.restorePause(true, favorite: previousFavorite, appDev: previousAppDev)
                    return
                }
            }

            do {
                let enabled = !isOn
                let settings = try await Networking.default.updateUserNotificationSettings(
                    favoriteItemPushNotifications: enabled,
                    cornellAppdevPushNotifications: enabled
                )
                self.apply(settings)
            } catch {
                self.restorePause(!isOn, favorite: previousFavorite, appDev: previousAppDev)
                logger.error("Failed to update pause setting: \(error)")
            }
        }
    }

    private func handleFavoriteItemsChanged(_ isOn: Bool) {
        guard !isApplyingServerState, !viewModel.pauseAll else { return }
        Task { @MainActor in
            if isOn {
                let allowed = await self.ensureNotificationPermission()
                if !allowed {
                    self.setFavoriteItems(false)
                    return
                }
            }
            await self.updateFavoriteItems(isOn)
        }
    }

    private func handleAppDevChanged(_ isOn: Bool) {
        guard !isApplyingServerState, !viewModel.pauseAll else { return }
        Task { @MainActor in
            if isOn {
                let allowed = await self.ensureNotificationPermission()
                if !allowed {
                    self.setAppDev(false)
                    return
                }
            }
            await self.updateAppDev(isOn)
        }
    }

    private func updateFavoriteItems(_ isOn: Bool) async {
        do {
            let settings = try await Networking.default.updateUserNotificationSettings(
                favoriteItemPushNotifications: isOn
            )
            apply(settings)
        } catch {
            setFavoriteItems(!isOn)
            logger.error("Failed to update favorite item notifications: \(error)")
        }
    }

    private func updateAppDev(_ isOn: Bool) async {
        do {
            let settings = try await Networking.default.updateUserNotificationSettings(
                cornellAppdevPushNotifications: isOn
            )
            apply(settings)
        } catch {
            setAppDev(!isOn)
            logger.error("Failed to update AppDev notifications: \(error)")
        }
    }

    private func setFavoriteItems(_ isOn: Bool) {
        isApplyingServerState = true
        viewModel.favoriteItems = isOn
        isApplyingServerState = false
    }

    private func setAppDev(_ isOn: Bool) {
        isApplyingServerState = true
        viewModel.appDev = isOn
        isApplyingServerState = false
    }

    private func restorePause(_ isOn: Bool, favorite: Bool, appDev: Bool) {
        isApplyingServerState = true
        viewModel.pauseAll = isOn
        viewModel.favoriteItems = favorite
        viewModel.appDev = appDev
        isApplyingServerState = false
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private var viewModel: SettingsNotificationsViewModel {
        hostingController.rootView.viewModel
    }
}
