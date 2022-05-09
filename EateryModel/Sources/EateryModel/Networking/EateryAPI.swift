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

    public func reportError(eateryID: Int, type: String, content: String) {
        let data: [String: Any] = ["eatery_id": eateryID, "type": type, "content": content]
        let body = try? JSONSerialization.data(withJSONObject: data, options: [])

        var request = URLRequest(url: url)
        request.httpBody = body
        request.httpMethod = "POST"

        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in

            if let _ = error {
                logger.error("Error submitting report: \(error.debugDescription)")
            } else if let _ = data {
                logger.info("Successfully reported Eatery Blue issue")
            } else {
                logger.error("Unknown error submitting report")
            }
        }

        task.resume()
    }

}

