//
//  Networking.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import Combine
import Foundation

class Networking {

    enum NetworkingError: Error {
        case other(String)
    }

    static let local = Networking(fetchUrl: URL(string: "http://127.0.0.1:8000/api")!)
    static let dev = Networking(fetchUrl: URL(string: "https://d706-2601-187-8400-2076-1158-3d93-7b45-1456.ngrok.io/api")!)
    static let prod = Networking(fetchUrl: URL(string: "https://d706-2601-187-8400-2076-1158-3d93-7b45-1456.ngrok.io/api")!)

    #if DEBUG
    static let `default` = local
    #else
    static let `default` = prod
    #endif

    let fetchUrl: URL
    let decoder: JSONDecoder

    private var lastFetch: Date?
    private var cachedEateries: [Eatery] = []
    private var fetchEateriesPublisher: AnyPublisher<[Eatery], Error>?
    private var cancellables: Set<AnyCancellable> = []

    init(fetchUrl: URL) {
        self.fetchUrl = fetchUrl
        self.decoder = JSONDecoder()

        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func isExpired(date: Date, maxStaleness: TimeInterval) -> Bool {
        if let lastFetch = lastFetch {
            return date.timeIntervalSince(lastFetch) > maxStaleness
        } else {
            return true
        }
    }

    func fetchEateries(maxStaleness: TimeInterval = 0) -> AnyPublisher<[Eatery], Error> {
        if !isExpired(date: Date(), maxStaleness: maxStaleness) {
            logger.debug("\(#function): returning \(cachedEateries.count) cached eateries")
            return Just(cachedEateries).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else if let publisher = fetchEateriesPublisher {
            logger.debug("\(#function): returning in-flight publisher")
            return publisher
        }

        logger.info("\(#function): fetching fresh eateries")

        let publisher = URLSession
            .shared
            .dataTaskPublisher(for: fetchUrl)
            .tryMap({ data, response in
                data
            })
            .decode(type: Schema.APIResponse.self, decoder: decoder)
            .tryMap({ (response: Schema.APIResponse) -> [Schema.Eatery] in
                if let error = response.error {
                    throw NetworkingError.other(error)
                }

                return response.data
            })
            .map({ (schemaEateries: [Schema.Eatery]) -> [Eatery] in
                schemaEateries.map(SchemaToModel.convert)
            })
            .receive(on: DispatchQueue.main)
            .share()
            .eraseToAnyPublisher()

        fetchEateriesPublisher = publisher

        publisher
            .sink { [self] _ in
                fetchEateriesPublisher = nil
            } receiveValue: { [self] value in
                lastFetch = Date()
                cachedEateries = value
            }
            .store(in: &cancellables)

        return publisher
    }

}
