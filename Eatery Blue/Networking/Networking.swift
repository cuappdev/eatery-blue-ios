//
//  Networking.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import Combine
import EateryGetAPI
import EateryModel
import Foundation
import Logging

class Networking {
    static let didLogOutNotification = Notification.Name("Networking.didLogOutNotification")

    let accounts: FetchAccounts
    let baseUrl: URL
    let eateryCache: EateryMemoryCache
    var sessionId: String {
        KeychainAccess.shared.retrieveToken(account: "SessionId") ?? ""
    }
    var accessToken: String {
        KeychainAccess.shared.retrieveToken(account: "AccessToken") ?? ""
    }
    var refreshToken: String {
        KeychainAccess.shared.retrieveToken(account: "RefreshToken") ?? ""
    }

    init(fetchUrl: URL) {
        baseUrl = fetchUrl
        let eateryApi = EateryAPI(url: fetchUrl.appendingPathComponent("eateries"))
        eateryCache = EateryMemoryCache(fetchAll: eateryApi.eateries)
        accounts = FetchAccounts()
    }

    func verifyToken() async throws {
        let eateryAPI = EateryAPI(url: baseUrl.appendingPathComponent("auth/verify-token"))
        let responseData = try await eateryAPI.verifyToken(deviceId: AuthStorage.deviceId)
        KeychainAccess.shared.saveToken(token: responseData.accessToken, account: "AccessToken")
        KeychainAccess.shared.saveToken(token: responseData.refreshToken, account: "RefreshToken")
        print("Successfully verified token. Access token: \(responseData.accessToken)")
    }
    
    func refreshAccessToken() async throws {
        let eateryAPI = EateryAPI(url: baseUrl.appendingPathComponent("auth/refresh-token"))
        if !refreshToken.isEmpty {
            let responseData = try await eateryAPI.refreshToken(deviceId: AuthStorage.deviceId, refreshToken: refreshToken)
            KeychainAccess.shared.saveToken(token: responseData.accessToken, account: "AccessToken")
            KeychainAccess.shared.saveToken(token: responseData.refreshToken, account: "RefreshToken")
        }
    }
    
    func linkGETAccount() async throws {
        let eateryAPI = EateryAPI(url: baseUrl.appendingPathComponent("auth/get/authorize"))
        if !accessToken.isEmpty && !sessionId.isEmpty {
            let _ = try await eateryAPI.linkGETAccount(accessToken: accessToken, sessionId: sessionId, pin: AuthStorage.pin)
            print("Successfully linked GET account. SessionId: \(sessionId)")
        }
    }
    
    func refreshGETSession() async throws {
        let eateryAPI = EateryAPI(url: baseUrl.appendingPathComponent("auth/get/refresh"))
        if !accessToken.isEmpty {
            let responseData = try await eateryAPI.refreGETSession(accessToken: accessToken, pin: AuthStorage.pin)
            KeychainAccess.shared.saveToken(token: responseData.sessionId, account: "SessionId")
        }
    }
    
    func getFinancials() async throws -> FinancialsResponse {
        let eateryAPI = EateryAPI(url: baseUrl.appendingPathComponent("financials"))
        do {
            return try await eateryAPI.getFinancials(accessToken: accessToken, sessionId: sessionId)
        } catch let firstError {
            logger.warning("Initial getFinancials failed: \(String(describing: firstError))")
        }
        
        do {
            try await refreshGETSession()
            return try await eateryAPI.getFinancials(accessToken: accessToken, sessionId: sessionId)
        } catch let secondError {
            logger.warning("getFinancials after refreshGETSession failed: \(String(describing: secondError))")
        }

        do {
            try await refreshAccessToken()
            try await refreshGETSession()
            return try await eateryAPI.getFinancials(accessToken: accessToken, sessionId: sessionId)
        } catch let thirdError {
            logger.error("Final getFinancials attempt failed: \(String(describing: thirdError))")
            throw thirdError
        }
    }
    
    func getAppVersion() async throws -> String {
        let eateryAPI = EateryAPI(url: baseUrl.appendingPathComponent("version"))

        return try await eateryAPI.version().version
    }

    func loadAllEatery() async throws -> [Eatery] {
        return try await eateryCache.fetchAll(maxStaleness: timeUntilFiveMinutesIntoNextHour())
    }

    func loadEatery(by id: Int) async -> Eatery? {
        var eatery: Eatery?
        if let url = URL(string: "\(baseUrl)\(id)/") {
            let eateryApi = EateryAPI(url: url)
            do {
                eatery = try await eateryCache.fetchByID(
                    maxStaleness: timeUntilFiveMinutesIntoNextHour(),
                    id: id,
                    fetchByID: eateryApi.eatery
                )
            } catch {
                logger.error("Failed to load eatery \(id)")
                return nil
            }
        }
        return eatery
    }

