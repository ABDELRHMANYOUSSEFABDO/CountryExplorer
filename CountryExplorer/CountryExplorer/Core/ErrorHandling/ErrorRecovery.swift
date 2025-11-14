//
//  ErrorRecovery.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//



import Foundation
import Combine


enum ErrorRecoveryStrategy {
    case retry(maxAttempts: Int)
    case fallback(action: () -> Void)
    case alert(title: String, message: String)
    case silent
    case custom(handler: (Error) -> Void)
}


final class ErrorRecoveryManager {
    
    static func recover(from error: ApplicationError,
                        using strategy: ErrorRecoveryStrategy,
                        completion: ((Bool) -> Void)? = nil) {
        
        switch strategy {
        case .retry(let maxAttempts):
            if error.isRetryable, maxAttempts > 0 {
                completion?(true)
            } else {
                completion?(false)
            }
            
        case .fallback(let action):
            action()
            completion?(true)
            
        case .alert(let title, let message):
            NotificationCenter.default.post(
                name: .showErrorAlert,
                object: nil,
                userInfo: ["title": title, "message": message]
            )
            completion?(true)
            
        case .silent:
            Logger.shared.error("Silent error: \(error.localizedDescription)")
            completion?(true)
            
        case .custom(let handler):
            handler(error)
            completion?(true)
        }
    }
}


extension Notification.Name {
    static let showErrorAlert = Notification.Name("showErrorAlert")
}


extension Result {
    func mapToApplicationError() -> Result<Success, ApplicationError> {
        mapError { error in
            ErrorHandler.shared.handle(error)
        }
    }
}


extension Publisher {
    func mapToApplicationError() -> AnyPublisher<Output, ApplicationError> {
        mapError { error in
            ErrorHandler.shared.handle(error)
        }
        .eraseToAnyPublisher()
    }
    
    func handleErrors(with strategy: ErrorRecoveryStrategy) -> AnyPublisher<Output, Never> {
        self.catch { error -> Empty<Output, Never> in
            let appError = ErrorHandler.shared.handle(error)
            ErrorRecoveryManager.recover(from: appError, using: strategy)
            return Empty()
        }
        .eraseToAnyPublisher()
    }
}
