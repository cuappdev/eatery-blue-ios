//
//  UIViewController+Extension.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 2/24/25.
//

import UIKit

extension UIViewController {
    static let notificationName = NSNotification.Name("favoriteEatery")
    static let notificationUserInfoKey = "addedToFavorites"

    func addFavoriteObservation(current: inout NSObjectProtocol?, _ closure: @escaping (Bool?) -> Void) {
        if let current { NotificationCenter.default.removeObserver(current) }

        current = NotificationCenter.default.addObserver(
            forName: UIViewController.notificationName,
            object: nil,
            queue: .main
        ) { res in
            closure(res.userInfo?[UIViewController.notificationUserInfoKey] as? Bool)
        }
    }

    func removeObserver(current: NSObjectProtocol?) {
        if let current { NotificationCenter.default.removeObserver(current) }
    }
}
