//
//  Schema.swift
//  
//
//  Created by William Ma on 1/12/22.
//

import Foundation

internal enum Schema {

    internal struct RawAccount: Decodable {

        internal let accountDisplayName: String?

        internal let balance: Double?

    }

    internal struct RawTransaction: Decodable {

        internal let accountName: String?

        internal let actualDate: String?

        internal let amount: Double?

        internal let locationName: String?

        internal let transactionType: Int?

    }

}
