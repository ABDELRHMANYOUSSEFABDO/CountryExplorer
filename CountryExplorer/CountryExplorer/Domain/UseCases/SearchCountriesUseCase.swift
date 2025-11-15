//
//  SearchCountriesUseCase.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation
import Combine

protocol SearchCountriesUseCaseProtocol {
    func execute(query: String) -> CountryDomainPublisher<[Country]>
}

final class SearchCountriesUseCase: SearchCountriesUseCaseProtocol {
    private let repository: CountryRepositoryProtocol
    
    init(repository: CountryRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(query: String) -> CountryDomainPublisher<[Country]> {
        repository.searchCountries(query: query)
    }
}

