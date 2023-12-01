//
//  EateryMemoryCache.swift
//  Eatery Blue
//
//  Created by Jayson Hahn on 10/25/23.
//

import Foundation
import EateryModel

actor EateryMemoryCache {
    
    private var allLoaded: Bool = false
    
    private var cachedValueDate: Date?
    private var cachedValue: [Eatery]?
    
    private let fetchAll: () async throws -> [Eatery]
    private var fetchAllTask: Task<[Eatery], Error>?
    private var fetchByIDTaskDic: [Int: Task<Eatery, Error>] = [:]
    
    init(fetchAll: @escaping () async throws -> [Eatery]) {
        self.fetchAll = fetchAll
    }
    
    func fetchAll(maxStaleness: TimeInterval) async throws -> [Eatery] {
        if !isExpired(maxStaleness: maxStaleness), let cachedValue, allLoaded {
            logger.info("\(self): Returning cached value")
            return cachedValue
        } else if let alltask = fetchAllTask {
            logger.info("\(self): Awaiting existing fetchAll task")
            return try await alltask.value
        } else {
            logger.info("\(self): Creating new fetchAll task")
            let alltask = Task { () -> [Eatery] in
                defer {
                    fetchAllTask = nil
                    allLoaded = true
                }
                let result = try await fetchAll()
                try Task.checkCancellation()
                cachedValue = result
                cachedValueDate = Date()
                return result
            }
            fetchAllTask = alltask
            return try await alltask.value
        }
    }
    
    func fetchByID(maxStaleness: TimeInterval, id: Int, fetchByID: @escaping () async throws -> Eatery) async throws -> Eatery {
        if !isExpired(maxStaleness: maxStaleness), let eateries = cachedValue, let eatery = (eateries.first { $0.id == id }) {
            logger.info("\(self): Returning cached value")
            return eatery
        } else if let task = fetchByIDTaskDic[id] {
            logger.info("\(self): Awaiting existing fetchByID task")
            return try await task.value
        } else {
            logger.info("\(self): Creating new fetch task")
            let task = Task { () -> Eatery in
                defer { fetchByIDTaskDic.removeValue(forKey: id) }
                let result = try await fetchByID()
                try Task.checkCancellation()
                if !allLoaded {
                    if cachedValue == nil { cachedValue = [] }
                    cachedValue?.append(result)
                }
                if cachedValueDate == nil {
                    cachedValueDate = Date()
                }
                return result
            }
            fetchByIDTaskDic[id] = task
            return try await task.value
        }
    }
    
    func isExpired(date: Date = Date(), maxStaleness: TimeInterval) -> Bool {
        if cachedValue == nil {
            return true
        }
        
        if let cachedValueDate = cachedValueDate {
            if (date.timeIntervalSince(cachedValueDate) > maxStaleness) {
                invalidate()
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
    
    func invalidate() {
        allLoaded = false
        cachedValue = nil
        cachedValueDate = nil
    }
    
}
