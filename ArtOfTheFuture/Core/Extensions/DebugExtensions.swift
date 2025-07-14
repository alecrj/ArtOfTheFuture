// File: ArtOfTheFuture/Core/Extensions/DebugExtensions.swift

import SwiftUI

// MARK: - View Extensions for Easy Debugging
extension View {
    /// Add debug logging when view appears
    func debugOnAppear(_ message: String, category: LogCategory = .ui) -> some View {
        self.onAppear {
            DebugService.shared.debug("View Appeared: \(message)", category: category)
        }
    }
    
    /// Add debug logging when view disappears
    func debugOnDisappear(_ message: String, category: LogCategory = .ui) -> some View {
        self.onDisappear {
            DebugService.shared.debug("View Disappeared: \(message)", category: category)
        }
    }
    
    /// Track user interactions
    func debugOnTapGesture(_ message: String, category: LogCategory = .userAction, action: @escaping () -> Void) -> some View {
        self.onTapGesture {
            DebugService.shared.trackUserAction("Tap: \(message)")
            action()
        }
    }
    
    /// Add debug overlay when in debug mode
    func withDebugOverlay() -> some View {
        self.overlay(
            DebugService.shared.showDebugOverlay ? AnyView(DebugOverlay()) : AnyView(EmptyView())
        )
    }
}

// MARK: - Error Extensions
extension Error {
    func logError(
        message: String = "Error occurred",
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        Task { @MainActor in
            DebugService.shared.error(
                message,
                error: self,
                category: category,
                file: file,
                function: function,
                line: line
            )
        }
    }
}
