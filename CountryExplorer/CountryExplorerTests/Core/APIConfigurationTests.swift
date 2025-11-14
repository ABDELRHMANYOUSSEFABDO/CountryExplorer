//
//  APIConfigurationTests.swift
//  CountryExplorerTests
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import XCTest
@testable import CountryExplorer

final class APIConfigurationTests: XCTestCase {
    
    // MARK: - Tests
    
    func testAPIConfigurationSingleton() {
        // Given & When
        let config1 = APIConfiguration.shared
        let config2 = APIConfiguration.shared
        
        // Then
        XCTAssertTrue(config1.fullBaseURL == config2.fullBaseURL, "Singleton should return same instance")
    }
    
    func testBaseURLIsNotEmpty() {
        // Given
        let config = APIConfiguration.shared
        
        // When
        let baseURL = config.fullBaseURL
        
        // Then
        XCTAssertFalse(baseURL.isEmpty, "Base URL should not be empty")
        XCTAssertTrue(baseURL.hasPrefix("https://") || baseURL.hasPrefix("http://"), 
                     "Base URL should start with http:// or https://")
    }
    
    func testAPIVersionIsValid() {
        // Given
        let config = APIConfiguration.shared
        
        // When
        let version = config.apiVersion
        
        // Then
        XCTAssertFalse(version.isEmpty, "API version should not be empty")
        XCTAssertTrue(version.hasPrefix("v"), "API version should start with 'v'")
    }
    
    func testTimeoutIsPositive() {
        // Given
        let config = APIConfiguration.shared
        
        // When
        let timeout = config.requestTimeout
        
        // Then
        XCTAssertGreaterThan(timeout, 0, "Timeout should be positive")
        XCTAssertLessThanOrEqual(timeout, 60, "Timeout should not exceed 60 seconds")
    }
    
    func testDebugEnvironmentHasLongerTimeout() {
        // This test verifies that debug environment typically has longer timeout
        // Note: This might fail in production builds, which is expected
        
        // Given
        let environment = AppEnvironment.current
        let config = APIConfiguration.shared
        
        // When & Then
        if environment == .debug {
            XCTAssertEqual(config.requestTimeout, 30.0, "Debug timeout should be 30 seconds")
        } else {
            XCTAssertEqual(config.requestTimeout, 15.0, "Production timeout should be 15 seconds")
        }
    }
    
    func testFullBaseURLFormat() {
        // Given
        let config = APIConfiguration.shared
        
        // When
        let baseURL = config.fullBaseURL
        
        // Then
        // Verify it's a valid URL
        XCTAssertNotNil(URL(string: baseURL), "Base URL should be a valid URL")
        
        // Verify it doesn't end with a slash (for consistent URL building)
        XCTAssertFalse(baseURL.hasSuffix("/"), "Base URL should not end with a slash")
    }
    
    func testAPIConfigurationWithDifferentEnvironments() {
        // Given
        let currentEnv = AppEnvironment.current
        
        // When & Then
        switch currentEnv {
        case .debug:
            XCTAssertTrue(currentEnv.loggingEnabled, "Logging should be enabled in debug")
            XCTAssertEqual(currentEnv.cacheExpirationTime, 300, "Cache expiration should be 5 minutes in debug")
            
        case .production:
            XCTAssertFalse(currentEnv.loggingEnabled, "Logging should be disabled in production")
            XCTAssertEqual(currentEnv.cacheExpirationTime, 3600, "Cache expiration should be 1 hour in production")
        }
    }
    
    func testEnvironmentBasedConfiguration() {
        // Given
        let environment = AppEnvironment.current
        
        // When
        let cacheExpiration = environment.cacheExpirationTime
        let maxCacheSize = environment.maxCacheSize
        let loggingEnabled = environment.loggingEnabled
        
        // Then
        XCTAssertGreaterThan(cacheExpiration, 0, "Cache expiration should be positive")
        XCTAssertGreaterThan(maxCacheSize, 0, "Max cache size should be positive")
        
        if environment == .debug {
            XCTAssertTrue(loggingEnabled, "Logging should be enabled in debug")
            XCTAssertEqual(cacheExpiration, 300, "Debug cache expiration should be 5 minutes")
            XCTAssertEqual(maxCacheSize, 50 * 1024 * 1024, "Debug cache size should be 50 MB")
        } else {
            XCTAssertFalse(loggingEnabled, "Logging should be disabled in production")
            XCTAssertEqual(cacheExpiration, 3600, "Production cache expiration should be 1 hour")
            XCTAssertEqual(maxCacheSize, 100 * 1024 * 1024, "Production cache size should be 100 MB")
        }
    }
    
    func testPerformanceOfConfigurationAccess() {
        // Given
        let config = APIConfiguration.shared
        
        // When & Then
        measure {
            // Should be very fast since it's already initialized
            _ = config.fullBaseURL
            _ = config.requestTimeout
            _ = config.apiVersion
        }
    }
}

