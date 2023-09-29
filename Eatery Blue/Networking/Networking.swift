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

    static var didLogOut = false

    let eateries: InMemoryCache<[Eatery]>
    let sessionId: String = {
        return KeychainAccess().retrieveToken() ?? ""
    }()
    let accounts: FetchAccounts

    init(fetchUrl: URL) {
        let eateryApi = EateryAPI(url: fetchUrl)
        self.eateries = InMemoryCache(fetch: eateryApi.eateries)

        let getApi = GetAPI()
        
        self.accounts = FetchAccounts(getApi: getApi, sessionId: self.sessionId)
    }

    func logOut() {
        Networking.didLogOut = true
        KeychainAccess().invalidateToken()
        NotificationCenter.default.post(name: Networking.didLogOutNotification, object: self)
    }
}

struct FetchAccounts {

    private let getApi: GetAPI
    private let sessionId: String

    fileprivate init(getApi: GetAPI, sessionId: String) {
        self.getApi = getApi
        self.sessionId = sessionId
    }

    func fetch(start: Day, end: Day) async throws -> [Account] {
        return try await fetch(start: start, end: end, retryAttempts: 1)
    }

    func fetch(start: Day, end: Day, retryAttempts: Int) async throws -> [Account] {
        logger.info("Attempting to fetch accounts start=\(start), end=\(end), retryAttempts=\(retryAttempts)")
        do {
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
