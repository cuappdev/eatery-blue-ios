//
//  ProfileCache.swift
//  Eatery Blue
//
//  Created by Amy Yang on 11/24/26.
//

import Foundation

actor ProfileCache {
    private var cachedValue: ProfileResponse?
    private var cachedValueDate: Date?
    private var fetchTask: Task<ProfileResponse, Error>?

    func fetch(maxStaleness: TimeInterval,
               fetchProfile: @escaping () async throws -> ProfileResponse) async throws -> ProfileResponse {
        if let cachedValue, let cachedValueDate,
           Date().timeIntervalSince(cachedValueDate) < maxStaleness {
            logger.info("\(self): Returning cached profile")
            return cachedValue
        }

        if let fetchTask {
            logger.info("\(self): Awaiting existing profile fetch task")
            return try await fetchTask.value
        }

        logger.info("\(self): Creating new profile fetch task")
        let task = Task<ProfileResponse, Error> {
            defer { fetchTask = nil }
            let result = try await fetchProfile()
            cachedValue = result
            cachedValueDate = Date()
            return result
        }
        fetchTask = task
        return try await task.value
    }

    func invalidate() {
        cachedValue = nil
        cachedValueDate = nil
    }
}
