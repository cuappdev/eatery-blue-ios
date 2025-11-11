//
//  NotificationViewController.swift
//  Eatery Blue
//
//  Created by Adelynn Wu on 11/9/25.
//

import Foundation
import UIKit

class NotificationViewController: UIViewController {
    
    // MARK: Properties (View)
    private let notificationTableView = UITableView()
    private let titleLabel = UILabel()
    private let notificationNavigationView = NotificationNavigationView()
    
    // MARK: Properties (Data)
    var notifications: [NotificationData] = NotificationData.dummyData
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewRespectsSystemMinimumLayoutMargins = false
        view.backgroundColor = .white
        
        setupNavigationView()
        setupTitleLabel()
        setupTableView()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "Favorite Items"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .Eatery.black
        titleLabel.textAlignment = .left
        
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(notificationNavigationView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(23)
            make.trailing.equalToSuperview().offset(-23)
        }
    }
    
    private func setupTableView() {
        notificationTableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: NotificationTableViewCell.reuse)
        notificationTableView.delegate = self
        notificationTableView.dataSource = self
        notificationTableView.separatorStyle = .none
        notificationTableView.rowHeight = UITableView.automaticDimension
        
        notificationTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(notificationTableView)
        
        notificationTableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
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
}

extension NotificationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 92
    }
}

extension NotificationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = notificationTableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.reuse, for: indexPath) as? NotificationTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(notification: notifications[indexPath.row])
        return cell
    }
    
    
}


