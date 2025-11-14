//
//  Untitled.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation
import os.log

enum LogLevel: Int, CaseIterable {
    case verbose = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
    case critical = 5
    
    var prefix: String {
        switch self {
        case .verbose:  return "📝 VERBOSE"
        case .debug:    return "🔍 DEBUG"
        case .info:     return "ℹ️ INFO"
        case .warning:  return "⚠️ WARNING"
        case .error:    return "❌ ERROR"
        case .critical: return "🔥 CRITICAL"
        }
    }
    
    var osLogType: OSLogType {
        switch self {
        case .verbose, .debug:
            return .debug
        case .info:
            return .info
        case .warning:
            return .default
        case .error:
            return .error
        case .critical:
            return .fault
        }
    }
}

protocol LoggerProtocol {
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int)
    func verbose(_ message: String, file: String, function: String, line: Int)
    func debug(_ message: String, file: String, function: String, line: Int)
    func info(_ message: String, file: String, function: String, line: Int)
    func warning(_ message: String, file: String, function: String, line: Int)
    func error(_ message: String, file: String, function: String, line: Int)
    func critical(_ message: String, file: String, function: String, line: Int)
}

// MARK: - Logger Implementation
final class Logger: LoggerProtocol {
    
    static let shared = Logger()
    
    private let subsystem = Bundle.main.bundleIdentifier ?? "CountryExplorer"
    private var osLogs: [String: OSLog] = [:]
    private let queue = DispatchQueue(label: "com.countryexplorer.logger", qos: .utility)
    
    var minimumLevel: LogLevel = BuildConfiguration.isDebug ? .verbose : .warning
    var isEnabled = true
    
    private init() {
        setupCategories()
    }
    
    private func setupCategories() {
        LogCategory.allCases.forEach { category in
            osLogs[category.rawValue] = OSLog(subsystem: subsystem, category: category.rawValue)
        }
    }
    
    func log(_ message: String,
             level: LogLevel = .info,
             file: String = #file,
             function: String = #function,
             line: Int = #line) {
        
        guard isEnabled, level.rawValue >= minimumLevel.rawValue else { return }
        
        let fileName = (file as NSString).lastPathComponent
        let timestamp = DateFormatter.iso8601Full.string(from: Date())
        let formattedMessage = "\(level.prefix) [\(timestamp)] [\(fileName):\(line)] \(function) - \(message)"
        
        queue.async { [weak self] in
            self?.writeLog(formattedMessage, level: level)
        }
    }
    
    private func writeLog(_ message: String, level: LogLevel) {
        // Console logging
        if AppEnvironment.current.loggingEnabled {
            print(message)
        }
        
        // OS Log
        let osLog = osLogs[LogCategory.general.rawValue] ?? .default
        os_log("%{public}@", log: osLog, type: level.osLogType, message)
        
        // File logging for production
        if AppEnvironment.current == .production {
            FileLogger.shared.write(message)
        }
        
        // Send to crash reporter for errors
        if level.rawValue >= LogLevel.error.rawValue {
            CrashReporter.shared.log(message, level: level)
        }
    }
    
    // MARK: - Convenience Methods
    
    func verbose(_ message: String,
                file: String = #file,
                function: String = #function,
                line: Int = #line) {
        log(message, level: .verbose, file: file, function: function, line: line)
    }
    
    func debug(_ message: String,
               file: String = #file,
               function: String = #function,
               line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    func info(_ message: String,
              file: String = #file,
              function: String = #function,
              line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    func warning(_ message: String,
                 file: String = #file,
                 function: String = #function,
                 line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    func error(_ message: String,
               file: String = #file,
               function: String = #function,
               line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
    
    func critical(_ message: String,
                  file: String = #file,
                  function: String = #function,
                  line: Int = #line) {
        log(message, level: .critical, file: file, function: function, line: line)
    }
}

enum LogCategory: String, CaseIterable {
    case general = "General"
    case network = "Network"
    case database = "Database"
    case ui = "UI"
    case analytics = "Analytics"
    case performance = "Performance"
}

final class FileLogger {
    static let shared = FileLogger()
    
    private let fileName = "app_logs.txt"
    private let maxFileSize: Int64 = 10 * 1024 * 1024
    private let fileManager = FileManager.default
    private var fileURL: URL?
    
    private init() {
        setupLogFile()
    }
    
    private func setupLogFile() {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory,
                                                        in: .userDomainMask).first else { return }
        
        fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        if !fileManager.fileExists(atPath: fileURL!.path) {
            fileManager.createFile(atPath: fileURL!.path, contents: nil)
        }
        
        checkFileSize()
    }
    
    func write(_ message: String) {
        guard let fileURL = fileURL else { return }
        
        let messageWithNewline = message + "\n"
        guard let data = messageWithNewline.data(using: .utf8) else { return }
        
        if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
            defer { fileHandle.closeFile() }
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
        }
    }
    
    private func checkFileSize() {
        guard let fileURL = fileURL,
              let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
              let fileSize = attributes[.size] as? Int64 else { return }
        
        if fileSize > maxFileSize {
            rotateLogFile()
        }
    }
    
    private func rotateLogFile() {
        guard let fileURL = fileURL else { return }
        
        let backupURL = fileURL.appendingPathExtension("backup")
        try? fileManager.removeItem(at: backupURL)
        try? fileManager.moveItem(at: fileURL, to: backupURL)
        fileManager.createFile(atPath: fileURL.path, contents: nil)
    }
}

extension Logger {
    func logNetworkRequest(_ request: URLRequest) {
        guard BuildConfiguration.isDebug else { return }
        
        var message = "🌐 Network Request:\n"
        message += "URL: \(request.url?.absoluteString ?? "nil")\n"
        message += "Method: \(request.httpMethod ?? "GET")\n"
        
        if let headers = request.allHTTPHeaderFields {
            message += "Headers: \(headers)\n"
        }
        
        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            message += "Body: \(bodyString)"
        }
        
        debug(message)
    }
    
    func logNetworkResponse(_ response: URLResponse?, data: Data?, error: Error?) {
        guard BuildConfiguration.isDebug else { return }
        
        var message = "🌐 Network Response:\n"
        
        if let httpResponse = response as? HTTPURLResponse {
            message += "Status Code: \(httpResponse.statusCode)\n"
            message += "Headers: \(httpResponse.allHeaderFields)"
        }
        
        if let data = data,
           let dataString = String(data: data, encoding: .utf8) {
            message += "\nData: \(dataString.prefix(1000))"
        }
        
        if let responseError = error {
            message += "\nError: \(responseError.localizedDescription)"
            self.error(message)
        } else {
            self.debug(message)
        }
    }
}

extension Logger {
    func measureTime<T>(operation: String, block: () throws -> T) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        defer {
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            debug("⏱ \(operation) took \(String(format: "%.3f", timeElapsed)) seconds")
        }
        return try block()
    }
}

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
}
