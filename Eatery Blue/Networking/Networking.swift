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
    private let backendAuthenticator: BackendAuthenticator

    var sessionId: String {
        KeychainAccess.shared.retrieveToken() ?? ""
    }

    init(fetchUrl: URL) {
        baseUrl = fetchUrl
        backendAuthenticator = BackendAuthenticator(baseURL: fetchUrl)
        let eateryApi = EateryAPI(url: fetchUrl.appendingPathComponent("eateries"))
        eateryCache = EateryMemoryCache(fetchAll: eateryApi.eateries)
        accounts = FetchAccounts()
    }

    func registerFCMToken(_ token: String) async throws {
        struct RequestBody: Encodable {
            let token: String
        }

        let body = try JSONEncoder().encode(RequestBody(token: token))
        _ = try await performAuthorizedRequest { accessToken in
            var request = URLRequest(url: self.baseUrl.appendingPathComponent("users/fcm-token"))
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.httpBody = body
            return request
        }
    }

    func updateFavoriteItem(name: String, isFavorite: Bool) async throws {
        struct RequestBody: Encodable {
            let name: String
        }

        let body = try JSONEncoder().encode(RequestBody(name: name))
        _ = try await performAuthorizedRequest { accessToken in
            var request = URLRequest(url: self.baseUrl.appendingPathComponent("users/favorites/items"))
            request.httpMethod = isFavorite ? "POST" : "DELETE"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.httpBody = body
            return request
        }
    }

    private func performAuthorizedRequest(
        makeRequest: (String) -> URLRequest
    ) async throws -> Data {
        let accessToken = try await backendAuthenticator.validAccessToken()
        let firstResponse = try await send(makeRequest(accessToken))

        guard firstResponse.statusCode == 401 else {
            return try validatedData(firstResponse)
        }

        let refreshedToken = try await backendAuthenticator.refreshAccessToken(
            rejectedToken: accessToken
        )
        return try validatedData(await send(makeRequest(refreshedToken)))
    }

    private func send(_ request: URLRequest) async throws -> (data: Data, statusCode: Int) {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        return (data, httpResponse.statusCode)
    }

    private func validatedData(
        _ response: (data: Data, statusCode: Int)
    ) throws -> Data {
        guard (200 ... 299).contains(response.statusCode) else {
            print("Backend returned HTTP \(response.statusCode)")
            print("Response:", String(data: response.data, encoding: .utf8) ?? "No response body") // debug
            throw URLError(.badServerResponse)
        }
        return response.data
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

    private struct NotificationsResponse: Decodable {
        let notifications: [HubNotification]
    }

    func fetchNotifications() async throws -> [HubNotification] {
        let url = baseUrl.appendingPathComponent("users/notifications") // debug
        print("📍 Backend base URL:", baseUrl.absoluteString) // debug
        print("📍 Notifications URL:", url.absoluteString) // debug
        let data = try await performAuthorizedRequest { accessToken in
            var request = URLRequest(url: self.baseUrl.appendingPathComponent("users/notifications"))
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            return request
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .fracSecondsISO8601
        return try decoder.decode(NotificationsResponse.self, from: data).notifications
    }

    func markNotificationsRead(ids: [Int]) async throws {
        guard !ids.isEmpty else { return } // skips PATCH when there's no unread ids
        let body = try JSONEncoder().encode(["ids": ids])
        _ = try await performAuthorizedRequest { accessToken in
            var request = URLRequest(url: self.baseUrl.appendingPathComponent("users/notifications/read"))
            request.httpMethod = "PATCH"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.httpBody = body
            return request
        }
    }
}

private actor BackendAuthenticator {
    private enum AuthenticationError: Error {
        case invalidRefreshToken
    }

    private let baseURL: URL
    private var accessToken: String?
    private var refreshToken: String?
    private var authenticationTask: Task<BackendAuthTokens, Error>?
    private var refreshTask: Task<BackendAuthTokens, Error>?

    init(baseURL: URL) {
        self.baseURL = baseURL
        accessToken = KeychainAccess.shared.retrieveBackendAccessToken()
        refreshToken = KeychainAccess.shared.retrieveBackendRefreshToken()
    }

    func validAccessToken() async throws -> String {
        if let accessToken {
            return accessToken
        }
        return try await authenticateDevice()
    }

    func refreshAccessToken(rejectedToken: String) async throws -> String {
        if let accessToken, accessToken != rejectedToken {
            return accessToken
        }

        guard let refreshToken else {
            return try await authenticateDevice()
        }

        if let refreshTask {
            return try await storeAndReturnAccessToken(from: refreshTask)
        }

        let baseURL = baseURL
        let task = Task {
            try await Self.refreshTokens(
                baseURL: baseURL,
                refreshToken: refreshToken
            )
        }
        refreshTask = task

        do {
            let accessToken = try await storeAndReturnAccessToken(from: task)
            refreshTask = nil
            return accessToken
        } catch AuthenticationError.invalidRefreshToken {
            refreshTask = nil
            clearTokens()
            return try await authenticateDevice()
        } catch {
            refreshTask = nil
            throw error
        }
    }

    private func authenticateDevice() async throws -> String {
        if let authenticationTask {
            return try await storeAndReturnAccessToken(from: authenticationTask)
        }

        let baseURL = baseURL
        let deviceID = AuthStorage.deviceId
        let task = Task {
            try await Self.verifyDevice(baseURL: baseURL, deviceID: deviceID)
        }
        authenticationTask = task

        do {
            let accessToken = try await storeAndReturnAccessToken(from: task)
            authenticationTask = nil
            return accessToken
        } catch {
            authenticationTask = nil
            throw error
        }
    }

    private func storeAndReturnAccessToken(
        from task: Task<BackendAuthTokens, Error>
    ) async throws -> String {
        let tokens = try await task.value
        accessToken = tokens.accessToken
        refreshToken = tokens.refreshToken
        KeychainAccess.shared.saveBackendTokens(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken
        )
        return tokens.accessToken
    }

    private func clearTokens() {
        accessToken = nil
        refreshToken = nil
        KeychainAccess.shared.invalidateBackendTokens()
    }

    private static func verifyDevice(
        baseURL: URL,
        deviceID: String
    ) async throws -> BackendAuthTokens {
        struct RequestBody: Encodable {
            let deviceUuid: String
        }

        let body = try JSONEncoder().encode(RequestBody(deviceUuid: deviceID))
        return try await requestTokens(
            url: baseURL.appendingPathComponent("auth/verify-token"),
            body: body,
            allowsInvalidRefreshToken: false
        )
    }

    private static func refreshTokens(
        baseURL: URL,
        refreshToken: String
    ) async throws -> BackendAuthTokens {
        struct RequestBody: Encodable {
            let refreshToken: String
        }

        let body = try JSONEncoder().encode(RequestBody(refreshToken: refreshToken))
        return try await requestTokens(
            url: baseURL.appendingPathComponent("auth/refresh-token"),
            body: body,
            allowsInvalidRefreshToken: true
        )
    }

    private static func requestTokens(
        url: URL,
        body: Data,
        allowsInvalidRefreshToken: Bool
    ) async throws -> BackendAuthTokens {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if allowsInvalidRefreshToken,
           httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
            throw AuthenticationError.invalidRefreshToken
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(BackendAuthTokens.self, from: data)
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
