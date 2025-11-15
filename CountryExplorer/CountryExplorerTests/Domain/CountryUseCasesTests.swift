//
//  CountryUseCasesTests.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import XCTest
import Combine
@testable import CountryExplorer

final class CountryUseCasesTests: XCTestCase {

    private var repository: MockCountryRepository!
    private var fetchAllUseCase: FetchAllCountriesUseCase!
    private var manageSelectedUseCase: ManageSelectedCountriesUseCase!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        repository = MockCountryRepository()
        repository.countries = [
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
                languages: [],
                timezones: ["UTC+01:00"],
                borders: ["BEL", "DEU"]
            )
        ]
        fetchAllUseCase = FetchAllCountriesUseCase(repository: repository)
        manageSelectedUseCase = ManageSelectedCountriesUseCase(repository: repository)
    }

    override func tearDown() {
        cancellables.removeAll()
        repository = nil
        fetchAllUseCase = nil
        manageSelectedUseCase = nil
        super.tearDown()
    }

    func testFetchAllCountries_returnsCountries() {
        let expectation = XCTestExpectation(description: "fetch all countries")

        fetchAllUseCase.execute()
            .sink { completion in
                if case .failure(let error) = completion {
                    XCTFail("Unexpected error \(error)")
                }
            } receiveValue: { countries in
                XCTAssertEqual(countries.count, 1)
                XCTAssertEqual(countries.first?.name, "France")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testManageSelectedCountries_respectsMaxLimit() {
        let expectation = XCTestExpectation(description: "cannot add more than 5")

        repository.selected = (1...5).map {
            Country(
                name: "Country \($0)",
                capital: "Cap \($0)",
                alpha2Code: "C\($0)",
                alpha3Code: "C\($0)\($0)",
                region: "Test",
                population: 1_000,
                currencies: [],
                flag: nil,
                nativeName: nil,
                languages: [],
                timezones: nil,
                borders: nil
            )
        }

        let newCountry = Country(
            name: "Extra",
            capital: "ExtraCap",
            alpha2Code: "EX",
            alpha3Code: "EXT",
            region: "Test",
            population: 1_000,
            currencies: [],
            flag: nil,
            nativeName: nil,
            languages: [],
            timezones: nil,
            borders: nil
        )

        manageSelectedUseCase.add(newCountry)
            .sink { completion in
                if case .failure(let error) = completion {
                    XCTAssertEqual(error as? ApplicationError, .maxCountriesReached)
                    expectation.fulfill()
                }
            } receiveValue: { _ in
                XCTFail("Should not allow adding more than 5 countries")
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Search Use Case Tests
extension CountryUseCasesTests {
    
    func testSearchCountries_withValidQuery_returnsMatchingCountries() {
        // Given
        let searchUseCase = SearchCountriesUseCase(repository: repository)
        let expectation = XCTestExpectation(description: "search countries")
        
        // When
        searchUseCase.execute(query: "France")
            .sink { completion in
                if case .failure(let error) = completion {
                    XCTFail("Unexpected error: \(error)")
                }
            } receiveValue: { countries in
                // Then
                XCTAssertEqual(countries.count, 1)
                XCTAssertEqual(countries.first?.name, "France")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchCountries_withEmptyQuery_returnsAllCountries() {
        let searchUseCase = SearchCountriesUseCase(repository: repository)
        let expectation = XCTestExpectation(description: "search with empty query")
        
        searchUseCase.execute(query: "")
            .sink { completion in
                if case .failure(let error) = completion {
                    XCTFail("Unexpected error: \(error)")
                }
            } receiveValue: { countries in
                // Then
                XCTAssertEqual(countries.count, 1)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchCountries_withNoResults_returnsEmptyArray() {
        // Given
        let searchUseCase = SearchCountriesUseCase(repository: repository)
        let expectation = XCTestExpectation(description: "search with no results")
        
        // When
        searchUseCase.execute(query: "NonExistentCountry")
            .sink { completion in
                if case .failure(let error) = completion {
                    XCTFail("Unexpected error: \(error)")
                }
            } receiveValue: { countries in
                // Then
                XCTAssertTrue(countries.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchCountries_caseInsensitive_findsResults() {
        // Given
        let searchUseCase = SearchCountriesUseCase(repository: repository)
        let expectation = XCTestExpectation(description: "case insensitive search")
        
        // When
        searchUseCase.execute(query: "fRaNcE")
            .sink { completion in
                if case .failure(let error) = completion {
                    XCTFail("Unexpected error: \(error)")
                }
            } receiveValue: { countries in
                // Then
                XCTAssertEqual(countries.count, 1)
                XCTAssertEqual(countries.first?.name, "France")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
}
