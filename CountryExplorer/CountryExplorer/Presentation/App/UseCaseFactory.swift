//
//  UseCaseFactory.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//
//  DEPRECATED: Use DIContainer instead
//  This factory is kept for backward compatibility but delegates to DIContainer

import Foundation

struct UseCaseFactory {
    
    private static let container: DIContainerProtocol = DIContainer.shared

    static func makeFetchAllCountriesUseCase() -> FetchAllCountriesUseCaseProtocol {
        container.makeFetchAllCountriesUseCase()
    }

    static func makeSearchCountriesUseCase() -> SearchCountriesUseCaseProtocol {
        container.makeSearchCountriesUseCase()
    }

    static func makeManageSelectedCountriesUseCase() -> ManageSelectedCountriesUseCaseProtocol {
        container.makeManageSelectedCountriesUseCase()
    }
    
    static func makeGetCountryByLocationUseCase() -> GetCountryByLocationUseCaseProtocol {
        container.makeGetCountryByLocationUseCase()
    }
    
    static func makeFirstLaunchManager() -> FirstLaunchManagerProtocol {
        container.makeFirstLaunchManager()
    }
}
