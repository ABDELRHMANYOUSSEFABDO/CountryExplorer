//
//  Untitled.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//



import Foundation

enum NetworkError: LocalizedError, Equatable {
    case invalidURL
    case noInternetConnection
    case timeout
    case cancelled
    
    case serverError(statusCode: Int, message: String?)
    
    case noData
    case decodingError(Error)
    case encodingError(Error)
    
    case unknown(message: String)
    
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .noInternetConnection:
            return "No internet connection. Please check your network settings."
        case .timeout:
            return "The request timed out. Please try again."
        case .cancelled:
            return "The request was cancelled."
        case .serverError(let statusCode, let message):
            return message ?? "Server error (\(statusCode))."
        case .noData:
            return "No data received from server."
        case .decodingError:
            return "Failed to decode server response."
        case .encodingError:
            return "Failed to encode request body."
        case .unknown(let message):
            return message
        }
    }
    
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.noInternetConnection, .noInternetConnection),
             (.timeout, .timeout),
             (.cancelled, .cancelled),
             (.noData, .noData):
            return true
            
        case let (.serverError(codeL, _), .serverError(codeR, _)):
            return codeL == codeR
            
        case (.decodingError, .decodingError),
             (.encodingError, .encodingError):
            return true
            
        case let (.unknown(msgL), .unknown(msgR)):
            return msgL == msgR
            
        default:
            return false
        }
    }
}
