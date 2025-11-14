//
//  RepositoryFactory.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

struct RepositoryFactory {

    static func makeCountryRepository() -> CountryRepositoryProtocol {
        let client = URLSessionNetworkClient()
        let dataMapper = JSONDataMapper()
        let responseMapper = CountryResponseMapper()

        let networkManager = NetworkManager(
            client: client,
            dataMapper: dataMapper,
            responseMapper: responseMapper,
            baseURL: "https://restcountries.com"
        )

        let coreDataStack = CoreDataStack.shared
        let localDataSource: CountryLocalDataSource = CoreDataCountryLocalDataSource(coreDataStack: coreDataStack)

        return CountryRepository(
            networkManager: networkManager,
            localDataSource: localDataSource
        )
    }

    static func makeMockCountryRepository(
        networkClient: NetworkClientProtocol,
        coreDataStack: CoreDataStack = .shared
    ) -> CountryRepositoryProtocol {
        let dataMapper = JSONDataMapper()
        let responseMapper = CountryResponseMapper()

        let networkManager = NetworkManager(
            client: networkClient,
            dataMapper: dataMapper,
            responseMapper: responseMapper,
            baseURL: "https://restcountries.com"
        )

        let localDataSource: CountryLocalDataSource = CoreDataCountryLocalDataSource(coreDataStack: coreDataStack)

        return CountryRepository(
            networkManager: networkManager,
            localDataSource: localDataSource
        )
    }
}
