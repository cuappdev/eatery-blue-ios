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
        KeychainAccess.shared.retrieveToken() ?? ""
    }

    var backendAccessToken: String? {
        KeychainAccess.shared.retrieveBackendAccessToken()
    }

    var backendRefreshToken: String? {
        KeychainAccess.shared.retrieveBackendRefreshToken()
    }

    init(fetchUrl: URL) {
        baseUrl = fetchUrl
        let eateryApi = EateryAPI(url: fetchUrl.appendingPathComponent("eateries"))
        eateryCache = EateryMemoryCache(fetchAll: eateryApi.eateries)
        accounts = FetchAccounts()
    }

    func authenticateDevice() async throws {
        struct RequestBody: Encodable {
            let deviceUuid: String
        }

        let url = baseUrl.appendingPathComponent("auth/verify-token")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(RequestBody(deviceUuid: AuthStorage.deviceId))

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              200 ... 299 ~= httpResponse.statusCode
        else {
            throw URLError(.badServerResponse)
        }

        let tokens = try JSONDecoder().decode(BackendAuthTokens.self, from: data)
        KeychainAccess.shared.saveBackendTokens(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken
        )
    }

    func registerFCMToken(_ token: String) async throws {
        if backendAccessToken == nil {
            try await authenticateDevice()
        }

        guard let accessToken = backendAccessToken else {
            throw URLError(.userAuthenticationRequired)
        }

        var statusCode = try await sendFCMToken(token, accessToken: accessToken)
        if statusCode == 401 {
            try await refreshBackendAuthentication()

            guard let refreshedAccessToken = backendAccessToken else {
                throw URLError(.userAuthenticationRequired)
            }
            statusCode = try await sendFCMToken(token, accessToken: refreshedAccessToken)
        }

        guard 200 ... 299 ~= statusCode else {
            throw URLError(.badServerResponse)
        }
    }

    private func refreshBackendAuthentication() async throws {
        struct RequestBody: Encodable {
            let refreshToken: String
        }

        guard let refreshToken = backendRefreshToken else {
            try await authenticateDevice()
            return
        }

        let url = baseUrl.appendingPathComponent("auth/refresh-token")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(RequestBody(refreshToken: refreshToken))

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
            try await authenticateDevice()
            return
        }

        guard 200 ... 299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let tokens = try JSONDecoder().decode(BackendAuthTokens.self, from: data)
        KeychainAccess.shared.saveBackendTokens(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken
        )
    }

    private func sendFCMToken(_ token: String, accessToken: String) async throws -> Int {
        struct RequestBody: Encodable {
            let token: String
        }

        let url = baseUrl.appendingPathComponent("users/fcm-token")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(RequestBody(token: token))

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        return httpResponse.statusCode
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
        let dayURL = baseUrl.appendingPathComponent("eateries")
            .appending(queryItems: [URLQueryItem(name: "days", value: "\(day)")])
        let eateryAPI = EateryAPI(url: dayURL)

        return try await eateryAPI.eateries()
    }

    /// Computes the time until the end of the day previous cache policy
    private func endOfDay() -> TimeInterval {
        return Calendar.current.date(
            bySettingHour: 0,
            minute: 0,
            second: 0,
            of: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        )?.timeIntervalSince(Date()) ?? 0
    }

    /// Computes the time until 5 minutes into the next hour
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
        KeychainAccess.shared.invalidateToken()
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
                KeychainAccess.shared.invalidateToken()
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
