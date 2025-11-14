//
//  CountryRepositoryProtocol.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation
import Combine

typealias CountryDomainPublisher<T> = AnyPublisher<T, ApplicationError>

protocol CountryRepositoryProtocol {
    func fetchAllCountries() -> CountryDomainPublisher<[Country]>
    func searchCountries(query: String) -> CountryDomainPublisher<[Country]>
    func fetchCountry(byCode code: String) -> CountryDomainPublisher<Country>
    
    func getSelectedCountries() -> CountryDomainPublisher<[Country]>
    func addSelectedCountry(_ country: Country) -> CountryDomainPublisher<Void>
    func removeSelectedCountry(_ country: Country) -> CountryDomainPublisher<Void>
}
