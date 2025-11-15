//
//  CountryDetailsViewModelTests.swift
//  CountryExplorerTests
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import XCTest
import Combine
@testable import CountryExplorer

final class CountryDetailsViewModelTests: XCTestCase {
    
    var sut: CountryDetailsViewModel!
    var mockCountry: Country!
    
    override func setUp() {
        super.setUp()
        mockCountry = Country.mock(
            name: "Egypt",
            capital: "Cairo",
            alpha2Code: "EG",
            alpha3Code: "EGY",
            region: "Africa",
            population: 100_000_000
        )
        sut = CountryDetailsViewModel(country: mockCountry)
    }
    
    override func tearDown() {
        sut = nil
        mockCountry = nil
        super.tearDown()
    }
    
    
    func testInit_ShouldSetCountryCorrectly() {
        // Then
        XCTAssertEqual(sut.country.name, "Egypt")
        XCTAssertEqual(sut.country.capital, "Cairo")
        XCTAssertEqual(sut.country.alpha2Code, "EG")
        XCTAssertEqual(sut.country.alpha3Code, "EGY")
        XCTAssertEqual(sut.country.region, "Africa")
        XCTAssertEqual(sut.country.population, 100_000_000)
    }
    
    func testCountry_ShouldBePublished() {
        var receivedCountries: [Country] = []
        let cancellable = sut.$country
            .sink { country in
                receivedCountries.append(country)
            }
        
        XCTAssertEqual(receivedCountries.count, 1)
        XCTAssertEqual(receivedCountries.first?.name, "Egypt")
        
        cancellable.cancel()
    }
    
    
    func testCountry_CurrencyDescription_ShouldBeFormatted() {
        let country = Country(
            name: "USA",
            capital: "Washington",
            alpha2Code: "US",
            alpha3Code: "USA",
            region: "Americas",
            population: 330_000_000,
            currencies: [Currency(code: "USD", name: "US Dollar", symbol: "$")],
            flag: nil,
            nativeName: "United States",
            languages: [Language(iso639_1: "en", name: "English", nativeName: "English")],
            timezones: nil,
            borders: nil
        )
        
        let viewModel = CountryDetailsViewModel(country: country)
        
        XCTAssertEqual(viewModel.country.currencyDescription, "USD ($)")
    }
    
    func testCountry_LanguagesDescription_ShouldBeFormatted() {
        let country = Country(
            name: "Belgium",
            capital: "Brussels",
            alpha2Code: "BE",
            alpha3Code: "BEL",
            region: "Europe",
            population: 11_500_000,
            currencies: [Currency(code: "EUR", name: "Euro", symbol: "€")],
            flag: nil,
            nativeName: "België",
            languages: [
                Language(iso639_1: "nl", name: "Dutch", nativeName: "Nederlands"),
                Language(iso639_1: "fr", name: "French", nativeName: "Français"),
                Language(iso639_1: "de", name: "German", nativeName: "Deutsch")
            ],
            timezones: nil,
            borders: nil
        )
        
        let viewModel = CountryDetailsViewModel(country: country)
        
        XCTAssertEqual(viewModel.country.languagesDescription, "Nederlands, Français, Deutsch")
    }
    
    func testCountry_WithNoCurrency_ShouldShowNA() {
        let country = Country(
            name: "Test Country",
            capital: "Test Capital",
            alpha2Code: "TC",
            alpha3Code: "TST",
            region: "Test Region",
            population: 1000,
            currencies: [],
            flag: nil,
            nativeName: nil,
            languages: [],
            timezones: nil,
            borders: nil
        )
        
        let viewModel = CountryDetailsViewModel(country: country)
        
        XCTAssertEqual(viewModel.country.currencyDescription, "N/A")
    }
    
    func testCountry_WithNoLanguages_ShouldShowNA() {
        let country = Country(
            name: "Test Country",
            capital: "Test Capital",
            alpha2Code: "TC",
            alpha3Code: "TST",
            region: "Test Region",
            population: 1000,
            currencies: [],
            flag: nil,
            nativeName: nil,
            languages: [],
            timezones: nil,
            borders: nil
        )
        
        let viewModel = CountryDetailsViewModel(country: country)
        
        XCTAssertEqual(viewModel.country.languagesDescription, "N/A")
    }
    
    
    func testCountry_WithValidData_ShouldBeValid() {
        XCTAssertTrue(sut.country.isValid)
    }
    
    func testCountry_WithEmptyName_ShouldBeInvalid() {
        let invalidCountry = Country(
            name: "",
            capital: "Cairo",
            alpha2Code: "EG",
            alpha3Code: "EGY",
            region: "Africa",
            population: 100_000_000,
            currencies: [],
            flag: nil,
            nativeName: nil,
            languages: [],
            timezones: nil,
            borders: nil
        )
        
        let viewModel = CountryDetailsViewModel(country: invalidCountry)
        
        XCTAssertFalse(viewModel.country.isValid)
    }
    
    func testCountry_WithNegativePopulation_ShouldBeInvalid() {
        let invalidCountry = Country(
            name: "Test",
            capital: "Test",
            alpha2Code: "TS",
            alpha3Code: "TST",
            region: "Test",
            population: -1,
            currencies: [],
            flag: nil,
            nativeName: nil,
            languages: [],
            timezones: nil,
            borders: nil
        )
        
        let viewModel = CountryDetailsViewModel(country: invalidCountry)
        
        XCTAssertFalse(viewModel.country.isValid)
    }
}


