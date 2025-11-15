//
//  MockCountryLocalDataSource.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import XCTest
import Combine
@testable import CountryExplorer

final class MockCountryLocalDataSource: CountryLocalDataSource {

    var allCountriesPublisher: CountryDomainPublisher<[Country]> =
        Just([]).setFailureType(to: ApplicationError.self).eraseToAnyPublisher()

    var saveCountriesPublisher: CountryDomainPublisher<Void> =
        Just(()).setFailureType(to: ApplicationError.self).eraseToAnyPublisher()

    var selectedCountriesPublisher: CountryDomainPublisher<[Country]> =
        Just([]).setFailureType(to: ApplicationError.self).eraseToAnyPublisher()

    var addSelectedPublisher: CountryDomainPublisher<Void> =
        Just(()).setFailureType(to: ApplicationError.self).eraseToAnyPublisher()

    var removeSelectedPublisher: CountryDomainPublisher<Void> =
        Just(()).setFailureType(to: ApplicationError.self).eraseToAnyPublisher()

    func getAllCountries() -> CountryDomainPublisher<[Country]> {
        allCountriesPublisher
    }

    func saveCountries(_ countries: [Country]) -> CountryDomainPublisher<Void> {
        saveCountriesPublisher
    }

    func getSelectedCountries() -> CountryDomainPublisher<[Country]> {
        selectedCountriesPublisher
    }

    func addSelectedCountry(_ country: Country) -> CountryDomainPublisher<Void> {
        addSelectedPublisher
    }

    func removeSelectedCountry(_ country: Country) -> CountryDomainPublisher<Void> {
        removeSelectedPublisher
    }
}
