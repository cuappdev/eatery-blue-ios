//
//  Networking.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import Combine
import EateryModel
import EateryGetAPI
import Foundation
import Logging
import Alamofire
import UIKit

class Networking {
    
    static let didLogOutNotification = Notification.Name("Networking.didLogOutNotification")
    
    let accounts: FetchAccounts
    let baseUrl: URL
    let eateryCache: EateryMemoryCache
    var sessionId: String {
        KeychainAccess.shared.retrieveToken() ?? ""
    }
    let simpleUrl: URL
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    init(fetchUrl: URL) {
        self.baseUrl = fetchUrl
        let eateryApi = EateryAPI(url: fetchUrl)
        self.eateryCache = EateryMemoryCache(fetchAll: eateryApi.eateries)
        self.accounts = FetchAccounts()
        self.simpleUrl = URL(string: "\(baseUrl)simple/") ?? baseUrl
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    /// Not used anymore
    func loadAllEatery() async throws-> [Eatery] {
        return try await eateryCache.fetchAll(maxStaleness: timeUntilFiveMinutesIntoNextHour())
    }
    
    /// Load single eatery
    func loadEatery(by id: Int) async -> Eatery? {
        var eatery: Eatery?
        if let url = URL(string: "\(self.baseUrl)\(id)/") {
            let eateryApi = EateryAPI(url: url)
            do {
                eatery = try await eateryCache.fetchByID(maxStaleness: timeUntilFiveMinutesIntoNextHour(), id: id, fetchByID: eateryApi.eatery)
            } catch {
                // TODO: Handle error state
                logger.error("Failed to load eatery \(id). \(error.localizedDescription)")
                return nil
            }
        }
        return eatery
    }
    
    func loadSimpleEateries() async throws -> [Eatery] {
        // No /simple anymore after backend refactoring in Nov 2025, testing if /eateries works
        let eateryApi = EateryAPI(url: self.baseUrl)
        return try await eateryApi.eateries()
    }
    
    func loadEateryByDay(day: Int) async throws -> [Eatery] {
        if let url = URL(string: "\(self.baseUrl)day/\(day)/") {
            let eateryApi = EateryAPI(url: url)
            return try await eateryApi.eateries()
        }
        return []
    }
    
    func invalidateCache() async {
        await eateryCache.invalidate()
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
        KeychainAccess.shared.invalidateToken()
        NotificationCenter.default.post(name: Networking.didLogOutNotification, object: self)
    }
    
    /// Sends session id, device id, and pin back to backend to log in
    func authorize(sessionId: String) async throws {
        let url = "\(EateryEnvironment.baseURL)/user/authorize/"
        let headers: HTTPHeaders = [
                "Authorization": "Bearer \(sessionId)"
            ]
        
        let parameters: [String: Any]
        
        if let fcmToken = PushNotificationManager.shared.fcmToken {
            parameters = [
                "device_id": AuthStorage.deviceId,
                "pin": AuthStorage.pin,
                "fcm_token": fcmToken
            ]
        } else {
            parameters = [
                "device_id": AuthStorage.deviceId,
                "pin": AuthStorage.pin,
            ]
        }
                
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url,
                       method: .post,
                       parameters: parameters,
                       encoding: JSONEncoding.default,
                       headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Called after /authorize succeeded. Updates user account info.
    func updateUserAccount(sessionId: String) async throws {
        print("Authorized, updating user account")
        let url = "\(EateryEnvironment.baseURL)/user/accounts/"
        let headers: HTTPHeaders = [
                "Authorization": "Bearer \(sessionId)"
            ]
        
        let parameters: [String: Any]
        
        if let fcmToken = PushNotificationManager.shared.fcmToken {
            parameters = [
                "device_id": AuthStorage.deviceId,
                "fcm_token": fcmToken
            ]
        } else {
            parameters = [
                "device_id": AuthStorage.deviceId
            ]
        }
                
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url,
                       method: .post,
                       parameters: parameters,
                       encoding: JSONEncoding.default,
                       headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getUserFinancials(sessionId: String) async throws -> AccountsResponse {
        let url = "\(EateryEnvironment.baseURL)/financials/"
        let headers: HTTPHeaders = [
                "Authorization": "Bearer \(sessionId)"
            ]
                        
        return try await AF.request(url, headers: headers)
            .validate()
            .serializingDecodable(AccountsResponse.self, decoder: decoder)
            .value
    }
    
    @objc private func appDidEnterBackground() {
        logger.info("App entered background – invalidating cache")
        // clear all cache as app goes to background
        Task {
            await eateryCache.invalidate()
        }
    }

}

struct FetchAccounts {
    
    private let getApi = GetAPI()

    func fetch(start: Day, end: Day) async throws -> AccountsResponse {
        return try await fetch(start: start, end: end, retryAttempts: 1)
    }

//    func fetch(start: Day, end: Day, retryAttempts: Int) async throws -> [Account] {
//        logger.info("Attempting to fetch accounts start=\(start), end=\(end), retryAttempts=\(retryAttempts)")
//        do {
//            let sessionId = Networking.default.sessionId
//            if sessionId == "App Store Testing Session ID" {
//                try await Task.sleep(nanoseconds: 1_000_000_000)
//                return AccountDummyData.accounts
//            } else {
//                return try await getApi.accounts(sessionId: sessionId, start: start.rawValue, end: end.rawValue)
//            }
//        } catch {
//            if retryAttempts > 0 {
//                logger.warning(
//                    """
//                    FetchAccount failed with error: "\(error)"
//                    Will invalidate sessionId and retry \(retryAttempts) more times.
//                    """
//                )
//                KeychainAccess.shared.invalidateToken()
//                return try await fetch(start: start, end: end, retryAttempts: retryAttempts - 1)
//                
//            } else {
//                throw error
//            }
//        }
//    }
    
    func fetch(start: Day, end: Day, retryAttempts: Int) async throws -> AccountsResponse {
        logger.info("Attempting to fetch accounts start=\(start), end=\(end), retryAttempts=\(retryAttempts)")
        do {
            let sessionId = Networking.default.sessionId
            // TODO: call /financials
            return try await Networking.default.getUserFinancials(sessionId: sessionId)
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

    static let accounts: [Account] = [
//        Account(accountType: .bearBasic, balance: 10, transactions: [
//            Transaction(accountType: .bearBasic, amount: 1, date: Day().date(hour: 12, minute: 0), location: "Okenshields"),
//            Transaction(accountType: .bearBasic, amount: 1, date: Day().advanced(by: -1).date(hour: 12, minute: 0), location: "North Star"),
//            Transaction(accountType: .bearBasic, amount: 1, date: Day().advanced(by: -2).date(hour: 12, minute: 0), location: "RPCC")
//        ]),
//        Account(accountType: .bigRedBucks, balance: 500, transactions: [
//            Transaction(accountType: .bigRedBucks, amount: 1, date: Day().date(hour: 12, minute: 0), location: "Mattin's Cafe"),
//            Transaction(accountType: .bigRedBucks, amount: 1, date: Day().advanced(by: -1).date(hour: 12, minute: 0), location: "Mac's Cafe"),
//            Transaction(accountType: .bigRedBucks, amount: 1, date: Day().advanced(by: -2).date(hour: 12, minute: 0), location: "Mac's Cafe")
//        ]),
//        Account(accountType: .cityBucks, balance: 0, transactions: []),
//        Account(accountType: .laundry, balance: 37.54, transactions: [
//            Transaction(accountType: .laundry, amount: 1, date: Day().date(hour: 12, minute: 0), location: "Donlon 32 Dryer"),
//            Transaction(accountType: .laundry, amount: 1, date: Day().advanced(by: -1).date(hour: 12, minute: 0), location: "Dolon 32 Washer"),
//            Transaction(accountType: .laundry, amount: 1, date: Day().advanced(by: -2).date(hour: 12, minute: 0), location: "Dolon 27 Dryer")
//        ]),
    ]

}