    func loadEateryByDay(day: Int) async throws -> [Eatery] {
        if let url = URL(string: "\(baseUrl)?days=\(day)") {
            let eateryApi = EateryAPI(url: url)
            return try await eateryApi.eateries()
        }
        return []
    }

    // Computes the time until the end of the day previous cache policy
    private func endOfDay() -> TimeInterval {
        return Calendar.current.date(
            bySettingHour: 0,
            minute: 0,
            second: 0,
            of: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        )?.timeIntervalSince(Date()) ?? 0
    }

    // Computes the time until 5 minutes into the next hour
    private func timeUntilFiveMinutesIntoNextHour() -> TimeInterval {
        let calendar = Calendar.current
        let now = Date()
        // Grab the current Y/M/D/H and bump hour by 1
        var comps = calendar.dateComponents([.year, .month, .day, .hour], from: now)
        comps.hour! += 1
        // Set minute to 5, second to 0
        comps.minute = 5
        comps.second = 0

        // Construct the future date
        guard let target = calendar.date(from: comps) else {
            return 0
        }
        return target.timeIntervalSince(now)
    }

    func logOut() {
        KeychainAccess.shared.invalidateToken(account: "SessionId")
        NotificationCenter.default.post(name: Networking.didLogOutNotification, object: self)
    }
}

struct FetchAccounts {
    private let getApi = GetAPI()

    func fetch(start: Day, end: Day) async throws -> [Account] {
        return try await fetch(start: start, end: end, retryAttempts: 1)
    }

    func fetch(start: Day, end: Day, retryAttempts: Int) async throws -> [Account] {
        logger.info("Attempting to fetch accounts start=\(start), end=\(end), retryAttempts=\(retryAttempts)")
        do {
            let sessionId = Networking.default.sessionId
            if sessionId == "App Store Testing Session ID" {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                return AccountDummyData.accounts
            } else {
                return try await getApi.accounts(sessionId: sessionId, start: start.rawValue, end: end.rawValue)
            }
        } catch {
            if retryAttempts > 0 {
                logger.warning(
                    """
                    FetchAccount failed with error: "\(error)"
                    Will invalidate sessionId and retry \(retryAttempts) more times.
                    """
                )
                KeychainAccess.shared.invalidateToken(account: "SessionId")
                return try await fetch(start: start, end: end, retryAttempts: retryAttempts - 1)

            } else {
                throw error
            }
        }
    }
}

private enum AccountDummyData {
    static let accounts = [
        Account(accountType: .bearBasic, balance: 10, transactions: [
            Transaction(
                accountType: .bearBasic,
                amount: 1,
                date: Day().date(hour: 12, minute: 0),
                location: "Okenshields"
            ),
            Transaction(
                accountType: .bearBasic,
                amount: 1,
                date: Day().advanced(by: -1).date(hour: 12, minute: 0),
                location: "North Star"
            ),
            Transaction(
                accountType: .bearBasic,
                amount: 1,
                date: Day().advanced(by: -2).date(hour: 12, minute: 0),
                location: "RPCC"
            )
        ]),
        Account(accountType: .bigRedBucks, balance: 500, transactions: [
            Transaction(
                accountType: .bigRedBucks,
                amount: 1,
                date: Day().date(hour: 12, minute: 0),
                location: "Mattin's Cafe"
            ),
            Transaction(
                accountType: .bigRedBucks,
                amount: 1,
                date: Day().advanced(by: -1).date(hour: 12, minute: 0),
                location: "Mac's Cafe"
            ),
            Transaction(
                accountType: .bigRedBucks,
                amount: 1,
                date: Day().advanced(by: -2).date(hour: 12, minute: 0),
                location: "Mac's Cafe"
            )
        ]),
        Account(accountType: .cityBucks, balance: 0, transactions: []),
        Account(accountType: .laundry, balance: 37.54, transactions: [
            Transaction(
                accountType: .laundry,
                amount: 1,
                date: Day().date(hour: 12, minute: 0),
                location: "Donlon 32 Dryer"
            ),
            Transaction(
                accountType: .laundry,
                amount: 1,
                date: Day().advanced(by: -1).date(hour: 12, minute: 0),
                location: "Dolon 32 Washer"
            ),
            Transaction(
                accountType: .laundry,
                amount: 1,
                date: Day().advanced(by: -2).date(hour: 12, minute: 0),
                location: "Dolon 27 Dryer"
            )
        ])
    ]
}
