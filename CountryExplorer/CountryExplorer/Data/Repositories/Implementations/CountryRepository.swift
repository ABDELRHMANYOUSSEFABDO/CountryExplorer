//
//  CountryRepository.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation
import Combine
import CoreData

final class CountryRepository: CountryRepositoryProtocol {
    
    private let networkManager: NetworkManagerProtocol
    private let localDataSource: CountryLocalDataSource
    private var cancellables = Set<AnyCancellable>()
    
    init(
        networkManager: NetworkManagerProtocol,
        localDataSource: CountryLocalDataSource
    ) {
        self.networkManager = networkManager
        self.localDataSource = localDataSource
    }
    

    func fetchAllCountries() -> CountryDomainPublisher<[Country]> {
        networkManager.fetchAllCountries()
            .mapError { networkError in
                ApplicationError.networkError(networkError)
            }
            .handleEvents(receiveOutput: { [weak self] countries in
                guard let self = self else { return }
                
                _ = self.saveCountriesLocally(countries)
                    .sink(receiveCompletion: { _ in }, receiveValue: { })
            })
            .catch { [weak self] appError -> CountryDomainPublisher<[Country]> in
                guard let self = self else {
                    return Fail(error: appError).eraseToAnyPublisher()
                }
                return self.getLocalCountries()
            }
            .eraseToAnyPublisher()
    }
    
    func searchCountries(query: String) -> CountryDomainPublisher<[Country]> {
        guard !query.isEmpty else {
            return fetchAllCountries()
        }
        
        let localSearch = getLocalCountries()
            .map { countries in
                countries.filter { country in
                    country.name.localizedCaseInsensitiveContains(query) ||
                    country.capital.localizedCaseInsensitiveContains(query) ||
                    country.alpha2Code.localizedCaseInsensitiveContains(query) ||
                    country.alpha3Code.localizedCaseInsensitiveContains(query) ||
                    country.currencyDescription.localizedCaseInsensitiveContains(query)
                }
            }
            .eraseToAnyPublisher()
        
        return localSearch
            .flatMap { [weak self] localResults -> CountryDomainPublisher<[Country]> in
                guard let self = self else {
                    return Fail(error: ApplicationError.unknown("Repository deallocated"))
                        .eraseToAnyPublisher()
                }
                
                if !localResults.isEmpty {
                    return Just(localResults)
                        .setFailureType(to: ApplicationError.self)
                        .eraseToAnyPublisher()
                }
                
                return self.networkManager.searchCountries(query: query)
                    .mapError { ApplicationError.networkError($0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func fetchCountry(byCode code: String) -> CountryDomainPublisher<Country> {
        let localFetch = getLocalCountries()
            .map { countries in
                countries.first { $0.alpha2Code == code }
            }
            .eraseToAnyPublisher()
        
        return localFetch
            .flatMap { [weak self] localCountry -> CountryDomainPublisher<Country> in
                guard let self = self else {
                    return Fail(error: ApplicationError.unknown("Repository deallocated"))
                        .eraseToAnyPublisher()
                }
                
                if let country = localCountry {
                    return Just(country)
                        .setFailureType(to: ApplicationError.self)
                        .eraseToAnyPublisher()
                }
                
                return self.networkManager.fetchCountryByCode(code)
                    .mapError { ApplicationError.networkError($0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    

    func getSelectedCountries() -> CountryDomainPublisher<[Country]> {
        localDataSource.getSelectedCountries()
    }
    
    func addSelectedCountry(_ country: Country) -> CountryDomainPublisher<Void> {
        localDataSource.addSelectedCountry(country)
    }
    
    func removeSelectedCountry(_ country: Country) -> CountryDomainPublisher<Void> {
        localDataSource.removeSelectedCountry(country)
    }
    
    func saveCountriesLocally(_ countries: [Country]) -> CountryDomainPublisher<Void> {
        localDataSource.saveCountries(countries)
    }
    
    func getLocalCountries() -> CountryDomainPublisher<[Country]> {
        localDataSource.getAllCountries()
    }
}
