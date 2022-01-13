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

    static var logger = Logger(label: "com.appdev.Eatery-Blue.Networking.logger")

    let eateries: InMemoryCache<[Eatery]>
    let sessionId: InMemoryCache<String>
    let accounts: FetchAccounts

    init(fetchUrl: URL) {
        let eateryApi = EateryAPI(url: fetchUrl)
        self.eateries = InMemoryCache(fetch: eateryApi.eateries)

        let getApi = GetAPI()
        self.sessionId = InMemoryCache(fetch: {
            let credentials = try GetKeychainManager.shared.get()
            return try await getApi.sessionId(netId: credentials.netId, password: credentials.password)
        })

        self.accounts = FetchAccounts(getApi: getApi, sessionId: self.sessionId)
    }

    func logOut() async {
        do {
            try GetKeychainManager.shared.delete()
        } catch {
            Networking.logger.error("Unable to delete credentials while logging out: \(error)")
        }
        await sessionId.invalidate()

        NotificationCenter.default.post(name: Networking.didLogOutNotification, object: self)
    }

}

struct FetchAccounts {

    private let getApi: GetAPI
    private let sessionId: InMemoryCache<String>

    fileprivate init(getApi: GetAPI, sessionId: InMemoryCache<String>) {
        self.getApi = getApi
        self.sessionId = sessionId
    }

    func fetch(start: Day, end: Day) async throws -> [Account] {
        return try await fetch(start: start, end: end, retryAttempts: 1)
    }

    func fetch(start: Day, end: Day, retryAttempts: Int) async throws -> [Account] {
        do {
            let sessionId = try await sessionId.fetch(maxStaleness: .infinity)
            return try await getApi.accounts(sessionId: sessionId, start: start.rawValue, end: end.rawValue)

        } catch {
            if retryAttempts > 0 {
                Networking.logger.info(
                    """
                    FetchAccount failed with error: \(error)
                    Will invalidate sessionId and retry \(retryAttempts) more times.
                    """
                )
                await sessionId.invalidate()
                return try await fetch(start: start, end: end, retryAttempts: retryAttempts - 1)
                
            } else {
                throw error
            }
        }
    }

}
