//
//  ErrorHandlerTests.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import XCTest
@testable import CountryExplorer

final class ApplicationErrorTests: XCTestCase {
    
    
    func testNetworkError_returnsCorrectDescription() {
        let networkError = NetworkError.noInternetConnection
        let appError = ApplicationError.networkError(networkError)
        
        XCTAssertNotNil(appError.errorDescription)
        XCTAssertTrue(appError.errorDescription?.contains("internet") ?? false)
    }
    
    func testAPIError_returnsCorrectDescription() {
        let error = ApplicationError.apiError(statusCode: 404, message: "Not found")
        
        XCTAssertEqual(error.errorDescription, "Not found")
    }
    
    func testAPIErrorWithoutMessage_returnsStatusCode() {
        let error = ApplicationError.apiError(statusCode: 500, message: nil)
        
        XCTAssertEqual(error.errorDescription, "Server error: 500")
    }
    
    func testTimeout_returnsCorrectDescription() {
        let error = ApplicationError.timeout
        
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("timed out") ?? false)
    }
    
    func testNoInternetConnection_returnsCorrectDescription() {
        let error = ApplicationError.noInternetConnection
        
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("internet") ?? false)
    }
    
    func testDecodingFailed_returnsCorrectDescription() {
        let error = ApplicationError.decodingFailed
        
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("process") ?? false)
    }
    
    func testDatabaseError_returnsCorrectDescription() {
        let error = ApplicationError.databaseError("Failed to save")
        
        XCTAssertEqual(error.errorDescription, "Database error: Failed to save")
    }
    
    func testMaxCountriesReached_returnsCorrectDescription() {
        let error = ApplicationError.maxCountriesReached
        
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("5") ?? false)
    }
    
    func testCountryAlreadyAdded_returnsCorrectDescription() {
        let error = ApplicationError.countryAlreadyAdded
        
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("already") ?? false)
    }
    
    func testInvalidCountryCode_returnsCorrectDescription() {
        let error = ApplicationError.invalidCountryCode
        

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("Invalid") ?? false)
    }
    
    
    func testNoInternetConnection_returnsRecoverySuggestion() {
        let error = ApplicationError.noInternetConnection
        
        XCTAssertNotNil(error.recoverySuggestion)
        XCTAssertTrue(error.recoverySuggestion?.contains("internet") ?? false)
    }
    
    func testMaxCountriesReached_returnsRecoverySuggestion() {
        let error = ApplicationError.maxCountriesReached
        
        XCTAssertNotNil(error.recoverySuggestion)
        XCTAssertTrue(error.recoverySuggestion?.contains("Remove") ?? false)
    }
    
    func testCountryAlreadyAdded_returnsRecoverySuggestion() {
        let error = ApplicationError.countryAlreadyAdded
        
        XCTAssertNotNil(error.recoverySuggestion)
        XCTAssertTrue(error.recoverySuggestion?.contains("different") ?? false)
    }
    
    
    func testNetworkError_isRetryable() {
        let error = ApplicationError.networkError(.noInternetConnection)
        
        XCTAssertTrue(error.isRetryable)
    }
    
    func testTimeout_isRetryable() {
        let error = ApplicationError.timeout
        
        XCTAssertTrue(error.isRetryable)
    }
    
    func testNoInternetConnection_isRetryable() {
        let error = ApplicationError.noInternetConnection
        
        XCTAssertTrue(error.isRetryable)
    }
    
    func testAPIError_isRetryable() {
        let error = ApplicationError.apiError(statusCode: 500, message: nil)
        
        XCTAssertTrue(error.isRetryable)
    }
    
    func testDatabaseError_isNotRetryable() {
        let error = ApplicationError.databaseError("Failed")
        
        XCTAssertFalse(error.isRetryable)
    }
    
    func testDecodingFailed_isNotRetryable() {
        let error = ApplicationError.decodingFailed
        
        XCTAssertFalse(error.isRetryable)
    }
    
    func testMaxCountriesReached_isNotRetryable() {
        let error = ApplicationError.maxCountriesReached
        
        XCTAssertFalse(error.isRetryable)
    }
    
    
    func testNetworkErrors_areEqual() {
        let error1 = ApplicationError.networkError(.noInternetConnection)
        let error2 = ApplicationError.networkError(.noInternetConnection)
        
        XCTAssertEqual(error1, error2)
    }
    
    func testAPIErrors_withSameValues_areEqual() {
        let error1 = ApplicationError.apiError(statusCode: 404, message: "Not found")
        let error2 = ApplicationError.apiError(statusCode: 404, message: "Not found")
        
        XCTAssertEqual(error1, error2)
    }
    
    func testAPIErrors_withDifferentValues_areNotEqual() {
        let error1 = ApplicationError.apiError(statusCode: 404, message: "Not found")
        let error2 = ApplicationError.apiError(statusCode: 500, message: "Server error")
        
        XCTAssertNotEqual(error1, error2)
    }
    
    func testMaxCountriesReached_areEqual() {
        let error1 = ApplicationError.maxCountriesReached
        let error2 = ApplicationError.maxCountriesReached
        
        XCTAssertEqual(error1, error2)
    }
    
    func testDifferentErrorTypes_areNotEqual() {
        let error1 = ApplicationError.maxCountriesReached
        let error2 = ApplicationError.countryAlreadyAdded
        
        XCTAssertNotEqual(error1, error2)
    }
}

final class NetworkErrorTests: XCTestCase {
    
    func testNoInternetConnection_returnsCorrectDescription() {
        let error = NetworkError.noInternetConnection
        
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("No internet") ?? false)
    }
    
    func testRequestFailed_returnsCorrectDescription() {
        let error = NetworkError.serverError(statusCode: 404, message: nil)
        
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("404") ?? false)
    }
    
    func testInvalidResponse_returnsCorrectDescription() {
        let error = NetworkError.invalidURL
        
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("Invalid") ?? false)
    }
    
    func testTimeout_returnsCorrectDescription() {
        let error = NetworkError.timeout
        
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("timeout") ?? false)
    }
    
    func testNetworkErrors_areEqual() {
        let error1 = NetworkError.noInternetConnection
        let error2 = NetworkError.noInternetConnection
        
        XCTAssertEqual(error1, error2)
    }
    
    func testRequestFailedErrors_withSameStatusCode_areEqual() {
        let error1 = NetworkError.serverError(statusCode: 404, message: nil)
        let error2 = NetworkError.serverError(statusCode: 404, message: nil)
        
        XCTAssertEqual(error1, error2)
    }
    
    func testRequestFailedErrors_withDifferentStatusCodes_areNotEqual() {
        let error1 = NetworkError.serverError(statusCode: 404, message: nil)
        let error2 = NetworkError.serverError(statusCode: 500, message: nil)
        
        XCTAssertNotEqual(error1, error2)
    }
}

