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
    private let searchService: CountrySearchServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        networkManager: NetworkManagerProtocol,
        localDataSource: CountryLocalDataSource,
        searchService: CountrySearchServiceProtocol = CountrySearchService()
    ) {
        self.networkManager = networkManager
        self.localDataSource = localDataSource
        self.searchService = searchService
    }
    

    func fetchAllCountries() -> CountryDomainPublisher<[Country]> {
        networkManager.fetchAllCountries()
            .mapError { networkError in
                ApplicationError.networkError(networkError)
            }
            .handleEvents(receiveOutput: { [weak self] countries in
                guard let self = self else { return }
                
                self.saveCountriesLocally(countries)
                    .sink(receiveCompletion: { _ in }, receiveValue: { })
                    .store(in: &self.cancellables)
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
        
        // Offline-first strategy: Search locally only
        return getLocalCountries()
            .map { [weak self] countries in
                guard let self = self else { return [] }
                return self.searchService.search(countries, query: query)
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
                    .handleEvents(receiveOutput: { [weak self] country in
                        guard let self = self else { return }
                        // Save fetched country locally
                        self.saveCountriesLocally([country])
                            .sink(receiveCompletion: { _ in }, receiveValue: { })
                            .store(in: &self.cancellables)
                    })
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
