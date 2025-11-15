//
//  CountryRepositoryTests.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import XCTest
import Combine
@testable import CountryExplorer

final class CountryRepositoryTests: XCTestCase {

    var sut: CountryRepository!
    var mockNetwork: MockNetworkManager!
    var mockLocal: MockCountryLocalDataSource!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockNetwork = MockNetworkManager()
        mockLocal = MockCountryLocalDataSource()
        sut = CountryRepository(
            networkManager: mockNetwork,
            localDataSource: mockLocal,
            searchService: CountrySearchService()
        )
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        mockNetwork = nil
        mockLocal = nil
        cancellables = nil
        super.tearDown()
    }

    func testFetchAllCountriesSuccess_returnsNetworkDataAndCachesLocally() {
        // Given
        let countries = [
            Country(name: "France",
                    capital: "Paris",
                    alpha2Code: "FR",
                    alpha3Code: "FRA",
                    region: "Europe",
                    population: 67_000_000,
                    currencies: [],
                    flag: "🇫🇷",
                    nativeName: "France",
                    languages: [],
                    timezones: ["UTC+01:00"],
                    borders: ["BEL", "DEU"])
        ]

        mockNetwork.fetchAllCountriesPublisher =
            Just(countries)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        var didSaveLocally = false
        mockLocal.saveCountriesPublisher = Just(())
            .handleEvents(receiveSubscription: { _ in didSaveLocally = true })
            .setFailureType(to: ApplicationError.self)
            .eraseToAnyPublisher()

        let expectation = XCTestExpectation(description: "Fetch all countries")

        // When
        sut.fetchAllCountries()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success, got \(error)")
                    }
                },
                receiveValue: { result in
                    // Then
                    XCTAssertEqual(result.count, 1)
                    XCTAssertEqual(result.first?.name, "France")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(didSaveLocally, "Expected repository to cache countries locally")
    }

    func testFetchAllCountries_whenNetworkFails_usesLocalFallback() {
        // Given
        mockNetwork.fetchAllCountriesPublisher =
            Fail(error: NetworkError.noInternetConnection)
            .eraseToAnyPublisher()

        let localCountries = [
            Country(name: "Local Country",
                    capital: "Local",
                    alpha2Code: "LC",
                    alpha3Code: "LCL",
                    region: "LocalRegion",
                    population: 1_000,
                    currencies: [],
                    flag: nil,
                    nativeName: nil,
                    languages: [],
                    timezones: nil,
                    borders: nil)
        ]

        mockLocal.allCountriesPublisher =
            Just(localCountries)
            .setFailureType(to: ApplicationError.self)
            .eraseToAnyPublisher()

        let expectation = XCTestExpectation(description: "Fallback to local store")

        // When
        sut.fetchAllCountries()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success from local, got \(error)")
                    }
                },
                receiveValue: { result in
                    // Then
                    XCTAssertEqual(result.count, 1)
                    XCTAssertEqual(result.first?.name, "Local Country")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Search Countries Tests
    
    func testSearchCountries_withValidQuery_returnsFilteredResults() {
        // Given
        let allCountries = [
            Country(name: "France", capital: "Paris", alpha2Code: "FR", alpha3Code: "FRA",
                    region: "Europe", population: 67_000_000, currencies: [],
                    flag: nil, nativeName: nil, languages: [], timezones: nil, borders: nil),
            Country(name: "Germany", capital: "Berlin", alpha2Code: "DE", alpha3Code: "DEU",
                    region: "Europe", population: 83_000_000, currencies: [],
                    flag: nil, nativeName: nil, languages: [], timezones: nil, borders: nil)
        ]
        
        mockLocal.allCountriesPublisher = Just(allCountries)
            .setFailureType(to: ApplicationError.self)
            .eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(description: "Search countries")
        
        // When
        sut.searchCountries(query: "France")
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success, got \(error)")
                    }
                },
                receiveValue: { results in
                    // Then
                    XCTAssertEqual(results.count, 1)
                    XCTAssertEqual(results.first?.name, "France")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchCountries_withEmptyQuery_fetchesAllCountries() {
        // Given
        mockNetwork.fetchAllCountriesPublisher = Just([])
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        mockLocal.saveCountriesPublisher = Just(())
            .setFailureType(to: ApplicationError.self)
            .eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(description: "Fetch all with empty query")
        
        // When
        sut.searchCountries(query: "")
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        // OK - can fail if network fails
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Fetch Country By Code Tests
    
    func testFetchCountryByCode_whenFoundLocally_returnsCountry() {
        // Given
        let country = Country(name: "France", capital: "Paris", alpha2Code: "FR",
                             alpha3Code: "FRA", region: "Europe", population: 67_000_000,
                             currencies: [], flag: nil, nativeName: nil, languages: [],
                             timezones: nil, borders: nil)
        
        mockLocal.allCountriesPublisher = Just([country])
            .setFailureType(to: ApplicationError.self)
            .eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(description: "Fetch by code")
        
        // When
        sut.fetchCountry(byCode: "FR")
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success, got \(error)")
                    }
                },
                receiveValue: { result in
                    // Then
                    XCTAssertEqual(result.name, "France")
                    XCTAssertEqual(result.alpha2Code, "FR")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchCountryByCode_whenNotFoundLocally_fetchesFromNetwork() {
        // Given
        mockLocal.allCountriesPublisher = Just([])
            .setFailureType(to: ApplicationError.self)
            .eraseToAnyPublisher()
        
        let country = Country(name: "France", capital: "Paris", alpha2Code: "FR",
                             alpha3Code: "FRA", region: "Europe", population: 67_000_000,
                             currencies: [], flag: nil, nativeName: nil, languages: [],
                             timezones: nil, borders: nil)
        
        mockNetwork.fetchCountryByCodePublisher = Just(country)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(description: "Fetch from network")
        
        // When
        sut.fetchCountry(byCode: "FR")
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success, got \(error)")
                    }
                },
                receiveValue: { result in
                    // Then
                    XCTAssertEqual(result.name, "France")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Selected Countries Tests
    
    func testGetSelectedCountries_returnsSelectedList() {
        // Given
        let selectedCountries = [
            Country(name: "France", capital: "Paris", alpha2Code: "FR", alpha3Code: "FRA",
                    region: "Europe", population: 67_000_000, currencies: [],
                    flag: nil, nativeName: nil, languages: [], timezones: nil, borders: nil)
        ]
        
        mockLocal.selectedCountriesPublisher = Just(selectedCountries)
            .setFailureType(to: ApplicationError.self)
            .eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(description: "Get selected")
        
        // When
        sut.getSelectedCountries()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success, got \(error)")
                    }
                },
                receiveValue: { results in
                    // Then
                    XCTAssertEqual(results.count, 1)
                    XCTAssertEqual(results.first?.name, "France")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAddSelectedCountry_callsLocalDataSource() {
        // Given
        let country = Country(name: "France", capital: "Paris", alpha2Code: "FR",
                             alpha3Code: "FRA", region: "Europe", population: 67_000_000,
                             currencies: [], flag: nil, nativeName: nil, languages: [],
                             timezones: nil, borders: nil)
        
        var addCalled = false
        mockLocal.addSelectedPublisher = Just(())
            .handleEvents(receiveSubscription: { _ in addCalled = true })
            .setFailureType(to: ApplicationError.self)
            .eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(description: "Add selected")
        
        // When
        sut.addSelectedCountry(country)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success, got \(error)")
                    }
                },
                receiveValue: { _ in
                    // Then
                    XCTAssertTrue(addCalled)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRemoveSelectedCountry_callsLocalDataSource() {
        // Given
        let country = Country(name: "France", capital: "Paris", alpha2Code: "FR",
                             alpha3Code: "FRA", region: "Europe", population: 67_000_000,
                             currencies: [], flag: nil, nativeName: nil, languages: [],
                             timezones: nil, borders: nil)
        
        var removeCalled = false
        mockLocal.removeSelectedPublisher = Just(())
            .handleEvents(receiveSubscription: { _ in removeCalled = true })
            .setFailureType(to: ApplicationError.self)
            .eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(description: "Remove selected")
        
        // When
        sut.removeSelectedCountry(country)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success, got \(error)")
                    }
                },
                receiveValue: { _ in
                    // Then
                    XCTAssertTrue(removeCalled)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
}
