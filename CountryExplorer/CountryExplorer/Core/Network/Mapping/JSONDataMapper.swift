//
//  JSONDataMapper.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//


import Foundation

final class JSONDataMapper: DataMapperProtocol {
    
    private let decoder: JSONDecoder
    
    init(decoder: JSONDecoder = JSONDecoder()) {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }
    
    func map<T: Decodable>(_ data: Data, to type: T.Type) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
