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
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(label)
        setUpLabel()

        addSubview(logoutButton)
    }

    private func setUpLabel() {
        label.textColor = UIColor(named: "Gray05")
        label.font = .preferredFont(for: .body, weight: .semibold)
    }

    private func setUpConstraints() {
        label.centerY(to: layoutMarginsGuide)
        label.leading(to: layoutMarginsGuide)
        label.trailingToLeading(of: logoutButton)

        logoutButton.top(to: layoutMarginsGuide)
        logoutButton.trailing(to: layoutMarginsGuide)
        logoutButton.bottom(to: layoutMarginsGuide)
    }

}
