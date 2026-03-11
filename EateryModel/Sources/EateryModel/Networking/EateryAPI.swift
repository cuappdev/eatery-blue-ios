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
        decoder.dateDecodingStrategy = .fracSecondsISO8601
    }

    public func verifyToken(deviceId: String) async throws -> AccessTokenResponse {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = [
            "deviceUuid": deviceId
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        return try decoder.decode(AccessTokenResponse.self, from: data)
    }
    
    public func refreshToken(deviceId: String, refreshToken: String) async throws -> AccessTokenResponse {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = [
            "deviceUuid": deviceId,
            "refreshToken": refreshToken
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        return try decoder.decode(AccessTokenResponse.self, from: data)
    }
    
    /// Link GET account to user on core backend for persistent login.
    public func linkGETAccount(accessToken: String, sessionId: String, pin: String) async throws -> Bool {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = [
            "pin": pin,
            "sessionId": sessionId
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)
            
        if let httpResponse = response as? HTTPURLResponse {
            return 200...299 ~= httpResponse.statusCode
        }
        
        return false
    }
    
    /// Refreshes GET session and returns a new session id. 
    public func refreGETSession(accessToken: String, pin: String) async throws -> SessionIdResponse {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = [
            "pin": pin
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        return try decoder.decode(SessionIdResponse.self, from: data)
    }
    
    /// Registers or updates fcm token to the backend. Returns true if successfule, false if not.
    public func addOrUpdateFcmToken(accessToken: String, fcmToken: String) async -> Bool {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = [
            "token": fcmToken
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }

            guard 200...299 ~= httpResponse.statusCode else {
                return false
            }
            
            return true
        } catch {
            return false
        }
    }
    
    /// Deletes fcm token to the backend. Returns true if successfule, false if not. Used when users want to opt out of notification.
    public func deleteFcmToken(accessToken: String, fcmToken: String) async -> Bool {
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = [
            "token": fcmToken
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }

            guard 200...299 ~= httpResponse.statusCode else {
                return false
            }
            
            return true
        } catch {
            return false
        }
    }
    
    /// Adds item with name itemName to favorite items on the backend. Returns true if successfule, false if not.
    public func addFavoriteItem(accessToken: String, itemName: String) async -> Bool {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = [
            "name": itemName
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }

            guard 200...299 ~= httpResponse.statusCode else {
                return false
            }
            
            return true
        } catch {
            return false
        }
    }
    
    /// Deletes item with name itemName from favorite items on the backend. Returns true if successfule, false if not.
    public func deleteFavoriteItem(accessToken: String, itemName: String) async -> Bool {
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = [
            "name": itemName
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }

            guard 200...299 ~= httpResponse.statusCode else {
                return false
            }
            
            return true
        } catch {
            return false
        }
    }
    
    /// Adds eatery to favorite eateries on the backend. Returns true if successfule, false if not.
    public func addFavoriteEatery(accessToken: String, eateryName: String) async -> Bool {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = [
            "name": eateryName
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }

            guard 200...299 ~= httpResponse.statusCode else {
                return false
            }
            
            return true
        } catch {
            return false
        }
    }
    
    /// Deletes eatery from favorite eateries on the backend. Returns true if successfule, false if not.
    public func deleteFavoriteEatery(accessToken: String, eateryName: String) async -> Bool {
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = [
            "name": eateryName
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }

            guard 200...299 ~= httpResponse.statusCode else {
                return false
            }
            
            return true
        } catch {
            return false
        }
    }
    
    public func getFinancials(accessToken: String, sessionId: String) async throws -> FinancialsResponse {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
         request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = [
            "sessionId": sessionId
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        return try decoder.decode(FinancialsResponse.self, from: data)
    }
    
    public func version() async throws -> VersionResponse {
        let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)

        return try decoder.decode(VersionResponse.self, from: data)
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
