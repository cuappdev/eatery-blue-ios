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

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    public func eateries() async throws -> [Eatery] {
        let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)

        return try decoder.decode([Eatery].self, from: data)
    }

    public func eatery() async throws -> Eatery {
        let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)

        return try decoder.decode(Eatery.self, from: data)
    }

    public func reportError(eatery: Int? = nil, content: String) async {
        struct ReportData: Codable {
            let eatery: Int?
            let content: String
        }

        let reportData = ReportData(eatery: eatery, content: content)

        guard let jsonData = try? JSONEncoder().encode(reportData) else {
            logger.error("Unable to convert report data to JSON")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse {
                logger.info("\(#function): Status Code \(response.statusCode)")
            }
            if let error = error {
                logger.error("Error submitting report: \(error.localizedDescription)")
            } else if data != nil {
                logger.info("Successfully reported Eatery Blue issue")
            } else {
                logger.error("Unknown error submitting report")
            }
        }.resume()
    }
}
