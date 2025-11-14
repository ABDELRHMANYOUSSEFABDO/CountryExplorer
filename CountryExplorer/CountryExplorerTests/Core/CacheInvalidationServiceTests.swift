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
        // مدة صلاحية 1 ساعة، عتبة تحديث 15 دقيقة
        sut = CacheInvalidationService(
            cacheValidityDuration: 3600, // 1 hour
            autoRefreshThreshold: 900     // 15 minutes
        )
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Cache Validity Tests
    
    func testIsCacheValid_withNilDate_returnsFalse() {
        // When
        let isValid = sut.isCacheValid(lastUpdated: nil)
        
        // Then
        XCTAssertFalse(isValid)
    }
    
    func testIsCacheValid_withRecentDate_returnsTrue() {
        // Given
        let recentDate = Date().addingTimeInterval(-600) // 10 minutes ago
        
        // When
        let isValid = sut.isCacheValid(lastUpdated: recentDate)
        
        // Then
        XCTAssertTrue(isValid)
    }
    
    func testIsCacheValid_withExpiredDate_returnsFalse() {
        // Given
        let expiredDate = Date().addingTimeInterval(-7200) // 2 hours ago
        
        // When
        let isValid = sut.isCacheValid(lastUpdated: expiredDate)
        
        // Then
        XCTAssertFalse(isValid)
    }
    
    func testIsCacheValid_withDateJustBeforeExpiry_returnsTrue() {
        // Given
        let almostExpired = Date().addingTimeInterval(-3599) // 59 minutes 59 seconds ago
        
        // When
        let isValid = sut.isCacheValid(lastUpdated: almostExpired)
        
        // Then
        XCTAssertTrue(isValid)
    }
    
    // MARK: - Should Refresh Tests
    
    func testShouldRefreshCache_withNilDate_returnsTrue() {
        // When
        let shouldRefresh = sut.shouldRefreshCache(lastUpdated: nil)
        
        // Then
        XCTAssertTrue(shouldRefresh)
    }
    
    func testShouldRefreshCache_withVeryRecentDate_returnsFalse() {
        // Given
        let veryRecent = Date().addingTimeInterval(-300) // 5 minutes ago
        
        // When
        let shouldRefresh = sut.shouldRefreshCache(lastUpdated: veryRecent)
        
        // Then
        XCTAssertFalse(shouldRefresh)
    }
    
    func testShouldRefreshCache_withOldDate_returnsTrue() {
        // Given
        let old = Date().addingTimeInterval(-3000) // 50 minutes ago (past threshold)
        
        // When
        let shouldRefresh = sut.shouldRefreshCache(lastUpdated: old)
        
        // Then
        XCTAssertTrue(shouldRefresh)
    }
    
    func testShouldRefreshCache_withExpiredDate_returnsTrue() {
        // Given
        let expired = Date().addingTimeInterval(-7200) // 2 hours ago
        
        // When
        let shouldRefresh = sut.shouldRefreshCache(lastUpdated: expired)
        
        // Then
        XCTAssertTrue(shouldRefresh)
    }
    
    // MARK: - Remaining Time Tests
    
    func testRemainingCacheTime_withNilDate_returnsNil() {
        // When
        let remaining = sut.remainingCacheTime(lastUpdated: nil)
        
        // Then
        XCTAssertNil(remaining)
    }
    
    func testRemainingCacheTime_withRecentDate_returnsPositiveValue() {
        // Given
        let recent = Date().addingTimeInterval(-600) // 10 minutes ago
        
        // When
        let remaining = sut.remainingCacheTime(lastUpdated: recent)
        
        // Then
        XCTAssertNotNil(remaining)
        XCTAssertGreaterThan(remaining!, 0)
        XCTAssertLessThan(remaining!, 3600)
    }
    
    func testRemainingCacheTime_withExpiredDate_returnsNil() {
        // Given
        let expired = Date().addingTimeInterval(-7200) // 2 hours ago
        
        // When
        let remaining = sut.remainingCacheTime(lastUpdated: expired)
        
        // Then
        XCTAssertNil(remaining)
    }
    
    // MARK: - Cache Freshness Tests
    
    func testCacheFreshness_withNilDate_returnsZero() {
        // When
        let freshness = sut.cacheFreshness(lastUpdated: nil)
        
        // Then
        XCTAssertEqual(freshness, 0.0, accuracy: 0.01)
    }
    
    func testCacheFreshness_withVeryRecentDate_returnsNear100() {
        // Given
        let veryRecent = Date().addingTimeInterval(-60) // 1 minute ago
        
        // When
        let freshness = sut.cacheFreshness(lastUpdated: veryRecent)
        
        // Then
        XCTAssertGreaterThan(freshness, 95.0)
        XCTAssertLessThanOrEqual(freshness, 100.0)
    }
    
    func testCacheFreshness_withHalfExpiredDate_returnsAround50() {
        // Given
        let halfExpired = Date().addingTimeInterval(-1800) // 30 minutes ago (half of 1 hour)
        
        // When
        let freshness = sut.cacheFreshness(lastUpdated: halfExpired)
        
        // Then
        XCTAssertGreaterThan(freshness, 45.0)
        XCTAssertLessThan(freshness, 55.0)
    }
    
    func testCacheFreshness_withExpiredDate_returnsZero() {
        // Given
        let expired = Date().addingTimeInterval(-7200) // 2 hours ago
        
        // When
        let freshness = sut.cacheFreshness(lastUpdated: expired)
        
        // Then
        XCTAssertEqual(freshness, 0.0, accuracy: 0.01)
    }
    
    // MARK: - Edge Cases
    
    func testCacheInvalidation_withFutureDate_isStillValid() {
        // Given - تاريخ في المستقبل (حالة edge case)
        let futureDate = Date().addingTimeInterval(600) // 10 minutes in future
        
        // When
        let isValid = sut.isCacheValid(lastUpdated: futureDate)
        
        // Then
        XCTAssertTrue(isValid)
    }
    
    func testCacheInvalidation_withCustomDurations() {
        // Given - مدة قصيرة جداً (10 ثواني)
        let shortLivedCache = CacheInvalidationService(
            cacheValidityDuration: 10,
            autoRefreshThreshold: 2
        )
        
        let recent = Date().addingTimeInterval(-5) // 5 seconds ago
        
        // When
        let isValid = shortLivedCache.isCacheValid(lastUpdated: recent)
        let shouldRefresh = shortLivedCache.shouldRefreshCache(lastUpdated: recent)
        
        // Then
        XCTAssertTrue(isValid)
        XCTAssertFalse(shouldRefresh)
    }
    
    func testCacheInvalidation_withLongDuration() {
        // Given - مدة طويلة (7 أيام)
        let longLivedCache = CacheInvalidationService(
            cacheValidityDuration: 7 * 24 * 60 * 60, // 7 days
            autoRefreshThreshold: 24 * 60 * 60        // 1 day
        )
        
        let threeDaysAgo = Date().addingTimeInterval(-3 * 24 * 60 * 60)
        
        // When
        let isValid = longLivedCache.isCacheValid(lastUpdated: threeDaysAgo)
        let shouldRefresh = longLivedCache.shouldRefreshCache(lastUpdated: threeDaysAgo)
        
        // Then
        XCTAssertTrue(isValid)
        XCTAssertFalse(shouldRefresh)
    }
}

