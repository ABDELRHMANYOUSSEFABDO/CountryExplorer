//
//  CountryDTO.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation

struct FlagsDTO: Decodable {
    let svg: String?
    let png: String?
}

struct CountryDTO: Decodable {
    let name: String
    let capital: String?
    let alpha2Code: String
    let alpha3Code: String
    let flag: String?
    let flags: FlagsDTO?
    let region: String?
    let subregion: String?
    let population: Int?
    let currencies: [CurrencyDTO]?
    let languages: [LanguageDTO]?
    let timezones: [String]?
    let borders: [String]?
    let nativeName: String?
    let numericCode: String?
    let latlng: [Double]?
    
    // Computed property to get PNG flag URL
    var flagURL: String? {
        // Priority: flags.png > flag (for backwards compatibility)
        return flags?.png ?? flag
    }
}
