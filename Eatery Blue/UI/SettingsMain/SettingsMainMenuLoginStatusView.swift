//
//  SettingsMainMenuLoginStatusView.swift
//  Eatery Blue
//
//  Created by William Ma on 1/11/22.
//

import UIKit

class SettingsMainMenuLoginStatusView: UIView {
    let label = UILabel()
    let logoutButton = SettingsLogoutPillButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(label)
        setUpLabel()

        if KeychainAccess.shared.retrieveToken() != nil {
            addSubview(logoutButton)
            setUpLogoutButton()
        }
    }

    private func setUpLabel() {
        label.textColor = UIColor.Eatery.secondaryText
        label.font = .preferredFont(for: .body, weight: .semibold)
        label.snp.makeConstraints { make in
            make.centerY.leading.equalTo(layoutMarginsGuide)
        }
    }

    private func setUpLogoutButton() {
        logoutButton.snp.makeConstraints { make in
            make.leading.equalTo(label.snp.trailing)
            make.top.trailing.bottom.equalTo(layoutMarginsGuide)
        }
    }
}
