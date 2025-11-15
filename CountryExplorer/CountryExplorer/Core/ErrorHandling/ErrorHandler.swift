//
//  ErrorHandler.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//



import Foundation


protocol ErrorHandlerProtocol {
    func handle(_ error: Error) -> ApplicationError
    func handleWithRecovery(_ error: Error, recovery: @escaping () -> Void)
    func handleWithRetry(_ error: Error, retry: @escaping () -> Void)
}


final class ErrorHandler: ErrorHandlerProtocol {
    
    static let shared = ErrorHandler()
    
    private let logger: LoggerProtocol
    private let crashReporter: CrashReporterProtocol
    
    init(logger: LoggerProtocol = Logger.shared,
         crashReporter: CrashReporterProtocol = CrashReporter.shared) {
        self.logger = logger
        self.crashReporter = crashReporter
    }
    
    func handle(_ error: Error) -> ApplicationError {
        let appError = mapToApplicationError(error)
        
        logError(appError)
                
        if shouldReportToCrashService(appError) {
            crashReporter.recordError(appError)
        }
        
        return appError
    }
    
    func handleWithRecovery(_ error: Error, recovery: @escaping () -> Void) {
        let appError = handle(error)
        
        if appError.isRetryable {
            recovery()
        }
    }
    
    func handleWithRetry(_ error: Error, retry: @escaping () -> Void) {
        let appError = handle(error)
        
        if appError.isRetryable {
            RetryManager.shared.retry(operation: retry, error: appError)
        }
    }
    
    // MARK: - Private
    
    private func mapToApplicationError(_ error: Error) -> ApplicationError {
        if let appError = error as? ApplicationError {
            return appError
        } else if let networkError = error as? NetworkError {
            return .networkError(networkError)
        } else if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .dataNotAllowed:
                return .noInternetConnection
            case .timedOut:
                return .timeout
            default:
                return .networkError(.unknown(message: urlError.localizedDescription))
            }
        } else {
            return .unknown(error.localizedDescription)
        }
    }
    
    private func logError(_ error: ApplicationError,
                          file: String = #file,
                          function: String = #function,
                          line: Int = #line) {
        
        logger.error(
            "Error: \(error.errorDescription ?? "Unknown error")",
            file: file,
            function: function,
            line: line
        )
        
        if let recovery = error.recoverySuggestion {
            logger.info(
                "Recovery suggestion: \(recovery)",
                file: file,
                function: function,
                line: line
            )
        }
    }

    
   
    
    private func shouldReportToCrashService(_ error: ApplicationError) -> Bool {
        switch error {
        case .unknown, .databaseError, .fileSystemError:
            return true
        default:
            return false
        }
    }
}


final class RetryManager {
    
    static let shared = RetryManager()
    
    private let maxRetries = 3
    private let retryDelay: TimeInterval = 2.0
    private var retryCount: [String: Int] = [:]
    
    func retry(operation: @escaping () -> Void, error: ApplicationError) {
        let operationId = UUID().uuidString
        retryCount[operationId] = 0
        
        performRetry(operationId: operationId, operation: operation, error: error)
    }
    
    private func performRetry(operationId: String,
                              operation: @escaping () -> Void,
                              error: ApplicationError) {
        guard let count = retryCount[operationId], count < maxRetries else {
            Logger.shared.error("Max retries reached for operation: \(operationId)")
            retryCount.removeValue(forKey: operationId)
            return
        }
        
        retryCount[operationId] = count + 1
        
        let delay = retryDelay * pow(2.0, Double(count)) // Exponential backoff
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            Logger.shared.info("Retrying operation: \(operationId) (attempt \(count + 1)/\(self.maxRetries))")
            operation()
        }
    }
}

// MARK: - Crash Reporter Protocol

protocol CrashReporterProtocol {
    func recordError(_ error: Error)
    func log(_ message: String, level: LogLevel)
    func setUserIdentifier(_ identifier: String?)
    func setCustomValue(_ value: Any?, forKey key: String)
}

// MARK: - Crash Reporter

final class CrashReporter: CrashReporterProtocol {
    
    static let shared = CrashReporter()
    
    private var userIdentifier: String?
    private var customValues: [String: Any] = [:]
    
    func recordError(_ error: Error) {
       
        Logger.shared.error("Crash Reporter: \(error.localizedDescription)")
    }
    
    func log(_ message: String, level: LogLevel) {}
    
    func setUserIdentifier(_ identifier: String?) {
        userIdentifier = identifier
      
    }
    
    func setCustomValue(_ value: Any?, forKey key: String) {
        customValues[key] = value
    }
}
