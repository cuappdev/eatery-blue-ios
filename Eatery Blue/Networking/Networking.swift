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

    let eateries: InMemoryCache<[Eatery]>
    var sessionId: InMemoryCache<String>
    let accounts: FetchAccounts

    init(fetchUrl: URL) {
        let eateryApi = EateryAPI(url: fetchUrl)
        self.eateries = InMemoryCache(fetch: eateryApi.eateries)

        let getApi = GetAPI()
        self.sessionId = InMemoryCache(fetch: {
            let credentials = try NetIDKeychainManager.shared.get()
            if credentials.netId == "abc123", credentials.password == "password" {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                return "App Store Testing Session ID"
            } else {
                return ""
            }
        })

        self.accounts = FetchAccounts(getApi: getApi, sessionId: sessionId)
    }
    
    func cacheSessionId(_ sessionId: String) async {
        self.sessionId = InMemoryCache(fetch: { return sessionId })
    }

    func logOut() async {
        do {
            try NetIDKeychainManager.shared.delete()
        } catch {
            logger.error("Unable to delete credentials while logging out: \(error)")
        }
        await sessionId.invalidate()

        NotificationCenter.default.post(name: Networking.didLogOutNotification, object: self)
    }
}

struct FetchAccounts {

    private let getApi: GetAPI
//    private let sessionId: InMemoryCache<String>

    fileprivate init(getApi: GetAPI, sessionId: InMemoryCache<String>) {
        self.getApi = getApi
//        self.sessionId = sessionId
    }

    func fetch(start: Day, end: Day, sessionId: String) async throws -> [Account] {
        return try await fetch(start: start, end: end, sessionId: sessionId, retryAttempts: 1)
    }

    func fetch(start: Day, end: Day, sessionId: String, retryAttempts: Int) async throws -> [Account] {
        logger.info("Attempting to fetch accounts start=\(start), end=\(end), retryAttempts=\(retryAttempts)")
        do {
//            let sessionId = try await sessionId.fetch(maxStaleness: .infinity)

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
//                await sessionId.invalidate()
                return try await fetch(start: start, end: end, sessionId: sessionId, retryAttempts: retryAttempts - 1)
                
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
