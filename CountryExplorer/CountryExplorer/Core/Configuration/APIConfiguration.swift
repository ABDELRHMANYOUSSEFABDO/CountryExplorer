//
//  APIConfiguration.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation

struct APIConfiguration {
    
    // MARK: - Properties
    let baseURL: String
    let apiVersion: String
    let timeout: TimeInterval
    
    // MARK: - Singleton
    static let shared: APIConfiguration = {
        let environment = AppEnvironment.current
        return APIConfiguration(environment: environment)
    }()
    
    // MARK: - Initialization
    private init(environment: AppEnvironment) {
        self.baseURL = Self.getBaseURL(for: environment)
        self.apiVersion = Self.getAPIVersion(for: environment)
        self.timeout = Self.getTimeout(for: environment)
    }
    
    // MARK: - Private Helpers
    
    private static func getBaseURL(for environment: AppEnvironment) -> String {
        // First, try to get from Info.plist for better security
        if let plistURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
           !plistURL.isEmpty {
            return plistURL
        }
        
        // Fallback to environment-based URLs
        switch environment {
        case .debug:
            return "https://restcountries.com"
        case .production:
            return "https://restcountries.com"
        }
    }
    
    private static func getAPIVersion(for environment: AppEnvironment) -> String {
        if let plistVersion = Bundle.main.object(forInfoDictionaryKey: "API_VERSION") as? String,
           !plistVersion.isEmpty {
            return plistVersion
        }
        
        return "v2"
    }
    
    private static func getTimeout(for environment: AppEnvironment) -> TimeInterval {
        switch environment {
        case .debug:
            return 30.0
        case .production:
            return 15.0
        }
    }
    
    // MARK: - Public API
    
    var fullBaseURL: String {
        return baseURL
    }
    
    var requestTimeout: TimeInterval {
        return timeout
    }
}

