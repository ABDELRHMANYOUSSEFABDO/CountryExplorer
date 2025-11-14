//
//  URLSessionNetworkClient.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation
import Combine

final class URLSessionNetworkClient: NetworkClientProtocol {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request(_ url: URL) -> AnyPublisher<Data, NetworkError> {
        let request = URLRequest(url: url)
        return self.request(request)
    }
    
    func request(_ request: URLRequest) -> AnyPublisher<Data, NetworkError> {

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.unknown(message: "Invalid response type.")
                }
                
                switch httpResponse.statusCode {
                case 200..<300:
                    return data
                case 408:
                    throw NetworkError.timeout
                case 401:

                    throw NetworkError.serverError(statusCode: 401, message: "Unauthorized.")
                default:
                    let message = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                    throw NetworkError.serverError(statusCode: httpResponse.statusCode,
                                                   message: message)
                }
            }
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                }
                
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet, .dataNotAllowed:
                        return .noInternetConnection
                    case .timedOut:
                        return .timeout
                    case .cancelled:
                        return .cancelled
                    default:
                        return .unknown(message: urlError.localizedDescription)
                    }
                }
                
                return .unknown(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
}
