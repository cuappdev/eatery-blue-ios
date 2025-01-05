//
//  SettingsMainMenuModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/11/22.
//

import UIKit
import GoogleSignIn

class SettingsMainMenuModelController: SettingsMainMenuViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpSettingsItems()
    }

    private func setUpSettingsItems() {
        clearStackView()

        addSettingsItem(SettingsItem(
            image: UIImage(named: "AppDevLogo"),
            title: "About Eatery",
            subtitle: "Learn more about Cornell AppDev",
            action: { [weak self] in
                guard let self else { return }

                let viewController = SettingsAboutModelController()
                navigationController?.pushViewController(viewController, animated: true)
            }
        ))
        addSeparator()
        addSettingsItem(SettingsItem(
            image: UIImage(named: "FavoriteUnselected"),
            title: "Favorites",
            subtitle: "Manage your favorite eateries",
            action: { [weak self] in
                guard let self else { return }

                let viewController = FavoritesViewController()
                navigationController?.pushViewController(viewController, animated: true)
            }
        ))
        addSeparator()
        addSettingsItem(SettingsItem(
            image: UIImage(named: "Eatery")?.withRenderingMode(.alwaysTemplate).withTintColor(UIColor.Eatery.gray05),
            title: "App Icon",
            subtitle: "Select the Eatery app icon for your phone",
            action: { [weak self] in
                guard let self else { return }

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
            action: { [weak self] in
                guard let self else { return }

                let viewController = SettingsPrivacyViewController()
                navigationController?.pushViewController(viewController, animated: true)
            }
        ))
        addSeparator()
        addSettingsItem(SettingsItem(
            image: UIImage(named: "Help"),
            title: "Support",
            subtitle: "Report issues and contact Cornell AppDev",
            action: { [weak self] in
                guard let self else { return }

                let viewController = SettingsSupportViewController()
                navigationController?.pushViewController(viewController, animated: true)
            }
        ))
        addSeparator()
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            guard let self else { return }

            if error != nil || user == nil {
                addSettingsItem(SettingsItem(
                    image: UIImage(named: "User"),
                    title: "Sign In",
                    subtitle: "Sync favorites and use AI features",
                    action: { [weak self] in
                        guard let self else { return }

                        let viewController = SettingsLoginSheetViewController()
                        viewController.setUpSheetPresentation()
                        viewController.onSuccess { [weak self] vc in
                            guard let self else { return }

                            vc.dismiss(animated: true)
                            setUpSettingsItems()
                        }
                        tabBarController?.present(viewController, animated: true)
                    }
                ))
            } else {
                addSettingsItem(SettingsItem(
                    image: UIImage(named: "User"),
                    title: user?.profile?.givenName ?? "User",
                    subtitle: "Click to log out",
                    action: { [weak self] in
                        guard let self else { return }

                        GIDSignIn.sharedInstance.signOut()
                        setUpSettingsItems()
                    }
                ))
            }

            setCustomSpacing(24)

            }

    }

}
