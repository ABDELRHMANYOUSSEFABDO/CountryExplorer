//
//  CountryEndpoint.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation

enum CountryEndpoint {
    case all
    case search(name: String)
    case byCode(code: String)
    
    private var path: String {
        switch self {
        case .all:
            return "/v2/all"
        case .search(let name):
            return "/v2/name/\(name)"
        case .byCode(let code):
            return "/v2/alpha/\(code)"
        }
    }
    
    
    func url(baseURL: String) -> URL? {
        guard var components = URLComponents(string: baseURL) else {
            return nil
        }
        
        let cleanPath = path.hasPrefix("/") ? path : "/\(path)"
        components.path = cleanPath
        
        if case .search(let name) = self {
            let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? name
            components.path = "/v2/name/\(encodedName)"
        }
        
        return components.url
    }
}
