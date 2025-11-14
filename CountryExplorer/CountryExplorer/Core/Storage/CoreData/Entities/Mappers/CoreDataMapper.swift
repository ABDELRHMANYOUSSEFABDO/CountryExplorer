//
//  CoreDataMapper.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation
import CoreData

final class CoreDataMapper {
    static func map(
        country: Country,
        to entity: CountryEntity,
        in context: NSManagedObjectContext
    ) {
        entity.name = country.name
        entity.capital = country.capital
        entity.alpha2Code = country.alpha2Code
        entity.alpha3Code = country.alpha3Code
        entity.region = country.region
        entity.population = Int64(country.population)
        entity.flag = country.flag
        entity.nativeName = country.nativeName
        entity.borders = country.borders
        entity.timezones = country.timezones
        entity.lastUpdated = Date()
        
        if let oldCurrencies = entity.currencies as? Set<CurrencyEntity> {
            oldCurrencies.forEach { context.delete($0) }
        }
        
        if let oldLanguages = entity.languages as? Set<LanguageEntity> {
            oldLanguages.forEach { context.delete($0) }
        }
        
        country.currencies.forEach { currency in
            let currencyEntity = CurrencyEntity(context: context)
            currencyEntity.code = currency.code
            currencyEntity.name = currency.name
            currencyEntity.symbol = currency.symbol
            entity.addToCurrencies(currencyEntity)
        }
        
        country.languages.forEach { language in
            let languageEntity = LanguageEntity(context: context)
            languageEntity.iso639_1 = language.iso639_1
            languageEntity.name = language.name
            languageEntity.nativeName = language.nativeName
            entity.addToLanguages(languageEntity)
        }
    }
    
    static func mapToDomain(entity: CountryEntity) -> Country {
        let currencies = (entity.currencies as? Set<CurrencyEntity>)?.map { currencyEntity in
            Currency(
                code: currencyEntity.code,
                name: currencyEntity.name,
                symbol: currencyEntity.symbol
            )
        } ?? []
        
        let languages = (entity.languages as? Set<LanguageEntity>)?.map { languageEntity in
            Language(
                iso639_1: languageEntity.iso639_1,
                name: languageEntity.name,
                nativeName: languageEntity.nativeName
            )
        } ?? []
        
        return Country(
            name: entity.name,
            capital: entity.capital,
            alpha2Code: entity.alpha2Code,
            alpha3Code: entity.alpha3Code,
            region: entity.region,
            population: Int(entity.population),
            currencies: currencies,
            flag: entity.flag,
            nativeName: entity.nativeName,
            languages: languages,
            timezones: entity.timezones,
            borders: entity.borders
        )
    }
}
