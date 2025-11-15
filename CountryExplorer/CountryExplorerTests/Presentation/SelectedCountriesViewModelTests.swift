//
//  SelectedCountriesViewModelTests.swift
//  CountryExplorerTests
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import XCTest
import Combine
@testable import CountryExplorer

final class SelectedCountriesViewModelTests: XCTestCase {
    
    var sut: SelectedCountriesViewModel!
    var mockManageUseCase: MockManageSelectedCountriesUseCase!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockManageUseCase = MockManageSelectedCountriesUseCase()
        cancellables = Set<AnyCancellable>()
        
        sut = SelectedCountriesViewModel(manageSelectedUseCase: mockManageUseCase)
    }
    
    override func tearDown() {
        sut = nil
        mockManageUseCase = nil
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
    
    
    func testOnAppear_ShouldLoadSelectedCountries() {

        let mockCountries = [
            Country.mock(name: "Egypt", alpha3Code: "EGY"),
            Country.mock(name: "USA", alpha3Code: "USA")
        ]
        mockManageUseCase.getSelectedResult = .success(mockCountries)
        
        let expectation = expectation(description: "Load selected countries")
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
        
        XCTAssertEqual(mockManageUseCase.getSelectedCallCount, 1)
    }
    
    func testOnAppear_WhenNoSelectedCountries_ShouldShowEmptyContent() {
        mockManageUseCase.getSelectedResult = .success([])
        
        let expectation = expectation(description: "Empty content")
        
        sut.$state
            .sink { state in
                if case .content(let rows) = state, rows.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.onAppear()
        
        wait(for: [expectation], timeout: 1.0)
        
        if case .content(let rows) = sut.state {
            XCTAssertTrue(rows.isEmpty)
        } else {
            XCTFail("Should show empty content")
        }
    }
    
    func testOnAppear_WhenLoadFails_ShouldShowError() {
        mockManageUseCase.getSelectedResult = .failure(.databaseError("Failed to load"))
        
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
    
    
    func testDidRemoveCountry_WithValidId_ShouldRemoveAndReload() {
        let egypt = Country.mock(name: "Egypt", alpha3Code: "EGY")
        let usa = Country.mock(name: "USA", alpha3Code: "USA")
        
        mockManageUseCase.getSelectedResult = .success([egypt, usa])
        mockManageUseCase.removeResult = .success(())
        
        sut.onAppear()
        
        let loadExpectation = expectation(description: "Initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1.0)
        
        mockManageUseCase.getSelectedResult = .success([usa])
        
        let removeExpectation = expectation(description: "Remove and reload")
        var finalState: ViewState<[CountryRowViewModel]>?
        
        sut.$state
            .dropFirst()
            .sink { state in
                if case .content(let rows) = state, rows.count == 1 {
                    finalState = state
                    removeExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.didRemoveCountry(id: "EGY")
        
        wait(for: [removeExpectation], timeout: 2.0)
        
        XCTAssertEqual(mockManageUseCase.removeCallCount, 1)
        XCTAssertEqual(mockManageUseCase.lastRemovedCountry?.alpha3Code, "EGY")
        
        if case .content(let rows) = finalState {
            XCTAssertEqual(rows.count, 1)
            XCTAssertEqual(rows.first?.name, "USA")
        } else {
            XCTFail("Should show updated content after removal")
        }
    }
    
    func testDidRemoveCountry_WithInvalidId_ShouldNotRemove() {
        let egypt = Country.mock(name: "Egypt", alpha3Code: "EGY")
        mockManageUseCase.getSelectedResult = .success([egypt])
        
        sut.onAppear()
        
        let loadExpectation = expectation(description: "Initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1.0)
        
        let initialCallCount = mockManageUseCase.removeCallCount
        
        sut.didRemoveCountry(id: "INVALID")
        
        let finalExpectation = expectation(description: "No removal")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            finalExpectation.fulfill()
        }
        wait(for: [finalExpectation], timeout: 1.0)
        
        XCTAssertEqual(mockManageUseCase.removeCallCount, initialCallCount,
                      "Should not call remove with invalid ID")
    }
    
    func testDidRemoveCountry_WhenRemovalFails_ShouldShowError() {
        let egypt = Country.mock(name: "Egypt", alpha3Code: "EGY")
        mockManageUseCase.getSelectedResult = .success([egypt])
        mockManageUseCase.removeResult = .failure(.dataNotFound)
        
        sut.onAppear()
        
        let loadExpectation = expectation(description: "Initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1.0)
        
        let errorExpectation = expectation(description: "Error after removal")
        
        sut.$state
            .dropFirst()
            .sink { state in
                if case .error = state {
                    errorExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.didRemoveCountry(id: "EGY")
        
        wait(for: [errorExpectation], timeout: 2.0)
        
        if case .error(let message) = sut.state {
            XCTAssertEqual(message, "Failed to remove country")
        } else {
            XCTFail("Should show error state")
        }
    }
    
    
    func testMultipleRemoves_ShouldWorkSequentially() {
        // Given
        let egypt = Country.mock(name: "Egypt", alpha3Code: "EGY")
        let usa = Country.mock(name: "USA", alpha3Code: "USA")
        let france = Country.mock(name: "France", alpha3Code: "FRA")
        
        mockManageUseCase.getSelectedResult = .success([egypt, usa, france])
        mockManageUseCase.removeResult = .success(())
        
        sut.onAppear()
        
        let loadExpectation = expectation(description: "Initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1.0)
        
        mockManageUseCase.getSelectedResult = .success([usa, france])
        sut.didRemoveCountry(id: "EGY")
        
        let firstRemoveExpectation = expectation(description: "First remove")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            firstRemoveExpectation.fulfill()
        }
        wait(for: [firstRemoveExpectation], timeout: 1.0)
        
        mockManageUseCase.getSelectedResult = .success([france])
        sut.didRemoveCountry(id: "USA")
        
        let secondRemoveExpectation = expectation(description: "Second remove")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            secondRemoveExpectation.fulfill()
        }
        wait(for: [secondRemoveExpectation], timeout: 1.0)
        
        XCTAssertEqual(mockManageUseCase.removeCallCount, 2)
        
        if case .content(let rows) = sut.state {
            XCTAssertEqual(rows.count, 1)
            XCTAssertEqual(rows.first?.name, "France")
        } else {
            XCTFail("Should show remaining country")
        }
    }
}


final class MockManageSelectedCountriesUseCase: ManageSelectedCountriesUseCaseProtocol {
    
    var getSelectedCallCount = 0
    var addCallCount = 0
    var removeCallCount = 0
    
    var getSelectedResult: Result<[Country], ApplicationError> = .success([])
    var addResult: Result<Void, ApplicationError> = .success(())
    var removeResult: Result<Void, ApplicationError> = .success(())
    
    var lastAddedCountry: Country?
    var lastRemovedCountry: Country?
    
    func getSelected() -> CountryDomainPublisher<[Country]> {
        getSelectedCallCount += 1
        return getSelectedResult.publisher.eraseToAnyPublisher()
    }
    
    func add(_ country: Country) -> CountryDomainPublisher<Void> {
        addCallCount += 1
        lastAddedCountry = country
        return addResult.publisher.eraseToAnyPublisher()
    }
    
    func remove(_ country: Country) -> CountryDomainPublisher<Void> {
        removeCallCount += 1
        lastRemovedCountry = country
        return removeResult.publisher.eraseToAnyPublisher()
    }
}


