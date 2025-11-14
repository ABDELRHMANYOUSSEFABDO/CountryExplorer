//
//  CountryLocalDataSource.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation
import Combine
import CoreData

protocol CountryLocalDataSource {
    func getAllCountries() -> CountryDomainPublisher<[Country]>
    func saveCountries(_ countries: [Country]) -> CountryDomainPublisher<Void>
    
    func getSelectedCountries() -> CountryDomainPublisher<[Country]>
    func addSelectedCountry(_ country: Country) -> CountryDomainPublisher<Void>
    func removeSelectedCountry(_ country: Country) -> CountryDomainPublisher<Void>
}

final class CoreDataCountryLocalDataSource: CountryLocalDataSource {
    
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func getAllCountries() -> CountryDomainPublisher<[Country]> {
        return Just([])
            .setFailureType(to: ApplicationError.self)
            .eraseToAnyPublisher()
    }
    
    func saveCountries(_ countries: [Country]) -> CountryDomainPublisher<Void> {
        return Just(())
            .setFailureType(to: ApplicationError.self)
            .eraseToAnyPublisher()
    }
    
    func getSelectedCountries() -> CountryDomainPublisher<[Country]> {
        return Just([])
            .setFailureType(to: ApplicationError.self)
            .eraseToAnyPublisher()
    }
    
    func addSelectedCountry(_ country: Country) -> CountryDomainPublisher<Void> {
        return Just(())
            .setFailureType(to: ApplicationError.self)
            .eraseToAnyPublisher()
    }
    
    func removeSelectedCountry(_ country: Country) -> CountryDomainPublisher<Void> {
        return Just(())
            .setFailureType(to: ApplicationError.self)
            .eraseToAnyPublisher()
    }
}
