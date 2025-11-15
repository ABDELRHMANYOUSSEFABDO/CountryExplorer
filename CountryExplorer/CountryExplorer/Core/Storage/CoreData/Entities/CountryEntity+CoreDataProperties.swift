//
//  CountryEntity+CoreDataProperties.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation
import CoreData

extension CountryEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CountryEntity> {
        return NSFetchRequest<CountryEntity>(entityName: "CountryEntity")
    }
    
    @NSManaged public var alpha2Code: String
    @NSManaged public var alpha3Code: String
    @NSManaged public var borders: [String]?
    @NSManaged public var capital: String
    @NSManaged public var flag: String?
    @NSManaged public var isSelected: Bool
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var name: String
    @NSManaged public var nativeName: String?
    @NSManaged public var population: Int64
    @NSManaged public var region: String
    @NSManaged public var timezones: [String]?
    @NSManaged public var currencies: NSSet?
    @NSManaged public var languages: NSSet?
}

// MARK: Generated accessors for currencies
extension CountryEntity {
    
    @objc(addCurrenciesObject:)
    @NSManaged public func addToCurrencies(_ value: CurrencyEntity)
    
    @objc(removeCurrenciesObject:)
    @NSManaged public func removeFromCurrencies(_ value: CurrencyEntity)
    
    @objc(addCurrencies:)
    @NSManaged public func addToCurrencies(_ values: NSSet)
    
    @objc(removeCurrencies:)
    @NSManaged public func removeFromCurrencies(_ values: NSSet)
}

// MARK: Generated accessors for languages
extension CountryEntity {
    
    @objc(addLanguagesObject:)
    @NSManaged public func addToLanguages(_ value: LanguageEntity)
    
    @objc(removeLanguagesObject:)
    @NSManaged public func removeFromLanguages(_ value: LanguageEntity)
    
    @objc(addLanguages:)
    @NSManaged public func addToLanguages(_ values: NSSet)
    
    @objc(removeLanguages:)
    @NSManaged public func removeFromLanguages(_ values: NSSet)
}

extension CountryEntity: Identifiable {
    
}

