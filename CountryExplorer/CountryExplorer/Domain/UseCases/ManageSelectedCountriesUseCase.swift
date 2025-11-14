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
                guard let self else {
                    return Fail(error: ApplicationError.unknown("ManageSelectedCountriesUseCase deallocated"))
                        .eraseToAnyPublisher()
                }
                
                if current.contains(where: { $0.id == country.id }) {
                    return Fail(error: ApplicationError.countryAlreadyAdded)
                        .eraseToAnyPublisher()
                }
                
                if current.count >= self.maxCountries {
                    return Fail(error: ApplicationError.maxCountriesReached)
                        .eraseToAnyPublisher()
                }
                
                return self.repository.addSelectedCountry(country)
            }
            .eraseToAnyPublisher()
    }
    
    func remove(_ country: Country) -> CountryDomainPublisher<Void> {
        repository.removeSelectedCountry(country)
    }
}
