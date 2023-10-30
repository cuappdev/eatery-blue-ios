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

class Networking {

    static let didLogOutNotification = Notification.Name("Networking.didLogOutNotification")

    let accounts: FetchAccounts
    let baseUrl: URL
    let eateryCache: EateryMemoryCache
    var sessionId: String {
        KeychainAccess.shared.retrieveToken() ?? ""
    }
    let simpleUrl : URL

    init(fetchUrl: URL) {
        self.baseUrl = fetchUrl
        let eateryApi = EateryAPI(url: fetchUrl)
        self.eateryCache = EateryMemoryCache(fetchAll: eateryApi.eateries)
        self.accounts = FetchAccounts()
        self.simpleUrl = URL(string: "\(baseUrl)simple/") ?? baseUrl
    }
    
    func loadAllEatery() async throws-> [Eatery] {
        var eateries: [Eatery]
            eateries = try await eateryCache.fetchAll(maxStaleness: endOfDay())
        return eateries
    }
    
    func loadEatery(by id: Int) async -> Eatery? {
        var eatery: Eatery?
        if let url = URL(string: "\(self.baseUrl)\(id)/") {
            let eateryApi = EateryAPI(url: url)
            do {
                eatery = try await eateryCache.fetchByID(maxStaleness: endOfDay(), id: id, fetchByID: eateryApi.eatery)
            } catch {
                logger.error("Failed to load eatery \(id)")
                return nil
            }
        }
        return eatery
    }
    
    func loadSimpleEateries() async throws-> [Eatery] {
        let eateryApi = EateryAPI(url: simpleUrl)
            return try await eateryApi.eateries()
    }
    
    private func endOfDay() -> TimeInterval{
        let calendar = Calendar.current
        let currentDate = Date()
        if let endOfDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 1, to: currentDate)!) {
            return endOfDay.timeIntervalSince(currentDate)
        } 
        return 0
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
            Transaction(accountType: .bearBasic, amount: 1, date: Day().date(hour: 12, minute: 0), location: "Okenshields"),
            Transaction(accountType: .bearBasic, amount: 1, date: Day().advanced(by: -1).date(hour: 12, minute: 0), location: "North Star"),
            Transaction(accountType: .bearBasic, amount: 1, date: Day().advanced(by: -2).date(hour: 12, minute: 0), location: "RPCC")
        ]),
        Account(accountType: .bigRedBucks, balance: 500, transactions: [
            Transaction(accountType: .bigRedBucks, amount: 1, date: Day().date(hour: 12, minute: 0), location: "Mattin's Cafe"),
            Transaction(accountType: .bigRedBucks, amount: 1, date: Day().advanced(by: -1).date(hour: 12, minute: 0), location: "Mac's Cafe"),
            Transaction(accountType: .bigRedBucks, amount: 1, date: Day().advanced(by: -2).date(hour: 12, minute: 0), location: "Mac's Cafe")
        ]),
        Account(accountType: .cityBucks, balance: 0, transactions: []),
        Account(accountType: .laundry, balance: 37.54, transactions: [
            Transaction(accountType: .laundry, amount: 1, date: Day().date(hour: 12, minute: 0), location: "Donlon 32 Dryer"),
            Transaction(accountType: .laundry, amount: 1, date: Day().advanced(by: -1).date(hour: 12, minute: 0), location: "Dolon 32 Washer"),
            Transaction(accountType: .laundry, amount: 1, date: Day().advanced(by: -2).date(hour: 12, minute: 0), location: "Dolon 27 Dryer")
        ]),
    ]

}
