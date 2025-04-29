//
//  NotificationsHubViewController.swift
//  Eatery Blue
//
//  Created by Cindy Liang on 2/22/25.
//

import Foundation
import UIKit

class NotificationsHubViewController: UIViewController{

    private let notifHubNavigationView = NotificationsHubNavigationView()
    private let notificationHubView = NotificationHubView()
    private let scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.viewRespectsSystemMinimumLayoutMargins = false
        
        setUpNotifHubNavigationView()
        view.addSubview(notifHubNavigationView)

        setUpNotifHubView()
        view.addSubview(notificationHubView)

        setupConstraints()
    }
    

    private func setUpNotifHubNavigationView() {
        notifHubNavigationView.navigationController = navigationController
    }
    private func setUpNotifHubView(){
        notificationHubView.navigationController = navigationController
    }

    func setupConstraints() {
        notifHubNavigationView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(150)
        }

        notificationHubView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.top.equalTo(notifHubNavigationView.snp.bottom)
        }
    
    }
  
}
