// MARK: - App-Wide Debugging System
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
    func log(_ message: String, level: LogLevel = .info, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
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
        
        // Add to in-memory logs
        logs.append(debugLog)
        
        // Maintain log count limit
        if logs.count > maxLogCount {
            logs.removeFirst(logs.count - maxLogCount)
        }
        
        // Write to system log
        writeToSystemLog(debugLog)
        
        // Write to file in debug mode
        if isDebugMode {
            writeToFile(debugLog)
        }
        
        // Print to console in debug
        if isDebugMode {
            print("🔧 [\(level.emoji) \(category.rawValue)] \(fileName):\(line) - \(message)")
        }
    }
    
    // MARK: - Convenience Methods
    func debug(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, category: category, file: file, function: function, line: line)
    }
    
    func info(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, category: category, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, category: category, file: file, function: function, line: line)
    }
    
    func error(_ message: String, error: Error? = nil, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
        var fullMessage = message
        if let error = error {
            fullMessage += " - Error: \(error.localizedDescription)"
        }
        log(fullMessage, level: .error, category: category, file: file, function: function, line: line)
    }
    
    func critical(_ message: String, error: Error? = nil, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
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
            let detailsString = details.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
            message += " - Details: \(detailsString)"
        }
        log(message, category: .userAction)
    }
    
    // MARK: - Learning System Specific
    func logLessonEvent(_ event: LessonEvent, lessonId: String, details: [String: Any]? = nil) {
        var message = "Lesson \(event.rawValue): \(lessonId)"
        if let details = details {
            let detailsString = details.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
            message += " - \(detailsString)"
        }
        log(message, category: .learning)
    }
    
    func logProgressEvent(_ event: ProgressEvent, details: [String: Any]? = nil) {
        var message = "Progress \(event.rawValue)"
        if let details = details {
            let detailsString = details.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
            message += " - \(detailsString)"
        }
        log(message, category: .progress)
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
        
        return logs.map { log in
            "[\(formatter.string(from: log.timestamp))] [\(log.level.rawValue.uppercased())] [\(log.category.rawValue)] \(log.file):\(log.line) - \(log.message)"
        }.joined(separator: "\n")
    }
    
    // MARK: - Private Methods
    private func isRunningInDebug() -> Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    private func setupLogFile() {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        logFileURL = documentsPath.appendingPathComponent("app_debug.log")
    }
    
    private func writeToSystemLog(_ log: DebugLog) {
        let osLogType: OSLogType = switch log.level {
        case .debug: .debug
        case .info: .info
        case .warning: .default
        case .error: .error
        case .critical: .fault
        }
        
        logger.log(level: osLogType, "\(log.category.rawValue): \(log.message)")
    }
    
    private func writeToFile(_ log: DebugLog) {
        guard let logFileURL = logFileURL else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let logEntry = "[\(formatter.string(from: log.timestamp))] [\(log.level.rawValue)] [\(log.category.rawValue)] \(log.file):\(log.line) - \(log.message)\n"
        
        if FileManager.default.fileExists(atPath: logFileURL.path) {
            if let handle = try? FileHandle(forWritingTo: logFileURL) {
                handle.seekToEndOfFile()
                handle.write(logEntry.data(using: .utf8) ?? Data())
                handle.closeFile()
            }
        } else {
            try? logEntry.write(to: logFileURL, atomically: true, encoding: .utf8)
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
    case debug = "debug"
    case info = "info"
    case warning = "warning"
    case error = "error"
    case critical = "critical"
    
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
    case general = "General"
    case learning = "Learning"
    case progress = "Progress"
    case userAction = "UserAction"
    case performance = "Performance"
    case network = "Network"
    case drawing = "Drawing"
    case ui = "UI"
    case data = "Data"
}

enum LessonEvent: String {
    case started = "Started"
    case completed = "Completed"
    case failed = "Failed"
    case paused = "Paused"
    case resumed = "Resumed"
    case stepCompleted = "StepCompleted"
}

enum ProgressEvent: String {
    case xpGained = "XPGained"
    case levelUp = "LevelUp"
    case achievementUnlocked = "AchievementUnlocked"
    case streakUpdated = "StreakUpdated"
    case goalCompleted = "GoalCompleted"
}

class PerformanceTracker {
    private let startTime: CFAbsoluteTime
    private let operation: String
    private let category: LogCategory
    
    init(operation: String, category: LogCategory = .performance) {
        self.operation = operation
        self.category = category
        self.startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func finish() {
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        DebugService.shared.debug("Performance: \(operation) completed in \(String(format: "%.3f", duration))s", category: category)
    }
}

// MARK: - Debug Overlay View
struct DebugOverlay: View {
    @StateObject private var debugService = DebugService.shared
    @State private var selectedCategory: LogCategory?
    @State private var selectedLevel: LogLevel?
    
    var filteredLogs: [DebugLog] {
        var logs = debugService.logs
        
        if let category = selectedCategory {
            logs = logs.filter { $0.category == category }
        }
        
        if let level = selectedLevel {
            logs = logs.filter { $0.level == level }
        }
        
        return logs.reversed() // Show newest first
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(LogCategory.allCases, id: \.self) { category in
                            Button(category.rawValue) {
                                selectedCategory = selectedCategory == category ? nil : category
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                            .tint(selectedCategory == category ? .blue : .gray)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Logs List
                List(filteredLogs) { log in
                    LogRowView(log: log)
                }
            }
            .navigationTitle("Debug Console")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear") {
                        debugService.clearLogs()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        debugService.toggleDebugOverlay()
                    }
                }
            }
        }
    }
}

struct LogRowView: View {
    let log: DebugLog
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(log.level.emoji)
                Text(log.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(log.level.color.opacity(0.2))
                    .cornerRadius(4)
                
                Spacer()
                
                Text(timeFormatter.string(from: log.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(log.message)
                .font(.footnote)
            
            Text("\(log.file):\(log.line)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}
