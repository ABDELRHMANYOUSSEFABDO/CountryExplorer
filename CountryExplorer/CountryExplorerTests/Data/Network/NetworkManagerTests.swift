//
//  NetworkManagerTests.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import XCTest
import Combine
@testable import CountryExplorer

final class NetworkManagerTests: XCTestCase {

    var sut: NetworkManager!
    var mockClient: MockNetworkClient!
    var mockDataMapper: MockDataMapper!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockClient = MockNetworkClient()
        mockDataMapper = MockDataMapper()
        sut = NetworkManager(
            client: mockClient,
            dataMapper: mockDataMapper,
            responseMapper: CountryResponseMapper(),
            baseURL: "https://test.com"
        )
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        mockClient = nil
        mockDataMapper = nil
        cancellables = nil
        super.tearDown()
    }

    func testFetchAllCountriesSuccess_returnsMappedDomain() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch all countries")
        let json = NetworkTestHelpers.makeMockCountriesJSON()
        mockClient.setJSONResponse(json)

        // When
        sut.fetchAllCountries()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success, got \(error)")
                    }
                },
                receiveValue: { countries in
                    // Then
                    XCTAssertEqual(countries.count, 2)
                    XCTAssertEqual(countries[0].name, "Test Country")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockClient.requestedURLs.count, 1)
        XCTAssertTrue(mockClient.requestedURLs.first?.absoluteString.contains("/v2/all") ?? false)
    }

    func testSearchCountriesSuccess_buildsCorrectURL() {
        // Given
        let expectation = XCTestExpectation(description: "Search countries")
        let json = NetworkTestHelpers.makeMockCountriesJSON()
        mockClient.setJSONResponse(json)

        sut.searchCountries(query: "test")
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success, got \(error)")
                    }
                },
                receiveValue: { countries in
                    XCTAssertFalse(countries.isEmpty)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(mockClient.requestedURLs.first?.absoluteString.contains("/v2/name/test") ?? false)
    }

    func testFetchCountryByCodeSuccess_buildsCorrectURL() {
        let expectation = XCTestExpectation(description: "Fetch country by code")
        let json = NetworkTestHelpers.makeMockCountryJSON()
        mockClient.setJSONResponse(json)

        sut.fetchCountryByCode("TC")
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success, got \(error)")
                    }
                },
                receiveValue: { country in
                    XCTAssertEqual(country.name, "Test Country")
                    XCTAssertEqual(country.alpha2Code, "TC")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(mockClient.requestedURLs.first?.absoluteString.contains("/v2/alpha/TC") ?? false)
    }

    func testNetworkFailure_propagatesError() {
        // Given
        let expectation = XCTestExpectation(description: "Handle network failure")
        mockClient.shouldFail = true
        mockClient.errorToThrow = .noInternetConnection

        // When
        sut.fetchAllCountries()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTAssertEqual(error, NetworkError.noInternetConnection)
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail("Should not receive value on failure")
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
}
