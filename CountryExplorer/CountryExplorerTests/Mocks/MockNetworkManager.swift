//
//  MockNetworkManager.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import XCTest
import Combine
@testable import CountryExplorer


final class MockNetworkManager: NetworkManagerProtocol {

    var fetchAllCountriesPublisher: AnyPublisher<[Country], NetworkError>!
    var searchCountriesPublisher: AnyPublisher<[Country], NetworkError>!
    var fetchCountryByCodePublisher: AnyPublisher<Country, NetworkError>!

    func fetchAllCountries() -> AnyPublisher<[Country], NetworkError> {
        fetchAllCountriesPublisher
    }

    func searchCountries(query: String) -> AnyPublisher<[Country], NetworkError> {
        searchCountriesPublisher
    }

    func fetchCountryByCode(_ code: String) -> AnyPublisher<Country, NetworkError> {
        fetchCountryByCodePublisher
    }
}
