//
//  SettingsMainMenuModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/11/22.
//

import UIKit

class SettingsMainMenuModelController: SettingsMainMenuViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        addSettingsItem(SettingsItem(
            image: UIImage(named: "AppDevLogo"),
            title: "About Eatery",
            subtitle: "Learn more about Cornell AppDev",
            action: {
            }
        ))
        addSeparator()
        addSettingsItem(SettingsItem(
            image: UIImage(named: "FavoriteUnselected"),
            title: "Favorites",
            subtitle: "Manage your favorite eateries",
            action: {
            }
        ))
        addSeparator()
        addSettingsItem(SettingsItem(
            image: UIImage(named: "Lock"),
            title: "Privacy",
            subtitle: "Manage permissions and analytics",
            action: {
            }
        ))
        addSeparator()
        addSettingsItem(SettingsItem(
            image: UIImage(named: "Gavel"),
            title: "Legal",
            subtitle: "Find terms, conditions, and privacy policy",
            action: {
            }
        ))
        addSeparator()
        addSettingsItem(SettingsItem(
            image: UIImage(named: "Help"),
            title: "Support",
            subtitle: "Report issues and contact Cornell AppDev",
            action: {
            }
        ))
        setCustomSpacing(24)
        if let credentials = try? KeychainManager.shared.get() {
            addLoginStatusView(credentials.netId, logOut: {

            })
        }
    }

}