//
//  NSTextAttachment.swift
//  Eatery Blue
//
//  Created by William Ma on 12/24/21.
//

import UIKit

extension NSTextAttachment {

    convenience init(image: UIImage?, scaledToMatch font: UIFont?) {
        guard let image = image, let font = font else {
            self.init()
            return
        }

        self.init(image: image)

        let scale = font.capHeight / image.size.height
        self.bounds = CGRect(
            x: 0,
            y: 0,
            width: scale * image.size.width,
            height: scale * image.size.height
        )
    }

}
