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
    
    // MARK: Properties (Data)
    var notifications: [Notification] = Notification.dummyData
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewRespectsSystemMinimumLayoutMargins = false
        view.backgroundColor = .white
        
        setUpTableView()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "Favorite Items"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .Eatery.black
        titleLabel.textAlignment = .left
        
        view.addSubview(titleLabel)
        
        notificationTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    private func setUpTableView() {
        notificationTableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: NotificationTableViewCell.reuse)
        notificationTableView.delegate = self
        notificationTableView.separatorStyle = .none
        notificationTableView.rowHeight = UITableView.automaticDimension
        notificationTableView.estimatedRowHeight = 92
        
        notificationTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(notificationTableView)
        
        notificationTableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom);
            make.bottom.equalToSuperview();
            make.leading.equalToSuperview();
            make.trailing.equalToSuperview()
        }
    }
}

extension NotificationViewController: UITableViewDelegate {}


