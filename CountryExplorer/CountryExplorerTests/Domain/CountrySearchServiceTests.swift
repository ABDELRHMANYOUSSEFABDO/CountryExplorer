//
//  CountrySearchServiceTests.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import XCTest
@testable import CountryExplorer

final class CountrySearchServiceTests: XCTestCase {
    
    var sut: CountrySearchService!
    var testCountries: [Country]!
    
    override func setUp() {
        super.setUp()
        sut = CountrySearchService()
        
        testCountries = [
            Country(
                name: "France",
                capital: "Paris",
                alpha2Code: "FR",
                alpha3Code: "FRA",
                region: "Europe",
                population: 67_000_000,
                currencies: [Currency(code: "EUR", name: "Euro", symbol: "€")],
                flag: "🇫🇷",
                nativeName: "France",
                languages: [Language(iso639_1: "fr", name: "French", nativeName: "Français")],
                timezones: ["UTC+01:00"],
                borders: ["BEL", "DEU"]
            ),
            Country(
                name: "Germany",
                capital: "Berlin",
                alpha2Code: "DE",
                alpha3Code: "DEU",
                region: "Europe",
                population: 83_000_000,
                currencies: [Currency(code: "EUR", name: "Euro", symbol: "€")],
                flag: "🇩🇪",
                nativeName: "Deutschland",
                languages: [Language(iso639_1: "de", name: "German", nativeName: "Deutsch")],
                timezones: ["UTC+01:00"],
                borders: ["FRA", "POL"]
            ),
            Country(
                name: "Egypt",
                capital: "Cairo",
                alpha2Code: "EG",
                alpha3Code: "EGY",
                region: "Africa",
                population: 100_000_000,
                currencies: [Currency(code: "EGP", name: "Egyptian Pound", symbol: "£")],
                flag: "🇪🇬",
                nativeName: "مصر",
                languages: [Language(iso639_1: "ar", name: "Arabic", nativeName: "العربية")],
                timezones: ["UTC+02:00"],
                borders: ["ISR", "SDN"]
            )
        ]
    }
    
    override func tearDown() {
        sut = nil
        testCountries = nil
        super.tearDown()
    }
    
    // MARK: - Basic Search Tests
    
    func testSearch_withEmptyQuery_returnsAllCountries() {
        // When
        let results = sut.search(testCountries, query: "")
        
        // Then
        XCTAssertEqual(results.count, 3)
    }
    
    func testSearch_withWhitespaceQuery_returnsAllCountries() {
        // When
        let results = sut.search(testCountries, query: "   ")
        
        // Then
        XCTAssertEqual(results.count, 3)
    }
    
    func testSearch_withNoMatches_returnsEmptyArray() {
        // When
        let results = sut.search(testCountries, query: "NonExistentCountry")
        
        // Then
        XCTAssertTrue(results.isEmpty)
    }
    
    // MARK: - Name Search Tests
    
    func testSearch_byCountryName_findsMatch() {
        // When
        let results = sut.search(testCountries, query: "France")
        
        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "France")
    }
    
    func testSearch_byNativeName_findsMatch() {
        // When
        let results = sut.search(testCountries, query: "Deutschland")
        
        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Germany")
    }
    
    func testSearch_byArabicName_findsMatch() {
        // When
        let results = sut.search(testCountries, query: "مصر")
        
        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Egypt")
    }
    
    func testSearch_caseInsensitive_findsMatch() {
        // When
        let results = sut.search(testCountries, query: "fRaNcE")
        
        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "France")
    }
    
    // MARK: - Capital Search Tests
    
    func testSearch_byCapital_findsMatch() {
        // When
        let results = sut.search(testCountries, query: "Paris")
        
        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.capital, "Paris")
    }
    
    func testSearch_byCapitalCaseInsensitive_findsMatch() {
        // When
        let results = sut.search(testCountries, query: "cairo")
        
        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Egypt")
    }
    
    // MARK: - Code Search Tests
    
    func testSearch_byAlpha2Code_findsMatch() {
        // When
        let results = sut.search(testCountries, query: "FR")
        
        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.alpha2Code, "FR")
    }
    
    func testSearch_byAlpha3Code_findsMatch() {
        // When
        let results = sut.search(testCountries, query: "DEU")
        
        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.alpha3Code, "DEU")
    }
    
    // MARK: - Region Search Tests
    
    func testSearch_byRegion_findsMultipleMatches() {
        // When
        let results = sut.search(testCountries, query: "Europe")
        
        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.contains(where: { $0.name == "France" }))
        XCTAssertTrue(results.contains(where: { $0.name == "Germany" }))
    }
    
    // MARK: - Currency Search Tests
    
    func testSearch_byCurrencyCode_findsMatch() {
        // When
        let results = sut.search(testCountries, query: "EGP")
        
        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Egypt")
    }
    
    func testSearch_byCurrencyName_findsMultipleMatches() {
        // When
        let results = sut.search(testCountries, query: "Euro")
        
        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.contains(where: { $0.name == "France" }))
        XCTAssertTrue(results.contains(where: { $0.name == "Germany" }))
    }
    
    func testSearch_byCurrencySymbol_findsMatch() {
        // When
        let results = sut.search(testCountries, query: "€")
        
        // Then
        XCTAssertEqual(results.count, 2)
    }
    
    // MARK: - Language Search Tests
    
    func testSearch_byLanguageName_findsMatch() {
        // When
        let results = sut.search(testCountries, query: "French")
        
        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "France")
    }
    
    func testSearch_byLanguageNativeName_findsMatch() {
        // When
        let results = sut.search(testCountries, query: "Deutsch")
        
        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Germany")
    }
    
    func testSearch_byLanguageCode_findsMatch() {
        // When
        let results = sut.search(testCountries, query: "ar")
        
        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Egypt")
    }
    
    // MARK: - Partial Match Tests
    
    func testSearch_withPartialMatch_findsResults() {
        // When
        let results = sut.search(testCountries, query: "Fra")
        
        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "France")
    }
    
    func testSearch_withPartialCapitalMatch_findsResults() {
        // When
        let results = sut.search(testCountries, query: "Ber")
        
        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Germany")
    }
}

