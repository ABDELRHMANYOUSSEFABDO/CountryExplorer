//
//  NetworkError.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation

enum NetworkError: LocalizedError, Equatable {
    case invalidRequest
    case invalidResponse
    case noData
    case decodingFailed
    case serverError(statusCode: Int, message: String?)
    case unknown(message: String)

    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "Invalid network request."
        case .invalidResponse:
            return "Invalid server response."
        case .noData:
            return "No data received from server."
        case .decodingFailed:
            return "Failed to decode server response."
        case .serverError(let status, let message):
            return message ?? "Server error with status code: \(status)"
        case .unknown(let message):
            return message
        }
    }
}
