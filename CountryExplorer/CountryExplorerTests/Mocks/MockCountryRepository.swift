//
//  MockCountryRepository.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation
import Combine
@testable import CountryExplorer

final class MockCountryRepository: CountryRepositoryProtocol {

    var countries: [Country] = []
    var selected: [Country] = []

    func fetchAllCountries() -> CountryDomainPublisher<[Country]> {
        Just(countries)
            .setFailureType(to: ApplicationError.self)
            .eraseToAnyPublisher()
    }

    func searchCountries(query: String) -> CountryDomainPublisher<[Country]> {
        guard !query.isEmpty else {
            return fetchAllCountries()
        }
        
        let filtered = countries.filter {
            $0.name.lowercased().contains(query.lowercased())
        }

        return Just(filtered)
            .setFailureType(to: ApplicationError.self)
            .eraseToAnyPublisher()
    }

    func fetchCountry(byCode code: String) -> CountryDomainPublisher<Country> {
        if let country = countries.first(where: {
            $0.alpha2Code == code || $0.alpha3Code == code
        }) {
            return Just(country)
                .setFailureType(to: ApplicationError.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: ApplicationError.dataNotFound)
                .eraseToAnyPublisher()
        }
    }

    func getSelectedCountries() -> CountryDomainPublisher<[Country]> {
        Just(selected)
            .setFailureType(to: ApplicationError.self)
            .eraseToAnyPublisher()
    }

    func addSelectedCountry(_ country: Country) -> CountryDomainPublisher<Void> {
        selected.append(country)
        return Just(())
            .setFailureType(to: ApplicationError.self)
            .eraseToAnyPublisher()
    }

    func removeSelectedCountry(_ country: Country) -> CountryDomainPublisher<Void> {
        selected.removeAll { $0.id == country.id }
        return Just(())
            .setFailureType(to: ApplicationError.self)
            .eraseToAnyPublisher()
    }
}
