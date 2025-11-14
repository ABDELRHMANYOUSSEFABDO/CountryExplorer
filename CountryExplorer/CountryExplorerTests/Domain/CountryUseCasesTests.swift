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
                currencies: [Currency(code: "EUR", name: "Euro", symbol: "€")]
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

        // نضيف 5 دول مبدئيًا
        repository.selected = (1...5).map {
            Country(
                name: "Country \($0)",
                capital: "Cap \($0)",
                alpha2Code: "C\($0)",
                alpha3Code: "C\($0)\($0)",
                region: "Test",
                population: 1_000,
                currencies: []
            )
        }

        let newCountry = Country(
            name: "Extra",
            capital: "ExtraCap",
            alpha2Code: "EX",
            alpha3Code: "EXT",
            region: "Test",
            population: 1_000,
            currencies: []
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
