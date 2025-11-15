//
//  DataMapperTests.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import XCTest
@testable import CountryExplorer

final class DataMapperTests: XCTestCase {

    var sut: JSONDataMapper!

    override func setUp() {
        super.setUp()
        sut = JSONDataMapper()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testMapValidJSON_decodesCountryDTO() throws {
        let json = NetworkTestHelpers.makeMockCountryJSON()
        let data = json.data(using: .utf8)!

        let result = try sut.map(data, to: CountryDTO.self)

        XCTAssertEqual(result.name, "Test Country")
        XCTAssertEqual(result.capital, "Test Capital")
        XCTAssertEqual(result.alpha2Code, "TC")
    }

    func testMapInvalidJSON_throwsNetworkError() {
        let invalidJSON = "{ invalid json }"
        let data = invalidJSON.data(using: .utf8)!

        XCTAssertThrowsError(try sut.map(data, to: CountryDTO.self)) { error in
            XCTAssertTrue(error is NetworkError)
        }
    }

    func testMapArrayJSON_decodesCountriesArray() throws {
        let json = NetworkTestHelpers.makeMockCountriesJSON()
        let data = json.data(using: .utf8)!

        let result = try sut.map(data, to: [CountryDTO].self)

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].name, "Test Country")
        XCTAssertEqual(result[1].name, "Second Country")
    }
}
