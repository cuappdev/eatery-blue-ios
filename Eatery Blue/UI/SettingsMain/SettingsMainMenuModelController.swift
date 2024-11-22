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
            action: { [self] in
                let viewController = SettingsAboutModelController()
                navigationController?.pushViewController(viewController, animated: true)
            }
        ))
        addSeparator()
        addSettingsItem(SettingsItem(
            image: UIImage(named: "FavoriteUnselected"),
            title: "Favorites",
            subtitle: "Manage your favorite eateries",
            action: { [self] in
                let viewController = SettingsFavoritesViewController()
                navigationController?.navigationBar.isHidden = true
                navigationController?.pushViewController(viewController, animated: true)
            }
        ))
        addSeparator()
        addSettingsItem(SettingsItem(
            image: UIImage(named: "Eatery")?.withRenderingMode(.alwaysTemplate).withTintColor(UIColor.Eatery.gray05),
            title: "App Icon",
            subtitle: "Select the Eatery app icon for your phone",
            action: { [self] in
                let viewController = SettingsAppIconSheetViewController()
                viewController.setUpSheetPresentation()
                tabBarController?.present(viewController, animated: true)
            }
        ))
        addSeparator()
        addSettingsItem(SettingsItem(
            image: UIImage(named: "Lock"),
            title: "Privacy",
            subtitle: "Manage permissions and analytics",
            action: { [self] in
                let viewController = SettingsPrivacyViewController()
                navigationController?.pushViewController(viewController, animated: true) 
            }
        ))
        addSeparator()
        addSettingsItem(SettingsItem(
            image: UIImage(named: "Help"),
            title: "Support",
            subtitle: "Report issues and contact Cornell AppDev",
            action: { [self] in
                let viewController = SettingsSupportViewController()
                navigationController?.pushViewController(viewController, animated: true)
            }
        ))
        setCustomSpacing(24)

        var didAttemptLogOut = false

        addLoginStatusView(logOut: {
            if !didAttemptLogOut {
                Networking.default.logOut()
                didAttemptLogOut = true
            }
        })
    }
}
