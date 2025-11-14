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
}
