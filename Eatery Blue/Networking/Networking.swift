//
//  Networking.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import Combine
import Foundation

struct Networking {

    enum NetworkingError: Error {
        case other(String)
    }

    static let local = Networking(fetchUrl: URL(string: "http://127.0.0.1:8000/api")!)
    static let dev = Networking(fetchUrl: URL(string: "https://d706-2601-187-8400-2076-1158-3d93-7b45-1456.ngrok.io/api")!)
    static let prod = Networking(fetchUrl: URL(string: "https://d706-2601-187-8400-2076-1158-3d93-7b45-1456.ngrok.io/api")!)

    #if DEBUG
    static let `default` = dev
    #else
    static let `default` = prod
    #endif

    let fetchUrl: URL
    let decoder: JSONDecoder

    init(fetchUrl: URL) {
        self.fetchUrl = fetchUrl
        self.decoder = JSONDecoder()

        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func fetchEateries() -> AnyPublisher<[Eatery], Error> {
        return URLSession
            .shared
            .dataTaskPublisher(for: fetchUrl)
            .tryMap({ data, response in
                data
            })
            .decode(type: Schema.APIResponse.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
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
            .eraseToAnyPublisher()
    }

}
