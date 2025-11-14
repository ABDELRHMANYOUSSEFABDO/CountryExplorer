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


struct Country: Identifiable, Equatable {
    var id: String { alpha3Code }
    
    let name: String
    let capital: String
    let alpha2Code: String
    let alpha3Code: String
    
    let region: String
    let population: Int
    
    let currencies: [Currency]
    
    var mainCurrency: Currency? {
        currencies.first
    }
    
    var currencyDescription: String {
        guard let currency = mainCurrency else { return "N/A" }
        return currency.displayName
    }
}
