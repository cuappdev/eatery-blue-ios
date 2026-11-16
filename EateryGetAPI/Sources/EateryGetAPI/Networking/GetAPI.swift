//
//  GetAPI.swift
//
//
//  Created by William Ma on 1/12/22.
//

public struct GetAPI {
    public init() {}

    @MainActor
    public func accounts(sessionId: String, start: String, end: String) async throws -> AccountData {
        let sessionManager = GetSessionManager(sessionId: sessionId)

        let userId = try await sessionManager.userId()

        async let rawAccountInfo = sessionManager.accountInfo(userId: userId)
        async let rawTransactions = sessionManager.transactions(userId: userId, start: start, end: end)

        return try await SchemaToModel.convert(getAccounts: rawAccountInfo, getTransactions: rawTransactions)
    }

    @MainActor
    public func barcodeConfig(sessionId: String) async throws -> BarcodeConfig {
        let sessionManager = GetSessionManager(sessionId: sessionId)
        return try await sessionManager.nativeStartup()
    }
}
