// MARK: - Lessons View - Entry Point
// File: ArtOfTheFuture/Features/Lessons/Views/LessonsView.swift

import SwiftUI

struct LessonsView: View {
    var body: some View {
        LearningTreeView()
            .preferredColorScheme(.none) // Respect system settings
    }
}

#Preview {
    LessonsView()
}
