//
//  Schema.swift
//
//
//  Created by William Ma on 1/12/22.
//

import Foundation

enum Schema {
    struct RawAccount: Decodable {
        let accountDisplayName: String?

        let balance: Double?
    }

    struct RawTransaction: Decodable {
        let accountName: String?

        let actualDate: String?

        let amount: Double?

        let locationName: String?

        let transactionType: Int?

        /// Cashless key; GET may send a string or a number.
        let patronId: FlexibleID?
    }

    /// Raw `nativeStartup` payload. `pinSeed` is intentionally omitted.
    struct RawNativeStartup: Decodable {
        let barcodeSeed: String?
        let enableOfflineBarcodeGeneration: Bool?
    }
}

/// Decodes a JSON string or number into a string. Empty string → nil.
struct FlexibleID: Decodable {
    let string: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            string = nil
        } else if let value = try? container.decode(String.self) {
            string = value.isEmpty ? nil : value
        } else if let value = try? container.decode(Int.self) {
            string = String(value)
        } else {
            string = nil
        }
    }
}
