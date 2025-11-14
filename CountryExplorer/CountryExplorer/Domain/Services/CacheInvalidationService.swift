//
//  CacheInvalidationService.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation

protocol CacheInvalidationServiceProtocol {
    func isCacheValid(lastUpdated: Date?) -> Bool
    func shouldRefreshCache(lastUpdated: Date?) -> Bool
}

final class CacheInvalidationService: CacheInvalidationServiceProtocol {
    
    
    private let cacheValidityDuration: TimeInterval
    
    private let autoRefreshThreshold: TimeInterval
    
    init(
        cacheValidityDuration: TimeInterval = 24 * 60 * 60, // 24 hours
        autoRefreshThreshold: TimeInterval = 1 * 60 * 60    // 1 hour
    ) {
        self.cacheValidityDuration = cacheValidityDuration
        self.autoRefreshThreshold = autoRefreshThreshold
    }
    
    
    func isCacheValid(lastUpdated: Date?) -> Bool {
        guard let lastUpdated = lastUpdated else {
            return false
        }
        
        let expirationDate = lastUpdated.addingTimeInterval(cacheValidityDuration)
        return Date() < expirationDate
    }
    
    func shouldRefreshCache(lastUpdated: Date?) -> Bool {
        guard let lastUpdated = lastUpdated else {
            return true
        }
        
        let refreshDate = lastUpdated.addingTimeInterval(cacheValidityDuration - autoRefreshThreshold)
        return Date() >= refreshDate
    }
    
    
    func remainingCacheTime(lastUpdated: Date?) -> TimeInterval? {
        guard let lastUpdated = lastUpdated else {
            return nil
        }
        
        let expirationDate = lastUpdated.addingTimeInterval(cacheValidityDuration)
        let remaining = expirationDate.timeIntervalSince(Date())
        
        return remaining > 0 ? remaining : nil
    }
    
    func cacheFreshness(lastUpdated: Date?) -> Double {
        guard let remaining = remainingCacheTime(lastUpdated: lastUpdated) else {
            return 0.0
        }
        
        let freshness = (remaining / cacheValidityDuration) * 100
        return min(max(freshness, 0.0), 100.0)
    }
}


enum CacheStrategy {
    case cacheFirst
    
    case networkFirst
    
    case staleWhileRevalidate
    
    case cacheOnly
    
    case networkOnly
}

enum CacheStatus {
    case fresh
    case stale
    case expired
    case missing
}

