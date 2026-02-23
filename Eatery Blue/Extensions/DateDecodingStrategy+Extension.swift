//
//  DateDecodingStrategy+Extension.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 2/22/26.
//

import Foundation

extension JSONDecoder.DateDecodingStrategy {
    static let fracSecondsISO8601 = custom { decoder in
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)

        let formatter = ISO8601DateFormatter()

        // Strategy 1: Try with milliseconds
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) { return date }

        // Strategy 2: Try without milliseconds
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: dateString) { return date }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Unrecognized date format: \(dateString)"
        )
    }
}
