//
//  UseCaseFactory.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation

struct UseCaseFactory {


    private static let countryRepository: CountryRepositoryProtocol = {
        RepositoryFactory.makeCountryRepository()
    }()


    static func makeFetchAllCountriesUseCase() -> FetchAllCountriesUseCaseProtocol {
        FetchAllCountriesUseCase(repository: countryRepository)
    }

    static func makeSearchCountriesUseCase() -> SearchCountriesUseCaseProtocol {
        SearchCountriesUseCase(repository: countryRepository)
    }

    static func makeManageSelectedCountriesUseCase() -> ManageSelectedCountriesUseCaseProtocol {
        ManageSelectedCountriesUseCase(repository: countryRepository)
    }
}
