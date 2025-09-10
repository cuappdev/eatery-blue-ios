//
//  NSTextAttachment+Extension.swift
//  Eatery Blue
//
//  Created by William Ma on 12/24/21.
//

import UIKit

extension NSTextAttachment {
    convenience init(image: UIImage?, scaledToMatch font: UIFont?, scale: CGFloat = 1.5) {
        guard let image = image, let font = font else {
            self.init()
            return
        }

        self.init(image: image)

        let scale1 = font.capHeight / image.size.height
        let scale2 = scale * scale1
        bounds = CGRect(
            x: 0,
            y: (scale1 - scale2) * image.size.height / 2,
            width: scale2 * image.size.width,
            height: scale2 * image.size.height
        )
    }
}
