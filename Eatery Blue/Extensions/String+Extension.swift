//
//  String+Extension.swift
//  Eatery Blue
//
//  Created by Jayson Hahn on 10/17/23.
//

import EateryModel
import Foundation

extension String {
    /**
     Determines if a string has meaningful characters (not just whitespace or empty string).

     - Returns: `nil` if the string is empty or only contains whitespace/newline characters.
                Otherwise, returns the original string.
     */
    func validated() -> String? {
        if trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return nil
        }

        return self
    }
}
