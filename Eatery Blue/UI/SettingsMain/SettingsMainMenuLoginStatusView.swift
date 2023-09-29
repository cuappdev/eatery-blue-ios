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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(label)
        setUpLabel()
        
        if let _ = KeychainAccess().retrieveToken() {
            addSubview(logoutButton)
            setUpLogoutButton()
        }
    }

    private func setUpLabel() {
        label.textColor = UIColor.Eatery.gray05
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
