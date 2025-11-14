//
//  CountrySearchService.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation

protocol CountrySearchServiceProtocol {
    func search(_ countries: [Country], query: String) -> [Country]
}

final class CountrySearchService: CountrySearchServiceProtocol {
    
   
    func search(_ countries: [Country], query: String) -> [Country] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedQuery.isEmpty else {
            return countries
        }
        
        return countries.filter { country in
            matchesCountry(country, query: trimmedQuery)
        }
    }
    
    
    private func matchesCountry(_ country: Country, query: String) -> Bool {
        if country.name.localizedCaseInsensitiveContains(query) {
            return true
        }
        
        if let nativeName = country.nativeName,
           nativeName.localizedCaseInsensitiveContains(query) {
            return true
        }
        
        if country.capital.localizedCaseInsensitiveContains(query) {
            return true
        }
        
        if country.alpha2Code.localizedCaseInsensitiveContains(query) ||
           country.alpha3Code.localizedCaseInsensitiveContains(query) {
            return true
        }
        
        if country.region.localizedCaseInsensitiveContains(query) {
            return true
        }
        
        if matchesCurrencies(country.currencies, query: query) {
            return true
        }
        
        if matchesLanguages(country.languages, query: query) {
            return true
        }
        
        return false
    }
    
    private func matchesCurrencies(_ currencies: [Currency], query: String) -> Bool {
        currencies.contains { currency in
            currency.code.localizedCaseInsensitiveContains(query) ||
            currency.name.localizedCaseInsensitiveContains(query) ||
            currency.symbol.localizedCaseInsensitiveContains(query)
        }
    }
    
    private func matchesLanguages(_ languages: [Language], query: String) -> Bool {
        languages.contains { language in
            language.name.localizedCaseInsensitiveContains(query) ||
            (language.nativeName?.localizedCaseInsensitiveContains(query) ?? false) ||
            (language.iso639_1?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }
}

