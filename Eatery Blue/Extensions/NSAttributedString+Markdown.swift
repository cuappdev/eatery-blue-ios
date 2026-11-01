//
//  NSAttributedString+Markdown.swift
//  Eatery Blue
//
//  Created by Amy Yang on 10/31/26.
//

import UIKit

extension NSAttributedString {
    /// Splits on `**` and bolds the text between pairs of markers.
    static func fromMarkdown(
        _ markdown: String,
        baseFont: UIFont,
        baseColor: UIColor
    ) -> NSAttributedString {
        let boldFont = UIFont.systemFont(
            ofSize: baseFont.pointSize,
            weight: .bold
        )

        let result = NSMutableAttributedString()
        let segments = markdown.components(separatedBy: "**")

        for (index, segment) in segments.enumerated() {
            let font = index % 2 == 1 ? boldFont : baseFont
            result.append(
                NSAttributedString(
                    string: segment,
                    attributes: [.font: font, .foregroundColor: baseColor]
                )
            )
        }

        return result
    }
}
