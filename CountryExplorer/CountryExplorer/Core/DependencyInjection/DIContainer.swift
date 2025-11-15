//
//  DIContainer.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation

// MARK: - DI Container Protocol

protocol DIContainerProtocol {
    // Core Services
    func makeLocationService() -> LocationServiceProtocol
    func makeCoreDataStack() -> CoreDataStack
    
    // Data Layer
    func makeNetworkManager() -> NetworkManagerProtocol
    func makeLocalDataSource() -> CountryLocalDataSource
    func makeCountryRepository() -> CountryRepositoryProtocol
    
    // Use Cases
    func makeFetchAllCountriesUseCase() -> FetchAllCountriesUseCaseProtocol
    func makeSearchCountriesUseCase() -> SearchCountriesUseCaseProtocol
    func makeManageSelectedCountriesUseCase() -> ManageSelectedCountriesUseCaseProtocol
    func makeGetCountryByLocationUseCase() -> GetCountryByLocationUseCaseProtocol
    
    // Services
    func makeFirstLaunchManager() -> FirstLaunchManagerProtocol
}

// MARK: - DI Container Implementation

final class DIContainer: DIContainerProtocol {
    
    static let shared = DIContainer()
    
    // Singleton instances (for services that should be shared)
    private lazy var locationService: LocationServiceProtocol = LocationService()
    private lazy var coreDataStack: CoreDataStack = CoreDataStack.shared
    private lazy var countryRepository: CountryRepositoryProtocol = self.createCountryRepository()
    
    private init() {}
    
    // MARK: - Core Services
    
    func makeLocationService() -> LocationServiceProtocol {
        return locationService
    }
    
    func makeCoreDataStack() -> CoreDataStack {
        return coreDataStack
    }
    
    // MARK: - Data Layer
    
    func makeNetworkManager() -> NetworkManagerProtocol {
        let client = URLSessionNetworkClient()
        let dataMapper = JSONDataMapper()
        let responseMapper = CountryResponseMapper()
        
        return NetworkManager(
            client: client,
            dataMapper: dataMapper,
            responseMapper: responseMapper,
            baseURL: "https://restcountries.com"
        )
    }
    
    func makeLocalDataSource() -> CountryLocalDataSource {
        return CoreDataCountryLocalDataSource(coreDataStack: makeCoreDataStack())
    }
    
    func makeCountryRepository() -> CountryRepositoryProtocol {
        return countryRepository
    }
    
    private func createCountryRepository() -> CountryRepositoryProtocol {
        return CountryRepository(
            networkManager: makeNetworkManager(),
            localDataSource: makeLocalDataSource()
        )
    }
    
    // MARK: - Use Cases
    
    func makeFetchAllCountriesUseCase() -> FetchAllCountriesUseCaseProtocol {
        return FetchAllCountriesUseCase(repository: makeCountryRepository())
    }
    
    func makeSearchCountriesUseCase() -> SearchCountriesUseCaseProtocol {
        return SearchCountriesUseCase(repository: makeCountryRepository())
    }
    
    func makeManageSelectedCountriesUseCase() -> ManageSelectedCountriesUseCaseProtocol {
        return ManageSelectedCountriesUseCase(repository: makeCountryRepository())
    }
    
    func makeGetCountryByLocationUseCase() -> GetCountryByLocationUseCaseProtocol {
        return GetCountryByLocationUseCase(
            locationService: makeLocationService(),
            repository: makeCountryRepository(),
            defaultCountryCode: "EG" // Egypt as default
        )
    }
    
    // MARK: - Services
    
    func makeFirstLaunchManager() -> FirstLaunchManagerProtocol {
        return FirstLaunchManager(
            getCountryByLocationUseCase: makeGetCountryByLocationUseCase(),
            manageSelectedUseCase: makeManageSelectedCountriesUseCase()
        )
    }
}

// MARK: - DI Container for Testing

final class MockDIContainer: DIContainerProtocol {
    
    var mockLocationService: LocationServiceProtocol?
    var mockNetworkManager: NetworkManagerProtocol?
    var mockLocalDataSource: CountryLocalDataSource?
    var mockRepository: CountryRepositoryProtocol?
    
    func makeLocationService() -> LocationServiceProtocol {
        return mockLocationService ?? LocationService()
    }
    
    func makeCoreDataStack() -> CoreDataStack {
        return CoreDataStack.shared
    }
    
    func makeNetworkManager() -> NetworkManagerProtocol {
        return mockNetworkManager ?? DIContainer.shared.makeNetworkManager()
    }
    
    func makeLocalDataSource() -> CountryLocalDataSource {
        return mockLocalDataSource ?? DIContainer.shared.makeLocalDataSource()
    }
    
    func makeCountryRepository() -> CountryRepositoryProtocol {
        return mockRepository ?? DIContainer.shared.makeCountryRepository()
    }
    
    func makeFetchAllCountriesUseCase() -> FetchAllCountriesUseCaseProtocol {
        return FetchAllCountriesUseCase(repository: makeCountryRepository())
    }
    
    func makeSearchCountriesUseCase() -> SearchCountriesUseCaseProtocol {
        return SearchCountriesUseCase(repository: makeCountryRepository())
    }
    
    func makeManageSelectedCountriesUseCase() -> ManageSelectedCountriesUseCaseProtocol {
        return ManageSelectedCountriesUseCase(repository: makeCountryRepository())
    }
    
    func makeGetCountryByLocationUseCase() -> GetCountryByLocationUseCaseProtocol {
        return GetCountryByLocationUseCase(
            locationService: makeLocationService(),
            repository: makeCountryRepository(),
            defaultCountryCode: "EG"
        )
    }
    
    func makeFirstLaunchManager() -> FirstLaunchManagerProtocol {
        return FirstLaunchManager(
            getCountryByLocationUseCase: makeGetCountryByLocationUseCase(),
            manageSelectedUseCase: makeManageSelectedCountriesUseCase()
        )
    }
}


