//
//  ResponseMapperTests.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import XCTest
@testable import CountryExplorer

final class ResponseMapperTests: XCTestCase {

    var sut: CountryResponseMapper!

    override func setUp() {
        super.setUp()
        sut = CountryResponseMapper()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testMapDTOToDomain_mapsAllImportantFields() {
        let dto = NetworkTestHelpers.makeMockCountryDTO()

        let domain = sut.mapToDomain(dto)

        XCTAssertEqual(domain.name, dto.name)
        XCTAssertEqual(domain.capital, dto.capital)
        XCTAssertEqual(domain.alpha2Code, dto.alpha2Code)
        XCTAssertEqual(domain.population, dto.population ?? 0)
        XCTAssertFalse(domain.currencies.isEmpty)
        XCTAssertEqual(domain.currencies.first?.code, "TCC")
    }

    func testMapDTOWithMissingFields_appliesDefaults() {
        let dto = CountryDTO(
            name: "Minimal Country",
            capital: nil,
            alpha2Code: "MC",
            alpha3Code: "MIN",
            flag: nil,
            region: nil,
            subregion: nil,
            population: nil,
            currencies: nil,
            languages: nil,
            timezones: nil,
            borders: nil,
            nativeName: nil,
            numericCode: nil,
            latlng: nil
        )

        let domain = sut.mapToDomain(dto)

        XCTAssertEqual(domain.name, "Minimal Country")
        XCTAssertEqual(domain.capital, "N/A")
        XCTAssertEqual(domain.population, 0)
        XCTAssertTrue(domain.currencies.isEmpty)
    }

    func testMapArrayDTOsToDomainArray() {
        // Given
        let dtos = [NetworkTestHelpers.makeMockCountryDTO(),
                    NetworkTestHelpers.makeMockCountryDTO()]

        // When
        let domains = sut.mapToDomain(dtos)

        // Then
        XCTAssertEqual(domains.count, 2)
        XCTAssertEqual(domains[0].name, "Test Country")
    }
}
