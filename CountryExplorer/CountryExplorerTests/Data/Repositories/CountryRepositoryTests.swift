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
            localDataSource: mockLocal
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
                    currencies: [])
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
                    currencies: [])
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
}
