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
    }

    // Raw JSON from GET's nativeStartup call (before we clean it up).
    // pinSeed is also in the JSON; we skip it by not listing it here.
    struct RawNativeStartup: Decodable {
        let barcodeSeed: String?
        let enableOfflineBarcodeGeneration: Bool?
    }
}
