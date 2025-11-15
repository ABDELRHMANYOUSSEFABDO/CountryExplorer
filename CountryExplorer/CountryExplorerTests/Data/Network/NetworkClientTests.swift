//
//  NetworkClientTests.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import XCTest
import Combine
@testable import CountryExplorer

final class NetworkClientTests: XCTestCase {

    var sut: MockNetworkClient!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        sut = MockNetworkClient()
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        cancellables = nil
        super.tearDown()
    }

    func testRequestSuccess_returnsDataAndTracksURL() {
        let expectation = XCTestExpectation(description: "Request succeeds")
        let testData = "Test Data".data(using: .utf8)!
        sut.dataToReturn = testData

        guard let url = URL(string: "https://test.com") else {
            XCTFail("Invalid URL")
            return
        }

        sut.request(url)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success, got error: \(error)")
                    }
                },
                receiveValue: { data in
                    XCTAssertEqual(data, testData)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.requestedURLs.count, 1)
        XCTAssertEqual(sut.requestedURLs.first?.absoluteString, "https://test.com")
    }

    func testRequestFailure_propagatesNetworkError() {
        let expectation = XCTestExpectation(description: "Request fails")
        sut.shouldFail = true
        sut.errorToThrow = .noInternetConnection

        guard let url = URL(string: "https://test.com") else {
            XCTFail("Invalid URL")
            return
        }

        sut.request(url)
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
