//
//  GetAPI.swift
//  
//
//  Created by William Ma on 1/12/22.
//

public struct GetAPI {

    public init() {
    }

    @MainActor
    public func sessionId(netId: String, password: String) async throws -> String {
        try await GetAccountLogin(netId: netId, password: password).sessionId()
    }

    @MainActor
    public func accounts(sessionId: String, start: String, end: String) async throws -> [Account] {
        let sessionManager = GetSessionManager(sessionId: sessionId)

        let userId = try await sessionManager.userId()

        async let rawAccountInfo = sessionManager.accountInfo(userId: userId)
        async let rawTransactions = sessionManager.transactions(userId: userId, start: start, end: end)

        return try await SchemaToModel.convert(getAccounts: rawAccountInfo, getTransactions: rawTransactions)
    }

}
