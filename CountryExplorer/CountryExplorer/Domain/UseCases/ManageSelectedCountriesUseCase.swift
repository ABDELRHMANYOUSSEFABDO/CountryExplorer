//
//  ManageSelectedCountriesUseCase.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation
import Combine

protocol ManageSelectedCountriesUseCaseProtocol {
    func getSelected() -> CountryDomainPublisher<[Country]>
    func add(_ country: Country) -> CountryDomainPublisher<Void>
    func remove(_ country: Country) -> CountryDomainPublisher<Void>
}

final class ManageSelectedCountriesUseCase: ManageSelectedCountriesUseCaseProtocol {
    private let repository: CountryRepositoryProtocol
    private let maxCountries = 5
    
    init(repository: CountryRepositoryProtocol) {
        self.repository = repository
    }
    
    func getSelected() -> CountryDomainPublisher<[Country]> {
        repository.getSelectedCountries()
    }
    
    func add(_ country: Country) -> CountryDomainPublisher<Void> {
        repository.getSelectedCountries()
            .flatMap { [weak self] current -> CountryDomainPublisher<Void> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "deallocated", code: -1)).eraseToAnyPublisher()
                }
                
                if current.contains(where: { $0.id == country.id }) {
                    return Fail(error: NSError(domain: "country-already-added", code: 1)).eraseToAnyPublisher()
                }
                
                if current.count >= self.maxCountries {
                    return Fail(error: NSError(domain: "max-countries-reached", code: 2)).eraseToAnyPublisher()
                }
                
                return self.repository.addSelectedCountry(country)
            }
            .eraseToAnyPublisher()
    }
    
    func remove(_ country: Country) -> CountryDomainPublisher<Void> {
        repository.removeSelectedCountry(country)
    }
}
