//
//  CacheInvalidationServiceTests.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import XCTest
@testable import CountryExplorer

final class CacheInvalidationServiceTests: XCTestCase {
    
    var sut: CacheInvalidationService!
    
    override func setUp() {
        super.setUp()
        sut = CacheInvalidationService(
            cacheValidityDuration: 3600,
            autoRefreshThreshold: 900
        )
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    
    func testIsCacheValid_withNilDate_returnsFalse() {
        let isValid = sut.isCacheValid(lastUpdated: nil)
        
        XCTAssertFalse(isValid)
    }
    
    func testIsCacheValid_withRecentDate_returnsTrue() {
        let recentDate = Date().addingTimeInterval(-600)
        let isValid = sut.isCacheValid(lastUpdated: recentDate)
        
        XCTAssertTrue(isValid)
    }
    
    func testIsCacheValid_withExpiredDate_returnsFalse() {
        let expiredDate = Date().addingTimeInterval(-7200) 
        
        let isValid = sut.isCacheValid(lastUpdated: expiredDate)
        
        XCTAssertFalse(isValid)
    }
    
    func testIsCacheValid_withDateJustBeforeExpiry_returnsTrue() {
        let almostExpired = Date().addingTimeInterval(-3599)
        
        let isValid = sut.isCacheValid(lastUpdated: almostExpired)
        
        XCTAssertTrue(isValid)
    }
    
    // MARK: - Should Refresh Tests
    
    func testShouldRefreshCache_withNilDate_returnsTrue() {
        let shouldRefresh = sut.shouldRefreshCache(lastUpdated: nil)
        
        XCTAssertTrue(shouldRefresh)
    }
    
    func testShouldRefreshCache_withVeryRecentDate_returnsFalse() {
        let veryRecent = Date().addingTimeInterval(-300)
        
        let shouldRefresh = sut.shouldRefreshCache(lastUpdated: veryRecent)
        
        XCTAssertFalse(shouldRefresh)
    }
    
    func testShouldRefreshCache_withOldDate_returnsTrue() {
        let old = Date().addingTimeInterval(-3000)
        
        let shouldRefresh = sut.shouldRefreshCache(lastUpdated: old)
        
        XCTAssertTrue(shouldRefresh)
    }
    
    func testShouldRefreshCache_withExpiredDate_returnsTrue() {
        let expired = Date().addingTimeInterval(-7200) // 2 hours ago
        
        let shouldRefresh = sut.shouldRefreshCache(lastUpdated: expired)
        
        XCTAssertTrue(shouldRefresh)
    }
    
    
    func testRemainingCacheTime_withNilDate_returnsNil() {
        let remaining = sut.remainingCacheTime(lastUpdated: nil)
        
        XCTAssertNil(remaining)
    }
    
    func testRemainingCacheTime_withRecentDate_returnsPositiveValue() {
        let recent = Date().addingTimeInterval(-600)
        
        let remaining = sut.remainingCacheTime(lastUpdated: recent)
        
        XCTAssertNotNil(remaining)
        XCTAssertGreaterThan(remaining!, 0)
        XCTAssertLessThan(remaining!, 3600)
    }
    
    func testRemainingCacheTime_withExpiredDate_returnsNil() {
        let expired = Date().addingTimeInterval(-7200) // 2 hours ago
        
        let remaining = sut.remainingCacheTime(lastUpdated: expired)
        
        XCTAssertNil(remaining)
    }
    
    
    func testCacheFreshness_withNilDate_returnsZero() {
        let freshness = sut.cacheFreshness(lastUpdated: nil)
        
        XCTAssertEqual(freshness, 0.0, accuracy: 0.01)
    }
    
    func testCacheFreshness_withVeryRecentDate_returnsNear100() {
        let veryRecent = Date().addingTimeInterval(-60) // 1 minute ago
        
        let freshness = sut.cacheFreshness(lastUpdated: veryRecent)
        
        XCTAssertGreaterThan(freshness, 95.0)
        XCTAssertLessThanOrEqual(freshness, 100.0)
    }
    
    func testCacheFreshness_withHalfExpiredDate_returnsAround50() {
        let halfExpired = Date().addingTimeInterval(-1800)
        
        let freshness = sut.cacheFreshness(lastUpdated: halfExpired)
        
        XCTAssertGreaterThan(freshness, 45.0)
        XCTAssertLessThan(freshness, 55.0)
    }
    
    func testCacheFreshness_withExpiredDate_returnsZero() {
        let expired = Date().addingTimeInterval(-7200)
        
        let freshness = sut.cacheFreshness(lastUpdated: expired)
        
        XCTAssertEqual(freshness, 0.0, accuracy: 0.01)
    }
    
    // MARK: - Edge Cases
    
    func testCacheInvalidation_withFutureDate_isStillValid() {
        let futureDate = Date().addingTimeInterval(600)
        
        let isValid = sut.isCacheValid(lastUpdated: futureDate)
        
        XCTAssertTrue(isValid)
    }
    
    func testCacheInvalidation_withCustomDurations() {
        let shortLivedCache = CacheInvalidationService(
            cacheValidityDuration: 10,
            autoRefreshThreshold: 2
        )
        
        let recent = Date().addingTimeInterval(-5)
        
        let isValid = shortLivedCache.isCacheValid(lastUpdated: recent)
        let shouldRefresh = shortLivedCache.shouldRefreshCache(lastUpdated: recent)
        
        XCTAssertTrue(isValid)
        XCTAssertFalse(shouldRefresh)
    }
    
    func testCacheInvalidation_withLongDuration() {
        let longLivedCache = CacheInvalidationService(
            cacheValidityDuration: 7 * 24 * 60 * 60,
            autoRefreshThreshold: 24 * 60 * 60
        )
        
        let threeDaysAgo = Date().addingTimeInterval(-3 * 24 * 60 * 60)
        
        let isValid = longLivedCache.isCacheValid(lastUpdated: threeDaysAgo)
        let shouldRefresh = longLivedCache.shouldRefreshCache(lastUpdated: threeDaysAgo)
        
        XCTAssertTrue(isValid)
        XCTAssertFalse(shouldRefresh)
    }
}

