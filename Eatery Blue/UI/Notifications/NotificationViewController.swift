//
//  NotificationViewController.swift
//  Eatery Blue
//
//  Created by Adelynn Wu on 11/9/25.
//

import EateryModel
import Foundation
import UIKit

class NotificationViewController: UIViewController {
    // MARK: - Testing

    private let useMockNotifications = true

    private static let mockNotifications: [HubNotification] = [
        HubNotification(
            id: 1,
            title: "Chicken Nuggets",
            body: "Chicken Nuggets is being served at Keeton House, Okenshields, and Morrison Dining.",
            isRead: false,
            createdAt: Date()
        ),
        HubNotification(
            id: 2,
            title: "Orange Chicken",
            body: "Orange Chicken is being served at Becker House and Okenshields.",
            isRead: true,
            createdAt: Date().addingTimeInterval(-3600)
        ),
        HubNotification(
            id: 3,
            title: "Scrambled Eggs",
            body: "Scrambled Eggs is being served at Rose House.",
            isRead: false,
            createdAt: Date().addingTimeInterval(-7200)
        )
    ]

    // MARK: Properties (View)

    private let notificationTableView = UITableView()
    private let titleLabel = UILabel()
    private let notificationNavigationView = NotificationNavigationView()
    private let loadingView = UIActivityIndicatorView(style: .large)
    private let emptyView = UIView()
    private let errorView = UIView()

    private enum ViewState {
        case loading
        case loaded([HubNotification])
        case empty
        case error
    }

    // MARK: Properties (Data)

    var notifications: [HubNotification] = []
    private var state: ViewState = .loading {
        didSet { render() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewRespectsSystemMinimumLayoutMargins = false
        view.backgroundColor = .white

        setupNavigationView()
        setupTitleLabel()
        setupTableView()
        setupLoadingView()
        setupEmptyView()
        setupErrorView()
        Task { await loadNotifications() }
    }

    private func setupTitleLabel() {
        titleLabel.text = "Favorite Items"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .Eatery.black
        titleLabel.textAlignment = .left

        view.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(notificationNavigationView.snp.bottom).offset(26)
            make.leading.equalToSuperview().offset(23)
            make.trailing.equalToSuperview().offset(-23)
        }
    }

    private func setupTableView() {
        notificationTableView.register(
            NotificationTableViewCell.self,
            forCellReuseIdentifier: NotificationTableViewCell.reuse
        )
        notificationTableView.delegate = self
        notificationTableView.dataSource = self
        notificationTableView.separatorStyle = .none
        notificationTableView.rowHeight = UITableView.automaticDimension

        notificationTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(notificationTableView)

        notificationTableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func setupNavigationView() {
        notificationNavigationView.navigationController = navigationController

        view.addSubview(notificationNavigationView)

        notificationNavigationView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(140)
        }
    }

