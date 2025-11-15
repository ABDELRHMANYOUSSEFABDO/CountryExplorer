//
//  CountryListViewModelTests.swift
//  CountryExplorerTests
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import XCTest
import Combine
@testable import CountryExplorer

final class CountryListViewModelTests: XCTestCase {
    
    var sut: CountryListViewModel!
    var mockFetchUseCase: MockFetchAllCountriesUseCase!
    var mockSearchUseCase: MockSearchCountriesUseCase!
    var mockCoordinator: MockCountryFlowCoordinator!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockFetchUseCase = MockFetchAllCountriesUseCase()
        mockSearchUseCase = MockSearchCountriesUseCase()
        mockCoordinator = MockCountryFlowCoordinator()
        cancellables = Set<AnyCancellable>()
        
        sut = CountryListViewModel(
            fetchAllUseCase: mockFetchUseCase,
            searchUseCase: mockSearchUseCase,
            coordinator: mockCoordinator
        )
    }
    
    override func tearDown() {
        sut = nil
        mockFetchUseCase = nil
        mockSearchUseCase = nil
        mockCoordinator = nil
        cancellables = nil
        super.tearDown()
    }
    
    
    func testInitialState_ShouldBeIdle() {
        
        if case .idle = sut.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("Initial state should be idle")
        }
    }
    
    func testSearchQuery_InitialValue_ShouldBeEmpty() {
        XCTAssertEqual(sut.searchQuery, "")
    }
    
    
    func testOnAppear_WhenIdleState_ShouldFetchCountries() {
        let mockCountries = [
            Country.mock(name: "Egypt", alpha3Code: "EGY"),
            Country.mock(name: "USA", alpha3Code: "USA")
        ]
        mockFetchUseCase.result = .success(mockCountries)
        
        let expectation = expectation(description: "Fetch countries")
        var states: [ViewState<[CountryRowViewModel]>] = []
        
        sut.$state
            .sink { state in
                states.append(state)
                if case .content = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.onAppear()
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(states.count, 3)
        
        if case .loading = states[1] {
            XCTAssertTrue(true)
        } else {
            XCTFail("Second state should be loading")
        }
        
        if case .content(let rows) = states[2] {
            XCTAssertEqual(rows.count, 2)
            XCTAssertEqual(rows[0].name, "Egypt")
            XCTAssertEqual(rows[1].name, "USA")
        } else {
            XCTFail("Third state should be content")
        }
    }
    
    func testOnAppear_WhenAlreadyLoaded_ShouldNotFetchAgain() {
        let mockCountries = [Country.mock(name: "Egypt", alpha3Code: "EGY")]
        mockFetchUseCase.result = .success(mockCountries)
        
        sut.onAppear()
        
        let firstExpectation = expectation(description: "First load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            firstExpectation.fulfill()
        }
        wait(for: [firstExpectation], timeout: 1.0)
        
        let callCountBeforeSecondAppear = mockFetchUseCase.executeCallCount
        
        sut.onAppear()
        
        XCTAssertEqual(mockFetchUseCase.executeCallCount, callCountBeforeSecondAppear,
                      "Should not fetch again when state is not idle")
    }
    
    func testOnAppear_WhenFetchFails_ShouldShowError() {
        mockFetchUseCase.result = .failure(.networkError(.serverError(statusCode: 500, message: nil)))
        
        let expectation = expectation(description: "Error state")
        var errorMessage: String?
        
        sut.$state
            .sink { state in
                if case .error(let message) = state {
                    errorMessage = message
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.onAppear()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(errorMessage)
    }
    
    
    func testSearch_WithValidQuery_ShouldShowResults() {
        let mockResults = [Country.mock(name: "Egypt", alpha3Code: "EGY")]
        mockSearchUseCase.result = .success(mockResults)
        
        let expectation = expectation(description: "Search results")
        var contentReceived = false
        
        sut.$state
            .dropFirst()
            .sink { state in
                if case .content(let rows) = state {
                    contentReceived = true
                    XCTAssertEqual(rows.count, 1)
                    XCTAssertEqual(rows.first?.name, "Egypt")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.searchQuery = "Egypt"
        
        wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(contentReceived)
    }
    
    func testSearch_WithEmptyQuery_ShouldShowAllCountries() {
        let allCountries = [
            Country.mock(name: "Egypt", alpha3Code: "EGY"),
            Country.mock(name: "USA", alpha3Code: "USA")
        ]
        mockFetchUseCase.result = .success(allCountries)
        
        sut.onAppear()
        
        let expectation = expectation(description: "Show all countries")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.sut.searchQuery = ""
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Then
                if case .content(let rows) = self.sut.state {
                    XCTAssertEqual(rows.count, 2)
                    expectation.fulfill()
                } else {
                    XCTFail("Should show content state with all countries")
                }
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testSearch_IsDebounced() {
        mockSearchUseCase.result = .success([])
        
        sut.searchQuery = "E"
        sut.searchQuery = "Eg"
        sut.searchQuery = "Egy"
        sut.searchQuery = "Egyp"
        sut.searchQuery = "Egypt"
        
        let expectation = expectation(description: "Debounce")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        // Then - Should only call search once (debounced)
        XCTAssertEqual(mockSearchUseCase.executeCallCount, 1,
                      "Search should be debounced")
    }
    
    
    func testDidSelectCountry_WithValidId_ShouldNavigateToDetails() {
        // Given
        let mockCountries = [
            Country.mock(name: "Egypt", alpha3Code: "EGY"),
            Country.mock(name: "USA", alpha3Code: "USA")
        ]
        mockFetchUseCase.result = .success(mockCountries)
        
        sut.onAppear()
        
        let expectation = expectation(description: "Load countries")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        sut.didSelectCountry(id: "EGY")
        
        XCTAssertEqual(mockCoordinator.lastShowDetailCountry?.alpha3Code, "EGY")
        XCTAssertEqual(mockCoordinator.lastShowDetailCountry?.name, "Egypt")
    }
    
    func testDidSelectCountry_WithInvalidId_ShouldNotNavigate() {
        let mockCountries = [Country.mock(name: "Egypt", alpha3Code: "EGY")]
        mockFetchUseCase.result = .success(mockCountries)
        
        sut.onAppear()
        
        let expectation = expectation(description: "Load countries")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        sut.didSelectCountry(id: "INVALID")
        
        XCTAssertNil(mockCoordinator.lastShowDetailCountry)
    }
    
    
    func testCountryRowViewModel_ShouldMapAllProperties() {
        let country = Country.mock(
            name: "Egypt",
            capital: "Cairo",
            alpha2Code: "EG",
            alpha3Code: "EGY",
            region: "Africa",
            population: 100_000_000
        )
        
        let viewModel = CountryRowViewModel(country: country)
        
        XCTAssertEqual(viewModel.name, "Egypt")
        XCTAssertEqual(viewModel.capital, "Cairo")
        XCTAssertEqual(viewModel.region, "Africa")
        XCTAssertEqual(viewModel.populationText, "100.0M")
        XCTAssertEqual(viewModel.currencyText, "EGP (£)")
        XCTAssertEqual(viewModel.flagURL, "https://flagcdn.com/w320/eg.png")
    }
    
    func testCountryRowViewModel_FlagURLGeneration() {
        let testCases: [(alpha2Code: String, expectedURL: String)] = [
            ("EG", "https://flagcdn.com/w320/eg.png"),
            ("US", "https://flagcdn.com/w320/us.png"),
            ("GB", "https://flagcdn.com/w320/gb.png"),
            ("SA", "https://flagcdn.com/w320/sa.png")
        ]
        
        for testCase in testCases {
            let country = Country.mock(alpha2Code: testCase.alpha2Code)
            let viewModel = CountryRowViewModel(country: country)
            
            XCTAssertEqual(viewModel.flagURL, testCase.expectedURL,
                          "Flag URL for \(testCase.alpha2Code) should be \(testCase.expectedURL)")
        }
    }
    
    func testCountryRowViewModel_PopulationFormatting() {
        let testCases: [(population: Int, expected: String)] = [
            (0, "N/A"),
            (500, "500"),
            (1_500, "1.5k"),
            (50_000, "50.0k"),
            (1_500_000, "1.5M"),
            (100_000_000, "100.0M")
        ]
        
        for testCase in testCases {
            let country = Country.mock(population: testCase.population)
            
            let viewModel = CountryRowViewModel(country: country)
            
            XCTAssertEqual(viewModel.populationText, testCase.expected,
                          "Population \(testCase.population) should format to \(testCase.expected)")
        }
    }
    
    
    func testRefresh_ShouldReloadCountries() async {
        let initialCountries = [Country.mock(name: "Egypt", alpha3Code: "EGY")]
        mockFetchUseCase.result = .success(initialCountries)
        
        sut.onAppear()
        
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        let updatedCountries = [
            Country.mock(name: "Egypt", alpha3Code: "EGY"),
            Country.mock(name: "USA", alpha3Code: "USA")
        ]
        mockFetchUseCase.result = .success(updatedCountries)
        
        // When
        await sut.refresh()
        
        // Then
        if case .content(let rows) = sut.state {
            XCTAssertEqual(rows.count, 2)
        } else {
            XCTFail("Should have content after refresh")
        }
    }
}


final class MockFetchAllCountriesUseCase: FetchAllCountriesUseCaseProtocol {
    var executeCallCount = 0
    var result: Result<[Country], ApplicationError> = .success([])
    
    func execute() -> CountryDomainPublisher<[Country]> {
        executeCallCount += 1
        return result.publisher.eraseToAnyPublisher()
    }
}

final class MockSearchCountriesUseCase: SearchCountriesUseCaseProtocol {
    var executeCallCount = 0
    var result: Result<[Country], ApplicationError> = .success([])
    
    func execute(query: String) -> CountryDomainPublisher<[Country]> {
        executeCallCount += 1
        return result.publisher.eraseToAnyPublisher()
    }
}

final class MockCountryFlowCoordinator: CountryFlowCoordinating {
    var lastShowDetailCountry: Country?
    
    func showCountryDetails(_ country: Country) {
        lastShowDetailCountry = country
    }
}


extension Country {
    static func mock(
        name: String = "Egypt",
        capital: String = "Cairo",
        alpha2Code: String = "EG",
        alpha3Code: String = "EGY",
        region: String = "Africa",
        population: Int = 100_000_000,
        flag: String? = "https://flagcdn.com/w320/eg.png"
    ) -> Country {
        Country(
            name: name,
            capital: capital,
            alpha2Code: alpha2Code,
            alpha3Code: alpha3Code,
            region: region,
            population: population,
            currencies: [Currency(code: "EGP", name: "Egyptian Pound", symbol: "£")],
            flag: flag,
            nativeName: name,
            languages: [Language(iso639_1: "ar", name: "Arabic", nativeName: "العربية")],
            timezones: ["UTC+02:00"],
            borders: []
        )
    }
}

