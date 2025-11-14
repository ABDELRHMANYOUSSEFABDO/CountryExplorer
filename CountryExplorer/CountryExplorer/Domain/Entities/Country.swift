//
//  Country.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation

struct Currency: Equatable, Hashable {
    let code: String
    let name: String
    let symbol: String
    
    var displayName: String {
        if symbol.isEmpty { return code }
        return "\(code) (\(symbol))"
    }
}

struct Language: Equatable, Hashable {
    let iso639_1: String?
    let name: String
    let nativeName: String?
    
    var displayName: String {
        nativeName ?? name
    }
}

struct Country: Identifiable, Equatable {
    var id: String { alpha3Code }
    
    let name: String
    let capital: String
    let alpha2Code: String
    let alpha3Code: String
    
    let region: String
    let population: Int
    
    let currencies: [Currency]
    let flag: String?
    let nativeName: String?
    let languages: [Language]
    let timezones: [String]?
    let borders: [String]?
    
    var mainCurrency: Currency? {
        currencies.first
    }
    
    var currencyDescription: String {
        guard let currency = mainCurrency else { return "N/A" }
        return currency.displayName
    }
    
    var primaryLanguage: Language? {
        languages.first
    }
    
    var languagesDescription: String {
        guard !languages.isEmpty else { return "N/A" }
        return languages.map { $0.displayName }.joined(separator: ", ")
    }
    
    // Validation
    var isValid: Bool {
        !name.isEmpty &&
        !alpha2Code.isEmpty &&
        !alpha3Code.isEmpty &&
        population >= 0
    }
}
