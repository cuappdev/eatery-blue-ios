//
//  UIFont+Extension.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import UIKit

extension UIFont {

    // Fix navigation bar fonts to ensure uniformity between custom navigation bars and UINavigationBars.
    static let eateryNavigationBarLargeTitleFont = UIFont.systemFont(ofSize: 34, weight: .bold)
    static let eateryNavigationBarTitleFont = UIFont.systemFont(ofSize: 20, weight: .semibold)

    static func preferredFont(for style: TextStyle, weight: Weight) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: style)
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        let font = UIFont.systemFont(ofSize: descriptor.pointSize, weight: weight)
        return metrics.scaledFont(for: font)
    }

}
