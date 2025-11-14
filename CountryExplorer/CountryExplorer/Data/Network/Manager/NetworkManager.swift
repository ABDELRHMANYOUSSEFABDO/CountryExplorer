//
//  NetworkManager.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation
import Combine

protocol NetworkManagerProtocol {
    func fetchAllCountries() -> AnyPublisher<[Country], NetworkError>
    func searchCountries(query: String) -> AnyPublisher<[Country], NetworkError>
    func fetchCountryByCode(_ code: String) -> AnyPublisher<Country, NetworkError>
}

final class NetworkManager: NetworkManagerProtocol {
    
    private let client: NetworkClientProtocol
    private let dataMapper: DataMapperProtocol
    private let responseMapper: CountryResponseMapping
    private let baseURL: String
    
    init(
        client: NetworkClientProtocol,
        dataMapper: DataMapperProtocol,
        responseMapper: CountryResponseMapping = CountryResponseMapper(),
        baseURL: String = "https://restcountries.com"
    ) {
        self.client = client
        self.dataMapper = dataMapper
        self.responseMapper = responseMapper
        self.baseURL = baseURL
    }
    
    
    func fetchAllCountries() -> AnyPublisher<[Country], NetworkError> {
        guard let url = CountryEndpoint.all.url(baseURL: baseURL) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return client.request(url)
            .tryMap { [dataMapper] data -> [CountryDTO] in
                try dataMapper.map(data, to: [CountryDTO].self)
            }
            .map { [responseMapper] dtos in
                responseMapper.mapToDomain(dtos)
            }
            .mapError { error in
                self.mapToNetworkError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func searchCountries(query: String) -> AnyPublisher<[Country], NetworkError> {
        guard !query.isEmpty,
              let url = CountryEndpoint.search(name: query).url(baseURL: baseURL) else {
            return fetchAllCountries()
        }
        
        return client.request(url)
            .tryMap { [dataMapper] data -> [CountryDTO] in
                try dataMapper.map(data, to: [CountryDTO].self)
            }
            .map { [responseMapper] dtos in
                responseMapper.mapToDomain(dtos)
            }
            .mapError { error in
                self.mapToNetworkError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func fetchCountryByCode(_ code: String) -> AnyPublisher<Country, NetworkError> {
        guard let url = CountryEndpoint.byCode(code: code).url(baseURL: baseURL) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return client.request(url)
            .tryMap { [dataMapper] data -> CountryDTO in
                try dataMapper.map(data, to: CountryDTO.self)
            }
            .map { [responseMapper] dto in
                responseMapper.mapToDomain(dto)
            }
            .mapError { error in
                self.mapToNetworkError(error)
            }
            .eraseToAnyPublisher()
    }
    
    
    private func mapToNetworkError(_ error: Error) -> NetworkError {
        if let networkError = error as? NetworkError {
            return networkError
        }
        return .unknown(message: error.localizedDescription)
    }
}
