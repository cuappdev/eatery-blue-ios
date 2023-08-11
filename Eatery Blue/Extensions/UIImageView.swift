//
//  UIImageView.swift
//  Eatery Blue
//
//  Created by Jennifer Gu on 8/11/23.
//

import UIKit

extension UIImageView {
    func downloadImage(with url: URL?, contentMode: UIView.ContentMode = UIView.ContentMode.scaleAspectFill) {
        guard let url = url else { return }
        URLSession.shared.dataTask(with: url as URL, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                self.contentMode = contentMode
                if let data = data { self.image = UIImage(data: data) }
            }
        }).resume()
    }
}
