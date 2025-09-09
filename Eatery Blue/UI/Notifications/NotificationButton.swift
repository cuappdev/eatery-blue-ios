//
//  NotificationButton.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 9/7/24.
//

import UIKit

class NotificationButton: ButtonView<UIView> {

    // MARK: - Properties (view)

    private let notificationBellImageView = UIImageView()
    private let notificationDotImageView = UIImageView()

    // MARK: - Properties (data)

    private var completion: ((UIViewController) -> Void)?
//    private var notifictions: [EateryNotification]

    // MARK: - Init

    init() {
        super.init(content: UIView())

        setUpSelf()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Set Up

    private func setUpSelf() {
        content.addSubview(notificationBellImageView)
        setUpNotificationBellImageView()

        content.addSubview(notificationDotImageView)
        setUpNotificationDotImageView()

        setUpConstraints()

        self.buttonPress { [weak self] _ in
            guard let self else { return }
            
            var loggedIn = false
            if let sessionId = KeychainAccess.shared.retrieveToken() {
                loggedIn = true
            }

            let plvc = ProfileLoginModelController(canGoBack: true)
//            let vc = NotificationViewController(loggedIn: loggedIn)
            completion?(loggedIn ? UIViewController(): plvc)
            
//            let notifHubViewController = NotificationHubViewController
//
//            navigationController?.pushViewController(notifHubViewController, animated: true)
        }

        checkforNotifications()
    }

    func checkforNotifications() {
        guard let sessionId = KeychainAccess.shared.retrieveToken() else { return }

        // make networking call to see if there are any notis

        // if we have notis that are unread, we want to show the red dot
        notificationDotImageView.isHidden = false

    }

    func onTap(_ completion: @escaping (UIViewController) -> Void) {
        self.completion = completion
    }

    private func setUpNotificationBellImageView() {
        notificationBellImageView.image = UIImage(named: "Bell")
    }

    private func setUpNotificationDotImageView() {
        notificationDotImageView.image = UIImage(named: "NotificationDot")
        notificationDotImageView.isHidden = true
    }

    private func setUpConstraints() {
        content.snp.makeConstraints { make in
            make.size.equalTo(32)
        }

        notificationBellImageView.snp.makeConstraints { make in
            make.width.equalTo(22)
            make.height.equalTo(23)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(2)
        }

        notificationDotImageView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.size.equalTo(11)
        }
    }

}
