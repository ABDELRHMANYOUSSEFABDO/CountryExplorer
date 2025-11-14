//
//  MockDataMapper.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation
import Combine
@testable import CountryExplorer

final class MockDataMapper: DataMapperProtocol {

    var shouldThrowError = false
    var mappedObjects: [String: Any] = [:]

    func map<T: Decodable>(_ data: Data, to type: T.Type) throws -> T {
        if shouldThrowError {
            throw NetworkError.decodingError(NSError(domain: "MockError", code: 0))
        }

        let typeName = String(describing: type)
        if let object = mappedObjects[typeName] as? T {
            return object
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(type, from: data)
    }

    func setMappedObject<T>(_ object: T, for type: T.Type) {
        let typeName = String(describing: type)
        mappedObjects[typeName] = object
    }
}
