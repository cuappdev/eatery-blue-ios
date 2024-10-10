//
//  NotificationButton.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 9/7/24.
//

import UIKit

class NotificationButton: ButtonView<UIView> {

    // MARK: - Properties (View)

    private let notificationBellImageView = UIImageView()
    private let notificationDotImageView = UIImageView()

    // MARK: - Properties (Data)

    private var loggedIn = false
    private var completion: ((UIViewController) -> Void)?

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
        checkLogin()

        self.tap { [weak self] _ in

            self?.completion(UIViewController())
        }
    }

    private func checkLogin() {
        if let sessionId = KeychainAccess.shared.retrieveToken() {
            loggedIn = true
        }
    }

    func onTap(_ completion: (UIViewController) -> Void) {
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
