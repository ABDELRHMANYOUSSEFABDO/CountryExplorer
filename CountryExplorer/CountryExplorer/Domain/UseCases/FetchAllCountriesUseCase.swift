//
//  Untitled.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation
import Combine

protocol FetchAllCountriesUseCaseProtocol {
    func execute() -> CountryDomainPublisher<[Country]>
}

final class FetchAllCountriesUseCase: FetchAllCountriesUseCaseProtocol {
    private let repository: CountryRepositoryProtocol
    
    init(repository: CountryRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() -> CountryDomainPublisher<[Country]> {
        repository.fetchAllCountries()
    }
}
