//
//  Get.swift
//  Eatery Blue
//
//  Created by William Ma on 1/6/22.
//

import Logging

// A namespace for structs and properties of the GET subsystem
enum Get {

    static var debugAttachAccountLoginWebViewToWindow = false

    static var logger = Logger(label: "com.appdev.Eatery-Blue.Get.logger")

    struct Account: Decodable {
        let accountDisplayName: String?
        let balance: Double?
    }

    struct Transaction: Decodable {
        let amount: Double?
        let actualDate: String?
        let locationName: String?
        let transactionType: Int?
        let accountName: String?
    }

}
