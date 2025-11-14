//
//  CountryResponseMapper.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation

protocol CountryResponseMapping {
    func mapToDomain(_ dto: CountryDTO) -> Country
    func mapToDomain(_ dtos: [CountryDTO]) -> [Country]
}

final class CountryResponseMapper: CountryResponseMapping {
    
    func mapToDomain(_ dto: CountryDTO) -> Country {
        let currencies: [Currency] = (dto.currencies ?? []).map { currencyDTO in
            Currency(
                code: currencyDTO.code ?? "",
                name: currencyDTO.name ?? "",
                symbol: currencyDTO.symbol ?? ""
            )
        }
        
        let languages: [Language] = (dto.languages ?? []).map { languageDTO in
            Language(
                iso639_1: languageDTO.iso639_1,
                name: languageDTO.name ?? "",
                nativeName: languageDTO.nativeName
            )
        }
        
        return Country(
            name: dto.name,
            capital: dto.capital ?? "N/A",
            alpha2Code: dto.alpha2Code,
            alpha3Code: dto.alpha3Code ?? "",
            region: dto.region ?? "Unknown",
            population: dto.population ?? 0,
            currencies: currencies,
            flag: dto.flag,
            nativeName: dto.nativeName,
            languages: languages,
            timezones: dto.timezones,
            borders: dto.borders
        )
    }
    
    func mapToDomain(_ dtos: [CountryDTO]) -> [Country] {
        dtos.map(mapToDomain)
    }
}
