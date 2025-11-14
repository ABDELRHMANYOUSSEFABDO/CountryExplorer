//
//  GetCountryByLocationUseCase.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation
import Combine

protocol GetCountryByLocationUseCaseProtocol {
    func execute() -> AnyPublisher<Country, ApplicationError>
}

final class GetCountryByLocationUseCase: GetCountryByLocationUseCaseProtocol {
    
    private let locationService: LocationServiceProtocol
    private let repository: CountryRepositoryProtocol
    private let defaultCountryCode: String
    
    init(
        locationService: LocationServiceProtocol,
        repository: CountryRepositoryProtocol,
        defaultCountryCode: String = "EG" // Egypt as default
    ) {
        self.locationService = locationService
        self.repository = repository
        self.defaultCountryCode = defaultCountryCode
    }
    
    func execute() -> AnyPublisher<Country, ApplicationError> {
        // Try to get location-based country
        return locationService.getCurrentCountryCode()
            .mapError { locationError -> ApplicationError in
                Logger.shared.warning("Location error: \(locationError.localizedDescription)")
                return ApplicationError.locationPermissionDenied
            }
            .flatMap { [weak self] locationResult -> AnyPublisher<Country, ApplicationError> in
                guard let self = self else {
                    return Fail(error: ApplicationError.unknown("Use case deallocated"))
                        .eraseToAnyPublisher()
                }
                
                Logger.shared.info("Fetching country by code: \(locationResult.countryCode)")
                
                // Fetch country by detected country code
                return self.repository.fetchCountry(byCode: locationResult.countryCode)
            }
            .catch { [weak self] error -> AnyPublisher<Country, ApplicationError> in
                guard let self = self else {
                    return Fail(error: ApplicationError.unknown("Use case deallocated"))
                        .eraseToAnyPublisher()
                }
                
                // Fallback to default country if location fails
                Logger.shared.warning("Falling back to default country: \(self.defaultCountryCode)")
                return self.repository.fetchCountry(byCode: self.defaultCountryCode)
            }
            .eraseToAnyPublisher()
    }
}

