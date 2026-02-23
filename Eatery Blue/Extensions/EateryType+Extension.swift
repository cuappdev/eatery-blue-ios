//
//  EateryType+Extension.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 2/6/26.
//

import EateryModel

extension Array where Element == EateryType {
    func validated() -> [EateryType]? {
        guard count > 0 else { return nil }
        return self
    }

    func formatted() -> String {
        // should be "{0}, {1}, and {2}"
        let count = self.count
        if count == 1 {
            return self[0].description
        } else if count == 2 {
            return "\(self[0].description) and \(self[1].description)"
        } else {
            let allButLast = self[0 ..< (count - 1)].map { $0.description }.joined(separator: ", ")
            return "\(allButLast), and \(self[count - 1].description)"
        }
    }
}
