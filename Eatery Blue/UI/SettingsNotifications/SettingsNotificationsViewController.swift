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
        let hc = UIHostingController(rootView: SettingsNotificationsView())
        hc.view.backgroundColor = UIColor.Eatery.default00
        return hc
    }()

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.Eatery.default00
        setUpNavigationItem()
        setUpView()
        setUpConstraints()
        bindToggles()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        RootViewController.setStatusBarStyle(.darkContent)
        loadInitialState()
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
    }

    private func loadInitialState() {
        // If you later persist to UserDefaults, read them here.
    }

    // MARK: Actions — STUBS

    private func handlePauseAllChanged(_ isOn: Bool) {
        print("Pause all toggled: \(isOn)")
    }

    private func handleFavoriteItemsChanged(_ isOn: Bool) {
        print("Favorite Item Notifications: \(isOn)")
    }

    private func handleAppDevChanged(_ isOn: Bool) {
        print("Cornell AppDev Notifications: \(isOn)")
    }
}
