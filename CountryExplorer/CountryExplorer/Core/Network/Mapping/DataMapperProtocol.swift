//
//  DataMapperProtocol.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation

protocol DataMapperProtocol {
    func map<T: Decodable>(_ data: Data, to type: T.Type) throws -> T
}
