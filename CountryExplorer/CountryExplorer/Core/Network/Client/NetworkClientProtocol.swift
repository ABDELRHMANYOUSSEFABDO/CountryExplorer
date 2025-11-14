//
//  NetworkClientProtocol.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//



import Foundation
import Combine


protocol NetworkClientProtocol {
    
    func request(_ request: URLRequest) -> AnyPublisher<Data, NetworkError>
    
    func request(_ url: URL) -> AnyPublisher<Data, NetworkError>
}
