//
//  CountryEntityTests.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import XCTest
@testable import CountryExplorer

final class CountryEntityTests: XCTestCase {

    func testCurrencyDescription_withSymbol_formatsCorrectly() {
        // Given
        let currency = Currency(code: "EUR", name: "Euro", symbol: "€")
        let country = Country(
            name: "France",
            capital: "Paris",
            alpha2Code: "FR",
            alpha3Code: "FRA",
            region: "Europe",
            population: 67_000_000,
            currencies: [currency],
            flag: "🇫🇷",
            nativeName: "France",
            languages: [],
            timezones: ["UTC+01:00"],
            borders: ["BEL", "DEU"]
        )
        
        // When
        let description = country.currencyDescription
        
        // Then
        XCTAssertEqual(description, "EUR (€)")
    }
    
    func testCurrencyDescription_withoutCurrency_returnsNA() {
        let country = Country(
            name: "NoCurrencyLand",
            capital: "Capital",
            alpha2Code: "NC",
            alpha3Code: "NCL",
            region: "Nowhere",
            population: 0,
            currencies: [],
            flag: nil,
            nativeName: nil,
            languages: [],
            timezones: nil,
            borders: nil
        )
        
        XCTAssertEqual(country.currencyDescription, "N/A")
    }
    
    func testLanguagesDescription_withMultipleLanguages_formatsCorrectly() {
        // Given
        let french = Language(iso639_1: "fr", name: "French", nativeName: "Français")
        let german = Language(iso639_1: "de", name: "German", nativeName: "Deutsch")
        let country = Country(
            name: "Switzerland",
            capital: "Bern",
            alpha2Code: "CH",
            alpha3Code: "CHE",
            region: "Europe",
            population: 8_500_000,
            currencies: [],
            flag: "🇨🇭",
            nativeName: "Schweiz",
            languages: [french, german],
            timezones: ["UTC+01:00"],
            borders: ["DEU", "FRA", "ITA"]
        )
        
        // When
        let description = country.languagesDescription
        
        // Then
        XCTAssertEqual(description, "Français, Deutsch")
    }
    
    func testValidation_withValidCountry_returnsTrue() {
        // Given
        let country = Country(
            name: "France",
            capital: "Paris",
            alpha2Code: "FR",
            alpha3Code: "FRA",
            region: "Europe",
            population: 67_000_000,
            currencies: [],
            flag: nil,
            nativeName: nil,
            languages: [],
            timezones: nil,
            borders: nil
        )
        
        // Then
        XCTAssertTrue(country.isValid)
    }
    
    func testValidation_withInvalidCountry_returnsFalse() {
        // Given - negative population
        let country = Country(
            name: "Invalid",
            capital: "Capital",
            alpha2Code: "IV",
            alpha3Code: "IVD",
            region: "Test",
            population: -100,
            currencies: [],
            flag: nil,
            nativeName: nil,
            languages: [],
            timezones: nil,
            borders: nil
        )
        
        // Then
        XCTAssertFalse(country.isValid)
    }
}
