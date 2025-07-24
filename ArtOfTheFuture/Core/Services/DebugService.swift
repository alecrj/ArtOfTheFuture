// File: ArtOfTheFuture/Core/Services/DebugService.swift

import Foundation
import SwiftUI
import os.log

@MainActor
final class DebugService: ObservableObject {
    static let shared = DebugService()
    
    // MARK: - Published Properties
    @Published var logs: [DebugLog] = []
    @Published var isDebugMode: Bool = false
    @Published var logLevel: LogLevel = .info
    @Published var showDebugOverlay: Bool = false
    
    // MARK: - Private Properties
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ArtOfTheFuture", category: "DebugService")
    private let maxLogCount = 1000
    private var logFileURL: URL?
    
    // MARK: - Initialization
    private init() {
        setupLogFile()
        isDebugMode = isRunningInDebug()
    }
    
    // MARK: - Core Logging
    func log(
        _ message: String,
        level: LogLevel = .info,
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let debugLog = DebugLog(
            message: message,
            level: level,
            category: category,
            timestamp: Date(),
            file: fileName,
            function: function,
            line: line
        )
        
        logs.append(debugLog)
        if logs.count > maxLogCount {
            logs.removeFirst(logs.count - maxLogCount)
        }
        
        writeToSystemLog(debugLog)
        if isDebugMode { writeToFile(debugLog) }
        if isDebugMode {
            print("🔧 [\(level.emoji) \(category.rawValue)] \(fileName):\(line) - \(message)")
        }
    }
    
    // MARK: - Convenience Methods
    func debug(
        _ message: String,
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .debug, category: category, file: file, function: function, line: line)
    }
    
    func info(
        _ message: String,
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .info, category: category, file: file, function: function, line: line)
    }
    
    func warning(
        _ message: String,
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .warning, category: category, file: file, function: function, line: line)
    }
    
    func error(
        _ message: String,
        error: Error? = nil,
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        var fullMessage = message
        if let error = error {
            fullMessage += " - Error: \(error.localizedDescription)"
        }
        log(fullMessage, level: .error, category: category, file: file, function: function, line: line)
    }
    
    func critical(
        _ message: String,
        error: Error? = nil,
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        var fullMessage = message
        if let error = error {
            fullMessage += " - Critical Error: \(error.localizedDescription)"
        }
        log(fullMessage, level: .critical, category: category, file: file, function: function, line: line)
    }
    
    // MARK: - Performance Tracking
    func startPerformanceTracking(operation: String, category: LogCategory = .performance) -> PerformanceTracker {
        let tracker = PerformanceTracker(operation: operation, category: category)
        debug("Started performance tracking: \(operation)", category: category)
        return tracker
    }
    
    // MARK: - User Action Tracking
    func trackUserAction(_ action: String, details: [String: Any]? = nil) {
        var message = "User Action: \(action)"
        if let details = details {
            message += " - " + details.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        }
        log(message, category: .userAction)
    }
    
    // MARK: - Learning System Specific
    func logLessonEvent(_ event: LessonEvent, lessonId: String, details: [String: Any]? = nil) {
        var message = "Lesson \(event.rawValue): \(lessonId)"
        if let details = details {
            message += " - " + details.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        }
        log(message, category: .learning)
    }
    
    func logProgressEvent(_ event: ProgressEvent, details: [String: Any]? = nil) {
        var message = "Progress \(event.rawValue)"
        if let details = details {
            message += " - " + details.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        }
        log(message, category: .progress)
    }
    func logLearningEvent(_ event: LearningAnalyticsEvent, details: [String: Any]? = nil) {
        var message = "Learning Event: \(event.rawValue)"
        if let details = details {
            message += " - " + details.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        }
        log(message, category: .learning)
    }

    enum LearningAnalyticsEvent: String {
        case sectionViewed = "SectionViewed"
        case unitOpened = "UnitOpened"
    }

    
    // MARK: - Debug Controls
    func toggleDebugOverlay() {
        showDebugOverlay.toggle()
        debug("Debug overlay toggled: \(showDebugOverlay)")
    }
    
    func clearLogs() {
        logs.removeAll()
        debug("Debug logs cleared")
    }
    
    func exportLogs() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return logs.map {
            "[\(formatter.string(from: $0.timestamp))] [\($0.level.rawValue.uppercased())] [\($0.category.rawValue)] \($0.file):\($0.line) - \($0.message)"
        }.joined(separator: "\n")
    }
    
    // MARK: - Private Methods
    private func isRunningInDebug() -> Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }
    
    private func setupLogFile() {
        guard let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        logFileURL = docs.appendingPathComponent("app_debug.log")
    }
    
    private func writeToSystemLog(_ log: DebugLog) {
        let osType: OSLogType = {
            switch log.level {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            case .critical: return .fault
            }
        }()
        logger.log(level: osType, "\(log.category.rawValue): \(log.message)")
    }
    
    private func writeToFile(_ log: DebugLog) {
        guard let url = logFileURL else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let entry = "[\(formatter.string(from: log.timestamp))] [\(log.level.rawValue)] [\(log.category.rawValue)] \(log.file):\(log.line) - \(log.message)\n"
        if FileManager.default.fileExists(atPath: url.path),
           let handle = try? FileHandle(forWritingTo: url) {
            handle.seekToEndOfFile()
            handle.write(entry.data(using: .utf8)!)
            handle.closeFile()
        } else {
            try? entry.write(to: url, atomically: true, encoding: .utf8)
        }
    }
}

// MARK: - Supporting Types

struct DebugLog: Identifiable {
    let id = UUID()
    let message: String
    let level: LogLevel
    let category: LogCategory
    let timestamp: Date
    let file: String
    let function: String
    let line: Int
}

enum LogLevel: String, CaseIterable {
    case debug, info, warning, error, critical
    var emoji: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        case .critical: return "🚨"
        }
    }
    var color: Color {
        switch self {
        case .debug: return .gray
        case .info: return .blue
        case .warning: return .orange
        case .error: return .red
        case .critical: return .purple
        }
    }
}

enum LogCategory: String, CaseIterable {
    case general, learning, progress, userAction, performance, network, drawing, ui, data
}

enum LessonEvent: String {
    case started = "Started", completed = "Completed", failed = "Failed",
         paused = "Paused", resumed = "Resumed", stepCompleted = "StepCompleted"
}

enum ProgressEvent: String {
    case xpGained = "XPGained", levelUp = "LevelUp", achievementUnlocked = "AchievementUnlocked",
         streakUpdated = "StreakUpdated", goalCompleted = "GoalCompleted"
}

class PerformanceTracker {
    private let startTime = CFAbsoluteTimeGetCurrent()
    private let operation: String
    private let category: LogCategory
    
    init(operation: String, category: LogCategory = .performance) {
        self.operation = operation
        self.category = category
    }
    
    func finish() {
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        let formatted = String(format: "%.3f", duration)
        Task { @MainActor in
            DebugService.shared.debug(
                "Performance: \(operation) completed in \(formatted)s",
                category: category
            )
        }
    }
}
