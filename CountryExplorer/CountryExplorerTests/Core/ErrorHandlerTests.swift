//
//  ErrorHandlerTests.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import XCTest
@testable import CountryExplorer

final class ApplicationErrorTests: XCTestCase {
    
    // MARK: - Error Description Tests
    
    func testNetworkError_returnsCorrectDescription() {
        // Given
        let networkError = NetworkError.noInternetConnection
        let appError = ApplicationError.networkError(networkError)
        
        // Then
        XCTAssertNotNil(appError.errorDescription)
        XCTAssertTrue(appError.errorDescription?.contains("internet") ?? false)
    }
    
    func testAPIError_returnsCorrectDescription() {
        // Given
        let error = ApplicationError.apiError(statusCode: 404, message: "Not found")
        
        // Then
        XCTAssertEqual(error.errorDescription, "Not found")
    }
    
    func testAPIErrorWithoutMessage_returnsStatusCode() {
        // Given
        let error = ApplicationError.apiError(statusCode: 500, message: nil)
        
        // Then
        XCTAssertEqual(error.errorDescription, "Server error: 500")
    }
    
    func testTimeout_returnsCorrectDescription() {
        // Given
        let error = ApplicationError.timeout
        
        // Then
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("timed out") ?? false)
    }
    
    func testNoInternetConnection_returnsCorrectDescription() {
        // Given
        let error = ApplicationError.noInternetConnection
        
        // Then
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("internet") ?? false)
    }
    
    func testDecodingFailed_returnsCorrectDescription() {
        // Given
        let error = ApplicationError.decodingFailed
        
        // Then
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("process") ?? false)
    }
    
    func testDatabaseError_returnsCorrectDescription() {
        // Given
        let error = ApplicationError.databaseError("Failed to save")
        
        // Then
        XCTAssertEqual(error.errorDescription, "Database error: Failed to save")
    }
    
    func testMaxCountriesReached_returnsCorrectDescription() {
        // Given
        let error = ApplicationError.maxCountriesReached
        
        // Then
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("5") ?? false)
    }
    
    func testCountryAlreadyAdded_returnsCorrectDescription() {
        // Given
        let error = ApplicationError.countryAlreadyAdded
        
        // Then
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("already") ?? false)
    }
    
    func testInvalidCountryCode_returnsCorrectDescription() {
        // Given
        let error = ApplicationError.invalidCountryCode
        
        // Then
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("Invalid") ?? false)
    }
    
    // MARK: - Recovery Suggestion Tests
    
    func testNoInternetConnection_returnsRecoverySuggestion() {
        // Given
        let error = ApplicationError.noInternetConnection
        
        // Then
        XCTAssertNotNil(error.recoverySuggestion)
        XCTAssertTrue(error.recoverySuggestion?.contains("internet") ?? false)
    }
    
    func testMaxCountriesReached_returnsRecoverySuggestion() {
        // Given
        let error = ApplicationError.maxCountriesReached
        
        // Then
        XCTAssertNotNil(error.recoverySuggestion)
        XCTAssertTrue(error.recoverySuggestion?.contains("Remove") ?? false)
    }
    
    func testCountryAlreadyAdded_returnsRecoverySuggestion() {
        // Given
        let error = ApplicationError.countryAlreadyAdded
        
        // Then
        XCTAssertNotNil(error.recoverySuggestion)
        XCTAssertTrue(error.recoverySuggestion?.contains("different") ?? false)
    }
    
    // MARK: - Retryable Tests
    
    func testNetworkError_isRetryable() {
        // Given
        let error = ApplicationError.networkError(.noInternetConnection)
        
        // Then
        XCTAssertTrue(error.isRetryable)
    }
    
    func testTimeout_isRetryable() {
        // Given
        let error = ApplicationError.timeout
        
        // Then
        XCTAssertTrue(error.isRetryable)
    }
    
    func testNoInternetConnection_isRetryable() {
        // Given
        let error = ApplicationError.noInternetConnection
        
        // Then
        XCTAssertTrue(error.isRetryable)
    }
    
    func testAPIError_isRetryable() {
        // Given
        let error = ApplicationError.apiError(statusCode: 500, message: nil)
        
        // Then
        XCTAssertTrue(error.isRetryable)
    }
    
    func testDatabaseError_isNotRetryable() {
        // Given
        let error = ApplicationError.databaseError("Failed")
        
        // Then
        XCTAssertFalse(error.isRetryable)
    }
    
    func testDecodingFailed_isNotRetryable() {
        // Given
        let error = ApplicationError.decodingFailed
        
        // Then
        XCTAssertFalse(error.isRetryable)
    }
    
    func testMaxCountriesReached_isNotRetryable() {
        // Given
        let error = ApplicationError.maxCountriesReached
        
        // Then
        XCTAssertFalse(error.isRetryable)
    }
    
    // MARK: - Equality Tests
    
    func testNetworkErrors_areEqual() {
        // Given
        let error1 = ApplicationError.networkError(.noInternetConnection)
        let error2 = ApplicationError.networkError(.noInternetConnection)
        
        // Then
        XCTAssertEqual(error1, error2)
    }
    
    func testAPIErrors_withSameValues_areEqual() {
        // Given
        let error1 = ApplicationError.apiError(statusCode: 404, message: "Not found")
        let error2 = ApplicationError.apiError(statusCode: 404, message: "Not found")
        
        // Then
        XCTAssertEqual(error1, error2)
    }
    
    func testAPIErrors_withDifferentValues_areNotEqual() {
        // Given
        let error1 = ApplicationError.apiError(statusCode: 404, message: "Not found")
        let error2 = ApplicationError.apiError(statusCode: 500, message: "Server error")
        
        // Then
        XCTAssertNotEqual(error1, error2)
    }
    
    func testMaxCountriesReached_areEqual() {
        // Given
        let error1 = ApplicationError.maxCountriesReached
        let error2 = ApplicationError.maxCountriesReached
        
        // Then
        XCTAssertEqual(error1, error2)
    }
    
    func testDifferentErrorTypes_areNotEqual() {
        // Given
        let error1 = ApplicationError.maxCountriesReached
        let error2 = ApplicationError.countryAlreadyAdded
        
        // Then
        XCTAssertNotEqual(error1, error2)
    }
}