    private func setupLoadingView() {
        loadingView.hidesWhenStopped = true
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(notificationTableView)
        }
    }

    private func setupEmptyView() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12

        let imageView = UIImageView(image: UIImage(named: "Notifications Bell"))
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(54)
        }

        let titleLabel = UILabel()
        titleLabel.text = "Nothing here...yet!"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        let messageLabel = UILabel()
        messageLabel.text = "When your favorite menu items are being\n served in a dining hall, it will show up here."
        messageLabel.font = .systemFont(ofSize: 12, weight: .regular)
        messageLabel.textColor = .Eatery.gray05
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        stack.addArrangedSubview(imageView)
        stack.setCustomSpacing(12, after: imageView)
        stack.addArrangedSubview(titleLabel)
        stack.setCustomSpacing(4, after: titleLabel)
        stack.addArrangedSubview(messageLabel)

        emptyView.addSubview(stack)
        emptyView.isHidden = true
        view.addSubview(emptyView)

        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().inset(41)
            make.trailing.lessThanOrEqualToSuperview().inset(41)
        }

        emptyView.snp.makeConstraints { make in
            make.center.equalTo(notificationTableView)
        }
    }

    ///    private func buildErrorStateView() -> UIView {
    ///        let container = UIView()
    ///
    ///        let stack = UIStackView()
    ///        stack.axis = .vertical
    ///        stack.alignment = .center
    ///        stack.spacing = 12
    ///
    ///        let imageView = UIImageView(image: UIImage(systemName: "xmark.octagon"))
    ///        imageView.tintColor = UIColor.Eatery.red
    ///        imageView.contentMode = .scaleAspectFit
    ///        imageView.snp.makeConstraints { make in
    ///            make.width.height.equalTo(41)
    ///        }
    ///
    ///        let titleLabel = UILabel()
    ///        titleLabel.text = "Hmm, no chow here (yet)."
    ///        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    ///        titleLabel.textAlignment = .center
    ///        titleLabel.numberOfLines = 0
    ///
    ///        let messageLabel = UILabel()
    ///        messageLabel.text = "We ran into an issue loading this page. Check your connection or try again later"
    ///        messageLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
    ///        messageLabel.textColor = UIColor.Eatery.gray05
    ///        messageLabel.textAlignment = .center
    ///        messageLabel.numberOfLines = 0
    ///
    ///        stack.addArrangedSubview(imageView)
    ///        stack.setCustomSpacing(12, after: imageView)
    ///        stack.addArrangedSubview(titleLabel)
    ///        stack.setCustomSpacing(4, after: titleLabel)
    ///        stack.addArrangedSubview(messageLabel)
    ///
    ///        container.addSubview(stack)
    ///        stack.snp.makeConstraints { make in
    ///            make.centerX.equalToSuperview()
    ///            make.centerY.equalToSuperview().offset(-29)
    ///            make.leading.greaterThanOrEqualToSuperview().inset(41)
    ///            make.trailing.lessThanOrEqualToSuperview().inset(41)
    ///        }
    ///
    ///        return container
    ///    }
    private func setupErrorView() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12

        let imageView = UIImageView(image: UIImage(systemName: "xmark.octagon"))
        imageView.tintColor = .Eatery.red
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(41)
        }

        let titleLabel = UILabel()
        titleLabel.text = "Hmm, no chow here (yet)."
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        let messageLabel = UILabel()
        messageLabel.text = "We ran into an issue loading this page.\nCheck your connection or try again later"
        messageLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        messageLabel.textColor = UIColor.Eatery.gray05
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        let retryButton = UIButton(type: .system)
        retryButton.setTitle("Refresh", for: .normal)
        retryButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)

        stack.addArrangedSubview(imageView)
        stack.setCustomSpacing(12, after: imageView)
        stack.addArrangedSubview(titleLabel)
        stack.setCustomSpacing(4, after: titleLabel)
        stack.addArrangedSubview(messageLabel)
//        stack.setCustomSpacing(16, after: messageLabel)
//        stack.addArrangedSubview(retryButton)

        errorView.addSubview(stack)
        errorView.isHidden = true
        view.addSubview(errorView)

        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().inset(41)
            make.trailing.lessThanOrEqualToSuperview().inset(41)
        }

        errorView.snp.makeConstraints { make in
            make.center.equalTo(notificationTableView)
        }
    }

    @objc private func didTapRetry() {
        Task { await loadNotifications() }
    }

    private func loadNotifications() async {
        state = .loading

        // testing
        if useMockNotifications {
            state = Self.mockNotifications.isEmpty ? .empty : .loaded(Self.mockNotifications)
            return
        }

        do {
            let notifications = try await Networking.default.fetchNotifications()
            state = notifications.isEmpty ? .empty : .loaded(notifications)
        } catch {
            print("Failed to fetch notifications here: ", error) // debug
            state = .error
        }
    }

    private func render() {
        switch state {
        case .loading:
            notificationTableView.isHidden = true
            emptyView.isHidden = true
            errorView.isHidden = true
            titleLabel.isHidden = false
            loadingView.startAnimating()
        case let .loaded(notifications):
            self.notifications = notifications
            notificationTableView.reloadData()
            loadingView.isHidden = true
            emptyView.isHidden = true
            errorView.isHidden = true
            titleLabel.isHidden = false
            notificationTableView.isHidden = false
        case .empty:
            loadingView.isHidden = true
            notificationTableView.isHidden = true
            emptyView.isHidden = false
            errorView.isHidden = true
            titleLabel.isHidden = true
        case .error:
            loadingView.isHidden = true
            notificationTableView.isHidden = true
            emptyView.isHidden = true
            titleLabel.isHidden = true
            errorView.isHidden = false
        }
    }
}

extension NotificationViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension NotificationViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return notifications.count
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = notificationTableView.dequeueReusableCell(
            withIdentifier: NotificationTableViewCell.reuse,
            for: indexPath
        ) as? NotificationTableViewCell else {
            return UITableViewCell()
        }

        cell.configure(notification: notifications[indexPath.row])
        return cell
    }
}
