//
//  Networking.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import Combine
import Foundation
import Logging

class Networking {

    static var logger = Logger(label: "com.appdev.Eatery-Blue.Networking.logger")

    let eateries: InMemoryCache<[Eatery]>
    let sessionId: InMemoryCache<String>
    let account: FetchAccount

    init(fetchUrl: URL) {
        let fetchEateries = FetchEateries(url: fetchUrl)
        self.eateries = InMemoryCache(fetch: fetchEateries.fetch)

        let sessionId = FetchGETSessionID()
        self.sessionId = InMemoryCache(fetch: sessionId.fetch)

        self.account = FetchAccount(self.sessionId)
    }

}

struct FetchEateries {

    enum FetchError: Error {
        case apiError(String)
    }

    private let url: URL
    private let decoder: JSONDecoder

    init(url: URL) {
        self.url = url
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func fetch() async throws -> [Eatery] {
        let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
        let schemaApiResponse = try decoder.decode(Schema.APIResponse.self, from: data)

        if let error = schemaApiResponse.error {
            throw FetchError.apiError(error)
        }

        return schemaApiResponse.data.map(SchemaToModel.convert)
    }

}

struct FetchGETSessionID {

    func fetch() async throws -> String {
        let credentials = try KeychainManager.shared.get()
        return try await GetAccountLogin(credentials: credentials).sessionId()
    }

}

struct FetchAccount {

    let sessionId: InMemoryCache<String>

    init(_ sessionId: InMemoryCache<String>) {
        self.sessionId = sessionId
    }

    func fetch() async throws -> Account {
        return try await fetch(retryAttempts: 1)
    }

    func fetch(retryAttempts: Int) async throws -> Account {
        do {
            let sessionId = try await sessionId.fetch(maxStaleness: .infinity)
            let sessionManager = GetSessionManager(sessionId: sessionId)

            let userId = try await sessionManager.userId()

            async let rawAccountInfo = sessionManager.accountInfo(userId: userId)
            async let rawTransactions = sessionManager.transactions(
                userId: userId,
                start: Day(),
                end: Day().advanced(by: -365)
            )

            return try await GetToModel.convert(getAccounts: rawAccountInfo, getTransactions: rawTransactions)

        } catch {
            if retryAttempts > 0 {
                Networking.logger.info(
                    """
                    FetchAccount failed with error: \(error)
                    Retrying \(retryAttempts) more times.
                    """
                )
                await sessionId.invalidate()
                return try await fetch(retryAttempts: retryAttempts - 1)
                
            } else {
                throw error
            }
        }
    }

}
