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
    
    
    func testSearch_withEmptyQuery_returnsAllCountries() {
        let results = sut.search(testCountries, query: "")
        
        XCTAssertEqual(results.count, 3)
    }
    
    func testSearch_withWhitespaceQuery_returnsAllCountries() {
        let results = sut.search(testCountries, query: "   ")
        
        XCTAssertEqual(results.count, 3)
    }
    
    func testSearch_withNoMatches_returnsEmptyArray() {
        let results = sut.search(testCountries, query: "NonExistentCountry")
        
        XCTAssertTrue(results.isEmpty)
    }
    
    
    func testSearch_byCountryName_findsMatch() {
        let results = sut.search(testCountries, query: "France")
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "France")
    }
    
    func testSearch_byNativeName_findsMatch() {
        let results = sut.search(testCountries, query: "Deutschland")
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Germany")
    }
    
    func testSearch_byArabicName_findsMatch() {
        let results = sut.search(testCountries, query: "مصر")
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Egypt")
    }
    
    func testSearch_caseInsensitive_findsMatch() {
        let results = sut.search(testCountries, query: "fRaNcE")
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "France")
    }
    
    
    func testSearch_byCapital_findsMatch() {
        let results = sut.search(testCountries, query: "Paris")
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.capital, "Paris")
    }
    
    func testSearch_byCapitalCaseInsensitive_findsMatch() {
        let results = sut.search(testCountries, query: "cairo")
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Egypt")
    }
    
    
    func testSearch_byAlpha2Code_findsMatch() {
        let results = sut.search(testCountries, query: "FR")
        
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.first?.alpha2Code, "FR")
    }
    
    func testSearch_byAlpha3Code_findsMatch() {
        let results = sut.search(testCountries, query: "DEU")
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.alpha3Code, "DEU")
    }
    
    
    func testSearch_byRegion_findsMultipleMatches() {
        let results = sut.search(testCountries, query: "Europe")
        
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.contains(where: { $0.name == "France" }))
        XCTAssertTrue(results.contains(where: { $0.name == "Germany" }))
    }
    
    
    func testSearch_byCurrencyCode_findsMatch() {
        let results = sut.search(testCountries, query: "EGP")
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Egypt")
    }
    
    func testSearch_byCurrencyName_findsMultipleMatches() {
        let results = sut.search(testCountries, query: "Euro")
        
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.contains(where: { $0.name == "France" }))
        XCTAssertTrue(results.contains(where: { $0.name == "Germany" }))
    }
    
    func testSearch_byCurrencySymbol_findsMatch() {
        let results = sut.search(testCountries, query: "€")
        
        XCTAssertEqual(results.count, 2)
    }
    
    
    func testSearch_byLanguageName_findsMatch() {
        let results = sut.search(testCountries, query: "French")
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "France")
    }
    
    func testSearch_byLanguageNativeName_findsMatch() {
        let results = sut.search(testCountries, query: "Deutsch")
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Germany")
    }
        
    
    func testSearch_withPartialMatch_findsResults() {
        let results = sut.search(testCountries, query: "Fra")
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "France")
    }
    
    func testSearch_withPartialCapitalMatch_findsResults() {
        let results = sut.search(testCountries, query: "Ber")
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Germany")
    }
}

