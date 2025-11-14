//
//  CountryDTO.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation

struct CountryDTO: Decodable {
    let name: String
    let capital: String?
    let alpha2Code: String
    let alpha3Code: String
    let flag: String?
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
}
