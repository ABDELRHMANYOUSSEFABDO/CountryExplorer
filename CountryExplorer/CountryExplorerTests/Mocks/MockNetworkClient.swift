//
//  MockNetworkClient.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//
import XCTest
import Combine
@testable import CountryExplorer

final class MockNetworkClient: NetworkClientProtocol {

    var shouldFail = false
    var errorToThrow: NetworkError = .noInternetConnection
    var dataToReturn: Data?
    var delay: TimeInterval = 0

    private(set) var requestedURLs: [URL] = []
    private(set) var requestedRequests: [URLRequest] = []

    func request(_ request: URLRequest) -> AnyPublisher<Data, NetworkError> {
        requestedRequests.append(request)

        if shouldFail {
            return Fail(error: errorToThrow)
                .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        }

        guard let data = dataToReturn else {
            return Fail(error: NetworkError.noData)
                .eraseToAnyPublisher()
        }

        return Just(data)
            .setFailureType(to: NetworkError.self)
            .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func request(_ url: URL) -> AnyPublisher<Data, NetworkError> {
        requestedURLs.append(url)
        let request = URLRequest(url: url)
        return self.request(request)
    }

    func reset() {
        shouldFail = false
        errorToThrow = .noInternetConnection
        dataToReturn = nil
        delay = 0
        requestedURLs.removeAll()
        requestedRequests.removeAll()
    }

    func setSuccessResponse<T: Encodable>(_ response: T) {
        dataToReturn = try? JSONEncoder().encode(response)
    }

    func setJSONResponse(_ json: String) {
        dataToReturn = json.data(using: .utf8)
    }
}
