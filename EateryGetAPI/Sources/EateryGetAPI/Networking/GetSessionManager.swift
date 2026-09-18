//
//  GetSessionManager.swift
//  Eatery Blue
//
//  Created by William Ma on 1/6/22.
//

import Alamofire
import Foundation

class GetSessionManager {
    private struct ResponseWrapper<Response: Decodable>: Decodable {
        let response: Response
    }

    private let base: String = "https://services.get.cbord.com/GETServices/services/json"

    private let sessionId: String

    private var session: Session

    init(sessionId: String) {
        self.sessionId = sessionId

        session = Session(cachedResponseHandler: ResponseCacher.doNotCache)
    }

    @MainActor func userId() async throws -> String {
        struct Parameters: Encodable {
            let version = "1"
            let method = "retrieve"
            let params: [String: String]

            init(sessionId: String) {
                params = ["sessionId": sessionId]
            }
        }

        struct Response: Decodable {
            let id: String
        }

        let dataTask = session.request(
            "\(base)/user",
            method: .post,
            parameters: Parameters(sessionId: sessionId),
            encoder: JSONParameterEncoder.default
        )

        let responseData = try await dataTask.serializingData().value
        logger.trace("\(#function): \(String(data: responseData, encoding: .utf8) ?? "nil")")

        let response = try JSONDecoder().decode(ResponseWrapper<Response>.self, from: responseData)

        return response.response.id
    }

    @MainActor func accountInfo(userId: String) async throws -> [Schema.RawAccount] {
        struct Parameters: Encodable {
            let version = "1"
            let method = "retrieveAccountsByUser"
            let params: [String: String]

            init(sessionId: String, userId: String) {
                params = [
                    "sessionId": sessionId,
                    "userId": userId
                ]
            }
        }

        struct Response: Decodable {
            let accounts: [Schema.RawAccount]
        }

        let dataTask = session.request(
            "\(base)/commerce",
            method: .post,
            parameters: Parameters(
                sessionId: sessionId,
                userId: userId
            ),
            encoder: JSONParameterEncoder.default
        )

        let responseData = try await dataTask.serializingData().value
        logger.trace("\(#function): \(String(data: responseData, encoding: .utf8) ?? "nil")")

        let response = try JSONDecoder().decode(ResponseWrapper<Response>.self, from: responseData)
        return response.response.accounts
    }

    private struct TransactionHistoryQueryCriteria: Encodable {
        let accountId: String? = nil
        let endDate: String
        let institutionId = "73116ae4-22ad-4c71-8ffd-11ba015407b1"
        let maxReturn = 100
        let startDate: String
        let startingReturnRow: String? = nil
        let userId: String

        init(userId: String, startDate: String, endDate: String) {
            self.userId = userId
            self.startDate = startDate
            self.endDate = endDate
        }
    }

    private struct TransactionHistoryParams: Encodable {
        let paymentSystemType = 0
        let queryCriteria: TransactionHistoryQueryCriteria
        let sessionId: String

        init(sessionId: String, userId: String, startDate: String, endDate: String) {
            self.sessionId = sessionId
            queryCriteria = TransactionHistoryQueryCriteria(
                userId: userId,
                startDate: startDate,
                endDate: endDate
            )
        }
    }

    @MainActor func transactions(
        userId: String,
        start: String,
        end: String
    ) async throws -> [Schema.RawTransaction] {
        struct Parameters: Encodable {
            let version = "1"
            let method = "retrieveTransactionHistory"
            let params: TransactionHistoryParams

            init(sessionId: String, userId: String, startDate: String, endDate: String) {
                params = TransactionHistoryParams(
                    sessionId: sessionId,
                    userId: userId,
                    startDate: startDate,
                    endDate: endDate
                )
            }
        }

        struct Response: Decodable {
            let transactions: [Schema.RawTransaction]
        }

        let dataTask = session.request(
            "\(base)/commerce",
            method: .post,
            parameters: Parameters(
                sessionId: sessionId,
                userId: userId,
                startDate: start,
                endDate: end
            ),
            encoder: JSONParameterEncoder.default
        )

        let responseData = try await dataTask.serializingData().value
        logger.trace("\(#function): \(String(data: responseData, encoding: .utf8) ?? "nil")")

        let response = try JSONDecoder().decode(ResponseWrapper<Response>.self, from: responseData)
        return response.response.transactions
    }

    // POST /configuration method nativeStartup → barcode seed for this session.
    @MainActor func nativeStartup() async throws -> BarcodeConfig {
        // Body GET expects. Same shape as userId() / transactions, different method.
        struct Parameters: Encodable {
            let version = "1"
            let method = "nativeStartup"
            let params: [String: String]

            init(sessionId: String) {
                params = [
                    "clientType": "ios",
                    "clientVersion": "4.33.27",
                    "institutionId": "73116ae4-22ad-4c71-8ffd-11ba015407b1", // Cornell GET
                    "sessionId": sessionId // from Keychain after GET login
                ]
            }
        }

        let dataTask = session.request(
            "\(base)/configuration",
            method: .post,
            parameters: Parameters(sessionId: sessionId),
            encoder: JSONParameterEncoder.default
        )

        let responseData = try await dataTask.serializingData().value
        // Do not log responseData — it contains barcodeSeed.
        return try SchemaToModel.barcodeConfig(fromNativeStartupData: responseData)
    }
}
