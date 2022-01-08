//
//  GetNetworkManager.swift
//  Eatery Blue
//
//  Created by William Ma on 1/6/22.
//

import Alamofire
import Foundation

class GetSessionManager {

    struct ResponseWrapper<Response: Decodable>: Decodable {
        let response: Response
    }

    private let base: String
    private let sessionId: String

    init(base: String = "https://services.get.cbord.com/GETServices/services/json", sessionId: String) {
        self.base = base
        self.sessionId = sessionId
    }

    @MainActor func userId() async throws -> String {
        struct Parameters: Encodable {
            let version = "1"
            let method = "retrieve"
            let params: [String: String]

            init(sessionId: String) {
                self.params = ["sessionId": sessionId]
            }
        }

        struct Response: Decodable {
            let id: String
        }

        let dataTask = AF.request(
            "\(base)/user",
            method: .post,
            parameters: Parameters(sessionId: sessionId),
            encoder: JSONParameterEncoder.default
        )

        let responseData = try await dataTask.serializingData().value
        Networking.logger.trace("\(#function): \(String(data: responseData, encoding: .utf8) ?? "nil")")

        let response = try JSONDecoder().decode(ResponseWrapper<Response>.self, from: responseData)
        return response.response.id
    }

    @MainActor func accountInfo(userId: String) async throws -> [Get.RawAccount] {
        struct Parameters: Encodable {
            let version = "1"
            let method = "retrieveAccountsByUser"
            let params: [String: String]

            init(sessionId: String, userId: String) {
                self.params = [
                    "sessionId": sessionId,
                    "userId": userId
                ]
            }
        }

        struct Response: Decodable {
            let accounts: [Get.RawAccount]
        }

        let dataTask = AF.request(
            "\(base)/commerce",
            method: .post,
            parameters: Parameters(
                sessionId: sessionId,
                userId: userId
            ),
            encoder: JSONParameterEncoder.default
        )

        let responseData = try await dataTask.serializingData().value
        Networking.logger.trace("\(#function): \(String(data: responseData, encoding: .utf8) ?? "nil")")

        let response = try JSONDecoder().decode(ResponseWrapper<Response>.self, from: responseData)
        return response.response.accounts
    }

    @MainActor func transactions(userId: String, start: Day, end: Day) async throws -> [Get.RawTransaction] {
        struct Parameters: Encodable {
            struct Params: Encodable {
                struct QueryCriteria: Encodable {
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

                let paymentSystemType = 0
                let queryCriteria: QueryCriteria
                let sessionId: String

                init(sessionId: String, userId: String, startDate: String, endDate: String) {
                    self.sessionId = sessionId
                    self.queryCriteria = QueryCriteria(userId: userId, startDate: startDate, endDate: endDate)
                }
            }

            let version = "1"
            let method = "retrieveTransactionHistory"
            let params: Params

            init(sessionId: String, userId: String, startDate: String, endDate: String) {
                self.params = Params(sessionId: sessionId, userId: userId, startDate: startDate, endDate: endDate)
            }
        }

        struct Response: Decodable {
            let transactions: [Get.RawTransaction]
        }

        let dataTask = AF.request(
            "\(base)/commerce",
            method: .post,
            parameters: Parameters(
                sessionId: sessionId,
                userId: userId,
                startDate: start.iso8601(),
                endDate: end.iso8601()
            ),
            encoder: JSONParameterEncoder.default
        )

        let responseData = try await dataTask.serializingData().value
        Networking.logger.trace("\(#function): \(String(data: responseData, encoding: .utf8) ?? "nil")")

        let response = try JSONDecoder().decode(ResponseWrapper<Response>.self, from: responseData)
        return response.response.transactions
    }

}