// MARK: - Network Error Tests
final class NetworkErrorTests: XCTestCase {
    
    func testNoInternetConnection_returnsCorrectDescription() {
        // Given
        let error = NetworkError.noInternetConnection
        
        // Then
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("No internet") ?? false)
    }
    
    func testRequestFailed_returnsCorrectDescription() {
        // Given
        let error = NetworkError.requestFailed(statusCode: 404)
        
        // Then
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("404") ?? false)
    }
    
    func testInvalidResponse_returnsCorrectDescription() {
        // Given
        let error = NetworkError.invalidResponse
        
        // Then
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("Invalid") ?? false)
    }
    
    func testTimeout_returnsCorrectDescription() {
        // Given
        let error = NetworkError.timeout
        
        // Then
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("timeout") ?? false)
    }
    
    func testNetworkErrors_areEqual() {
        // Given
        let error1 = NetworkError.noInternetConnection
        let error2 = NetworkError.noInternetConnection
        
        // Then
        XCTAssertEqual(error1, error2)
    }
    
    func testRequestFailedErrors_withSameStatusCode_areEqual() {
        // Given
        let error1 = NetworkError.requestFailed(statusCode: 404)
        let error2 = NetworkError.requestFailed(statusCode: 404)
        
        // Then
        XCTAssertEqual(error1, error2)
    }
    
    func testRequestFailedErrors_withDifferentStatusCodes_areNotEqual() {
        // Given
        let error1 = NetworkError.requestFailed(statusCode: 404)
        let error2 = NetworkError.requestFailed(statusCode: 500)
        
        // Then
        XCTAssertNotEqual(error1, error2)
    }
}

