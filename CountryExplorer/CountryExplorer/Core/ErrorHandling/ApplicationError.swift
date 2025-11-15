//
//  ApplicationError.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//


import Foundation


enum ApplicationError: LocalizedError, Equatable {
    case networkError(NetworkError)
    case apiError(statusCode: Int, message: String?)
    case timeout
    case noInternetConnection
    
    case decodingFailed
    case encodingFailed
    case dataNotFound
    case invalidData
    
    case databaseError(String)
    case cacheError(String)
    case fileSystemError(String)
    
    case maxCountriesReached
    case countryAlreadyAdded
    case invalidCountryCode
    case locationPermissionDenied
    
    case unknown(String)
    case notImplemented
    
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return error.errorDescription
        case .apiError(let statusCode, let message):
            return message ?? "Server error: \(statusCode)"
        case .timeout:
            return "The request timed out. Please try again."
        case .noInternetConnection:
            return "No internet connection. Please check your network settings."
        case .decodingFailed:
            return "Failed to process server response."
        case .encodingFailed:
            return "Failed to encode data."
        case .dataNotFound:
            return "Requested data not found."
        case .invalidData:
            return "Invalid data received."
        case .databaseError(let message):
            return "Database error: \(message)"
        case .cacheError(let message):
            return "Cache error: \(message)"
        case .fileSystemError(let message):
            return "File system error: \(message)"
        case .maxCountriesReached:
            return "You can only add up to 5 countries to your list."
        case .countryAlreadyAdded:
            return "This country is already in your list."
        case .invalidCountryCode:
            return "Invalid country code provided."
        case .locationPermissionDenied:
            return "Location permission denied. Using default country."
        case .unknown(let message):
            return message
        case .notImplemented:
            return "This feature is not yet implemented."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .noInternetConnection, .networkError, .timeout:
            return "Please check your internet connection and try again."
        case .maxCountriesReached:
            return "Remove a country from your list to add a new one."
        case .countryAlreadyAdded:
            return "Choose a different country to add."
        case .locationPermissionDenied:
            return "Enable location services in Settings to use this feature."
        default:
            return "Please try again later."
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .networkError, .timeout, .noInternetConnection, .apiError:
            return true
        default:
            return false
        }
    }
}
