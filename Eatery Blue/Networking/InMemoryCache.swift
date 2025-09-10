//
//  InMemoryCache.swift
//  Eatery Blue
//
//  Created by William Ma on 1/7/22.
//

import Foundation

actor InMemoryCache<Value> {
    private var cachedValueDate: Date?
    private var cachedValue: Value?

    private var fetchTask: Task<Value, Error>?
    private let fetch: () async throws -> Value

    init(fetch: @escaping () async throws -> Value) {
        self.fetch = fetch
    }

    func fetch(maxStaleness: TimeInterval) async throws -> Value {
        if !isExpired(maxStaleness: maxStaleness), let cachedValue = cachedValue {
            logger.info("\(self): Returning cached value")
            return cachedValue

        } else if let task = fetchTask {
            logger.info("\(self): Awaiting existing fetch task")
            return try await task.value

        } else {
            logger.info("\(self): Creating new fetch task")
            let task = Task { () -> Value in
                defer { fetchTask = nil }
                let result = try await fetch()
                try Task.checkCancellation()
                cachedValue = result
                cachedValueDate = Date()
                return result
            }
            fetchTask = task
            return try await task.value
        }
    }

    func isExpired(date: Date = Date(), maxStaleness: TimeInterval) -> Bool {
        if cachedValue == nil {
            return true
        }

        if let cachedValueDate = cachedValueDate {
            return date.timeIntervalSince(cachedValueDate) > maxStaleness
        } else {
            return true
        }
    }

    func invalidate() {
        cachedValue = nil
        cachedValueDate = nil
        fetchTask?.cancel()
    }
}
