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

/// مسئول عن تحويل الـ DTOs لـ Domain models
final class CountryResponseMapper: CountryResponseMapping {
    
    func mapToDomain(_ dto: CountryDTO) -> Country {
        let currencies: [Currency] = (dto.currencies ?? []).map { currencyDTO in
            Currency(
                code: currencyDTO.code ?? "",
                name: currencyDTO.name ?? "",
                symbol: currencyDTO.symbol ?? ""
            )
        }
        
        return Country(
            name: dto.name,
            capital: dto.capital ?? "N/A",
            alpha2Code: dto.alpha2Code,
            alpha3Code: dto.alpha3Code ?? "",
            region: dto.region ?? "Unknown",
            population: dto.population ?? 0,
            currencies: currencies
        )
    }
    
    func mapToDomain(_ dtos: [CountryDTO]) -> [Country] {
        dtos.map(mapToDomain)
    }
}
