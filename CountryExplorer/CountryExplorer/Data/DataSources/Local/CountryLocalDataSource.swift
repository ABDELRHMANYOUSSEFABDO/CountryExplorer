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
        return Future<[Country], ApplicationError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.databaseError("Data source deallocated")))
                return
            }
            
            let context = self.coreDataStack.viewContext
            let fetchRequest: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
            do {
                let entities = try context.fetch(fetchRequest)
                let countries = entities.map { CoreDataMapper.mapToDomain(entity: $0) }
                promise(.success(countries))
            } catch {
                promise(.failure(.databaseError("Failed to fetch countries: \(error.localizedDescription)")))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func saveCountries(_ countries: [Country]) -> CountryDomainPublisher<Void> {
        return Future<Void, ApplicationError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.databaseError("Data source deallocated")))
                return
            }
            
            let context = self.coreDataStack.viewContext
            
            context.perform {
                do {
                    let fetchRequest: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "isSelected == NO")
                    
                    let oldEntities = try context.fetch(fetchRequest)
                    oldEntities.forEach { context.delete($0) }
                    
                    for country in countries {
                        let fetchRequest: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "alpha3Code == %@", country.alpha3Code)
                        fetchRequest.fetchLimit = 1
                        
                        let entity: CountryEntity
                        if let existingEntity = try context.fetch(fetchRequest).first {
                            entity = existingEntity
                        } else {
                            entity = CountryEntity(context: context)
                        }
                        
                        CoreDataMapper.map(country: country, to: entity, in: context)
                    }
                    
                    if context.hasChanges {
                        try context.save()
                    }
                    
                    promise(.success(()))
                } catch {
                    promise(.failure(.databaseError("Failed to save countries: \(error.localizedDescription)")))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    func getSelectedCountries() -> CountryDomainPublisher<[Country]> {
        return Future<[Country], ApplicationError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.databaseError("Data source deallocated")))
                return
            }
            
            let context = self.coreDataStack.viewContext
            let fetchRequest: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "isSelected == YES")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
            do {
                let entities = try context.fetch(fetchRequest)
                let countries = entities.map { CoreDataMapper.mapToDomain(entity: $0) }
                promise(.success(countries))
            } catch {
                promise(.failure(.databaseError("Failed to fetch selected countries: \(error.localizedDescription)")))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func addSelectedCountry(_ country: Country) -> CountryDomainPublisher<Void> {
        return Future<Void, ApplicationError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.databaseError("Data source deallocated")))
                return
            }
            
            let context = self.coreDataStack.viewContext
            
            context.perform {
                do {
                    let countRequest: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
                    countRequest.predicate = NSPredicate(format: "isSelected == YES")
                    let selectedCount = try context.count(for: countRequest)
                    
                    guard selectedCount < 5 else {
                        promise(.failure(.maxCountriesReached))
                        return
                    }
                    
                    let fetchRequest: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "alpha3Code == %@", country.alpha3Code)
                    fetchRequest.fetchLimit = 1
                    
                    let entity: CountryEntity
                    if let existingEntity = try context.fetch(fetchRequest).first {
                        if existingEntity.isSelected {
                            promise(.failure(.countryAlreadyAdded))
                            return
                        }
                        entity = existingEntity
                    } else {
                        entity = CountryEntity(context: context)
                        CoreDataMapper.map(country: country, to: entity, in: context)
                    }
                    
                    entity.isSelected = true
                    
                    if context.hasChanges {
                        try context.save()
                    }
                    
                    promise(.success(()))
                } catch {
                    promise(.failure(.databaseError("Failed to add selected country: \(error.localizedDescription)")))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func removeSelectedCountry(_ country: Country) -> CountryDomainPublisher<Void> {
        return Future<Void, ApplicationError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.databaseError("Data source deallocated")))
                return
            }
            
            let context = self.coreDataStack.viewContext
            
            context.perform {
                do {
                    let fetchRequest: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "alpha3Code == %@", country.alpha3Code)
                    fetchRequest.fetchLimit = 1
                    
                    guard let entity = try context.fetch(fetchRequest).first else {
                        promise(.failure(.dataNotFound))
                        return
                    }
                    
                    entity.isSelected = false
                    
                    if context.hasChanges {
                        try context.save()
                    }
                    
                    promise(.success(()))
                } catch {
                    promise(.failure(.databaseError("Failed to remove selected country: \(error.localizedDescription)")))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
