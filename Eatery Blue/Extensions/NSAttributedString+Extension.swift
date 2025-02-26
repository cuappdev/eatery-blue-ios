//
//  NSAttributedString+Extension.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 1/12/25.
//

import Foundation

extension NSAttributedString {

    func split(seperateBy: String) -> [NSAttributedString] {
        let input = self.string
        let separatedInput = input.components(separatedBy: seperateBy)
        var output = [NSAttributedString]()
        var start = 0
        separatedInput.forEach { sub in
            let range = NSMakeRange(start, sub.utf16.count)
            let attribStr = self.attributedSubstring(from: range)
            output.append(attribStr)
            start += range.length + seperateBy.count
        }

        return output
    }

}