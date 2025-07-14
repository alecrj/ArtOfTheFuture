import SwiftUI

struct DebugPerformanceModifier: ViewModifier {
    let label: String
    let category: LogCategory
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                let tracker = DebugService.shared.startPerformanceTracking(operation: "View Load: \(label)", category: category)
                
                DispatchQueue.main.async {
                    tracker.finish()
                }
            }
    }
}

struct DebugGestureModifier: ViewModifier {
    let action: String
    let originalAction: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                DebugService.shared.trackUserAction(action)
                originalAction()
            }
    }
}

extension View {
    func debugPerformance(_ label: String, category: LogCategory = .performance) -> some View {
        self.modifier(DebugPerformanceModifier(label: label, category: category))
    }
    
    func debugGesture(_ action: String, perform: @escaping () -> Void) -> some View {
        self.modifier(DebugGestureModifier(action: action, originalAction: perform))
    }
}
