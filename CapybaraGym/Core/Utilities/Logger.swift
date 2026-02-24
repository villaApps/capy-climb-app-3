//
//  Logger.swift
//  CapybaraGym
//
//  Logging utility for debugging
//

import Foundation
import OSLog

// MARK: - Log Level
public enum LogLevel: String, CaseIterable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    
    var emoji: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
    
    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        }
    }
}

// MARK: - Logger
public struct Logger {
    
    // MARK: - Properties
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.capybara.gym"
    private static let osLog = OSLog(subsystem: subsystem, category: "CapybaraGym")
    
    /// Minimum log level (can be changed at runtime)
    public static var minimumLogLevel: LogLevel = .debug
    
    /// Enable/disable logging to console
    public static var isLoggingEnabled: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    // MARK: - Logging Methods
    
    /// Log debug message
    public static func debug(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    /// Log info message
    public static func info(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    /// Log warning message
    public static func warning(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    /// Log error message
    public static func error(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .error, file: file, function: function, line: line)
    }
    
    /// Log error with error object
    public static func error(
        _ error: Error,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(error.localizedDescription, level: .error, file: file, function: function, line: line)
    }
    
    // MARK: - Private Methods
    
    private static func log(
        _ message: String,
        level: LogLevel,
        file: String,
        function: String,
        line: Int
    ) {
        guard isLoggingEnabled else { return }
        
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "\(level.emoji) [\(level.rawValue)] [\(fileName):\(line)] \(function) - \(message)"
        
        // Log to OSLog
        os_log("%{public}@", log: osLog, type: level.osLogType, logMessage)
        
        // Also print to console in debug builds
        #if DEBUG
        print(logMessage)
        #endif
    }
}

// MARK: - Network Logger
public struct NetworkLogger {
    
    /// Log network request
    public static func logRequest(_ request: URLRequest) {
        guard Logger.isLoggingEnabled else { return }
        
        var log = "\n📤 === REQUEST ===\n"
        log += "URL: \(request.url?.absoluteString ?? "N/A")\n"
        log += "Method: \(request.httpMethod ?? "N/A")\n"
        log += "Headers: \(request.allHTTPHeaderFields ?? [:])\n"
        
        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            log += "Body: \(bodyString)\n"
        }
        
        log += "================\n"
        
        Logger.debug(log)
    }
    
    /// Log network response
    public static func logResponse(_ response: URLResponse?, data: Data?, error: Error?) {
        guard Logger.isLoggingEnabled else { return }
        
        var log = "\n📥 === RESPONSE ===\n"
        
        if let httpResponse = response as? HTTPURLResponse {
            log += "Status Code: \(httpResponse.statusCode)\n"
            log += "Headers: \(httpResponse.allHeaderFields)\n"
        }
        
        if let data = data,
           let dataString = String(data: data, encoding: .utf8) {
            log += "Body: \(dataString.prefix(1000))\n"
        }
        
        if let error = error {
            log += "Error: \(error.localizedDescription)\n"
        }
        
        log += "================\n"
        
        if let error = error {
            Logger.error(log)
        } else {
            Logger.debug(log)
        }
    }
}
