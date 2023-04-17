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
        var schemaApiResponse: [Schema.Eatery] = []

        do {
            schemaApiResponse = try decoder.decode([Schema.Eatery].self, from: data)
        }
        catch {
            if let error = error as! String? { // Error is returned as a String from backend
                throw EateryAPIError.apiResponseError(error)
            }
            print(error.localizedDescription)
        }

        return schemaApiResponse.map(SchemaToModel.convert)
    }

}

