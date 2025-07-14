// File 4: ArtOfTheFuture/Core/Debug/DebugControls.swift

import SwiftUI

struct DebugControlPanel: View {
    @StateObject private var debugService = DebugService.shared
    @State private var showingLogs = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Debug Controls")
                .font(.headline)
            
            VStack(spacing: 12) {
                // Debug Mode Toggle
                HStack {
                    Text("Debug Mode")
                    Spacer()
                    Toggle("", isOn: $debugService.isDebugMode)
                }
                
                // Log Level Picker
                HStack {
                    Text("Log Level")
                    Spacer()
                    Picker("Log Level", selection: $debugService.logLevel) {
                        ForEach(LogLevel.allCases, id: \.self) { level in
                            Text(level.rawValue.capitalized).tag(level)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Quick Actions
                Button("View Debug Logs") {
                    showingLogs = true
                }
                .buttonStyle(.bordered)
                
                Button("Clear All Logs") {
                    debugService.clearLogs()
                }
                .buttonStyle(.bordered)
                
                Button("Test Log Messages") {
                    testLogMessages()
                }
                .buttonStyle(.bordered)
                
                // Progress Testing
                Button("Test Progress Events") {
                    testProgressEvents()
                }
                .buttonStyle(.bordered)
                
                Button("Test Learning Events") {
                    testLearningEvents()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .sheet(isPresented: $showingLogs) {
            DebugOverlay()
        }
    }
    
    private func testLogMessages() {
        debugService.debug("This is a debug message")
        debugService.info("This is an info message")
        debugService.warning("This is a warning message")
        debugService.error("This is an error message")
        debugService.critical("This is a critical message")
    }
    
    private func testProgressEvents() {
        debugService.logProgressEvent(.xpGained, details: ["amount": 100])
        debugService.logProgressEvent(.levelUp, details: ["newLevel": 5])
        debugService.logProgressEvent(.achievementUnlocked, details: ["achievement": "First Drawing"])
    }
    
    private func testLearningEvents() {
        debugService.logLessonEvent(.started, lessonId: "lesson_001")
        debugService.logLessonEvent(.stepCompleted, lessonId: "lesson_001", details: ["step": 1])
        debugService.logLessonEvent(.completed, lessonId: "lesson_001", details: ["score": 85])
    }
}
