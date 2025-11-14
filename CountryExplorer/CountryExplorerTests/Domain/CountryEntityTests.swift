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
            currencies: [currency]
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
            currencies: []
        )
        
        XCTAssertEqual(country.currencyDescription, "N/A")
    }
}
