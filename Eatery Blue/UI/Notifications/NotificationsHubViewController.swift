//
//  NotificationsHubViewController.swift
//  Eatery Blue
//
//  Created by Angelina Chen on 3/11/26.
//

import Foundation
import UIKit

class NotificationsHubViewController: UIViewController, UITableViewDelegate {
    private let tableView = UITableView()

    private var favoriteItems: [ItemMetadata] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .Eatery.default00
        title = "Notifications"

        setUpTableView()
        loadFavorites()
    }

    private func setUpTableView() {
        tableView.register(NotificationItemCell.self,
                           forCellReuseIdentifier: NotificationItemCell.reuse)

        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func loadFavorites() {
        favoriteItems = AppDelegate.shared.coreDataStack.fetchFavoriteItems()
        tableView.reloadData()
    }
}

extension NotificationsHubViewController: UITableViewDataSource {
    func tableView(_: UITableView,
                   numberOfRowsInSection _: Int) -> Int {
        return favoriteItems.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationItemCell.reuse,
            for: indexPath
        ) as? NotificationItemCell else { return UITableViewCell() }

        cell.configure(item: favoriteItems[indexPath.row])

        cell.onArrowTap = { [weak self] in
            guard let self else { return }

            let favoritesVC = FavoritesViewController()
            self.navigationController?.pushViewController(favoritesVC, animated: true)
        }

        return cell
    }
}
