//
//  AppEnvironment.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation

enum AppEnvironment {
    case debug
    case production

    static var current: AppEnvironment {
        BuildConfiguration.isDebug ? .debug : .production
    }

    var loggingEnabled: Bool {
        switch self {
        case .debug:      return true
        case .production: return false    
        }
    }
    
    var cacheExpirationTime: TimeInterval {
        switch self {
        case .debug:
            return 300 // 5 minutes for debug
        case .production:
            return 3600 // 1 hour for production
        }
    }
    
    var maxCacheSize: Int {
        switch self {
        case .debug:
            return 50 * 1024 * 1024 // 50 MB
        case .production:
            return 100 * 1024 * 1024 // 100 MB
        }
    }
}
