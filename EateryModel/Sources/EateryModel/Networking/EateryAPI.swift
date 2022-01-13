//
//  EateryAPI.swift
//  
//
//  Created by William Ma on 1/12/22.
//

import Foundation

public struct EateryAPI {

    private let decoder: JSONDecoder

    private let url: URL

    public init(url: URL) {
        self.url = url

        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    public func eateries() async throws -> [Eatery] {
        let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
        let schemaApiResponse = try decoder.decode(Schema.APIResponse.self, from: data)

        if let error = schemaApiResponse.error {
            throw EateryAPIError.apiResponseError(error)
        }

        return schemaApiResponse.data.map(SchemaToModel.convert)
    }

}

