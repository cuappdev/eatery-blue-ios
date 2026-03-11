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

        let isoFormatter = ISO8601DateFormatter()

        // Strategy 1: Try with milliseconds
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: dateString) { return date }

        // Strategy 2: Try without milliseconds
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: dateString) { return date }
        
        // Strategy 3: used for date strings returned with transactions
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: dateString) {
            return date
        }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Unrecognized date format: \(dateString)"
        )
    }
}
