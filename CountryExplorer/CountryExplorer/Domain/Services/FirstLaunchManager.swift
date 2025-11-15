//
//  FirstLaunchManager.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation
import Combine

protocol FirstLaunchManagerProtocol {
    func handleFirstLaunchIfNeeded() -> AnyPublisher<Void, Never>
    var isFirstLaunch: Bool { get }
}

final class FirstLaunchManager: FirstLaunchManagerProtocol {
    
    private let getCountryByLocationUseCase: GetCountryByLocationUseCaseProtocol
    private let manageSelectedUseCase: ManageSelectedCountriesUseCaseProtocol
    private let userDefaults: UserDefaults
    private let firstLaunchKey = "hasLaunchedBefore"
    
    init(
        getCountryByLocationUseCase: GetCountryByLocationUseCaseProtocol,
        manageSelectedUseCase: ManageSelectedCountriesUseCaseProtocol,
        userDefaults: UserDefaults = .standard
    ) {
        self.getCountryByLocationUseCase = getCountryByLocationUseCase
        self.manageSelectedUseCase = manageSelectedUseCase
        self.userDefaults = userDefaults
    }
    
    var isFirstLaunch: Bool {
        !userDefaults.bool(forKey: firstLaunchKey)
    }
    
    func handleFirstLaunchIfNeeded() -> AnyPublisher<Void, Never> {
        guard isFirstLaunch else {
            Logger.shared.info("Not first launch, skipping auto-add country")
            return Just(()).eraseToAnyPublisher()
        }
        
        Logger.shared.info("First launch detected, attempting to add country by location")
        
        // Mark as launched before proceeding
        userDefaults.set(true, forKey: firstLaunchKey)
        
        return getCountryByLocationUseCase.execute()
            .flatMap { [weak self] country -> AnyPublisher<Void, ApplicationError> in
                guard let self = self else {
                    return Fail(error: ApplicationError.unknown("Manager deallocated"))
                        .eraseToAnyPublisher()
                }
                
                Logger.shared.info("Adding first country: \(country.name)")
                
                // Add country to selected
                return self.manageSelectedUseCase.add(country)
            }
            .catch { error -> AnyPublisher<Void, Never> in
                Logger.shared.error("Failed to add first launch country: \(error.localizedDescription)")
                // Don't fail the app, just log the error
                return Just(()).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}


