import SwiftUI

struct UnitDetailView: View {
    let unit: LearningUnit
    @ObservedObject var viewModel: LearningTreeViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var lessons: [Lesson] = []
    @State private var showContent = false
    @State private var selectedLesson: Lesson?
    @State private var isLoading = true
    
    private var unitColor: Color {
        if unit.sectionId.contains("beginner") {
            return .green
        } else if unit.sectionId.contains("intermediate") {
            return .blue
        } else {
            return .purple
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Hero header
                        UnitHeroHeader(
                            unit: unit,
                            unitColor: unitColor,
                            animated: showContent
                        )
                        
                        // Lessons list
                        VStack(spacing: 0) {
                            if isLoading {
                                LoadingLessonsView()
                                    .padding(.top, 40)
                            } else if lessons.isEmpty {
                                EmptyLessonsView()
                                    .padding(.top, 40)
                            } else {
                                ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                                    LessonRowView(
                                        lesson: lesson,
                                        index: index,
                                        unit: unit,
                                        unitColor: unitColor,
                                        completedLessons: viewModel.completedLessons,
                                        showContent: showContent,
                                        onTap: {
                                            if isLessonUnlocked(index: index) {
                                                selectedLesson = lesson
                                            } else {
                                                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                                            }
                                        }
                                    )
                                }
                                
                                // Bottom padding
                                Color.clear.frame(height: 100)
                            }
                        }
                        .padding(.top, 20)
                    }
                }
                
                // Close button
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundStyle(.white, Color.black.opacity(0.3))
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 60)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loadLessons()
                withAnimation(.spring(response: 0.6).delay(0.2)) {
                    showContent = true
                }
            }
            .sheet(item: $selectedLesson) { lesson in
                // Navigate to lesson detail
                NavigationView {
                    Text("Lesson: \(lesson.title)")
                        .navigationTitle(lesson.title)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") { selectedLesson = nil }
                            }
                        }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func loadLessons() {
        Task {
            isLoading = true
            
            do {
                // Get all lessons and filter by unit
                let allLessons = try await LessonService.shared.getAllLessons()
                
                // Filter and sort lessons based on unit order
                let unitLessons = allLessons.filter { unit.lessons.contains($0.id) }
                    .sorted { lesson1, lesson2 in
                        let index1 = unit.lessons.firstIndex(of: lesson1.id) ?? Int.max
                        let index2 = unit.lessons.firstIndex(of: lesson2.id) ?? Int.max
                        return index1 < index2
                    }
                
                await MainActor.run {
                    self.lessons = unitLessons
                    self.isLoading = false
                }
            } catch {
                print("Failed to load lessons: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    private func isLessonUnlocked(index: Int) -> Bool {
        // First lesson is always unlocked if unit is unlocked
        if index == 0 {
            return unit.isUnlocked
        }
        
        // Check if previous lesson is completed
        if index > 0 && index - 1 < lessons.count {
            let previousLesson = lessons[index - 1]
            return viewModel.completedLessons.contains(previousLesson.id)
        }
        
        return false
    }
}

// MARK: - Unit Hero Header
struct UnitHeroHeader: View {
    let unit: LearningUnit
    let unitColor: Color
    let animated: Bool
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    unitColor.opacity(0.3),
                    unitColor.opacity(0.1),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 300)
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Large icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [unitColor.opacity(0.3), unitColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(animated ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6).delay(0.2), value: animated)
                    
                    Image(systemName: unit.iconName)
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [unitColor, unitColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(animated ? 1.0 : 0.0)
                        .rotationEffect(.degrees(animated ? 0 : -180))
                        .animation(.spring(response: 0.8).delay(0.3), value: animated)
                }
                
                // Unit info
                VStack(spacing: 8) {
                    Text(unit.title)
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    
                    Text(unit.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .opacity(animated ? 1.0 : 0.0)
                .offset(y: animated ? 0 : 20)
                .animation(.spring(response: 0.6).delay(0.4), value: animated)
                
                // Progress stats
                HStack(spacing: 30) {
                    StatBadge(
                        value: "\(unit.completedLessons)",
                        label: "Completed",
                        color: .green
                    )
                    
                    StatBadge(
                        value: "\(unit.lessons.count)",
                        label: "Total",
                        color: unitColor
                    )
                    
                    StatBadge(
                        value: "\(unit.lessons.count * 10)",
                        label: "XP",
                        color: .orange
                    )
                }
                .scaleEffect(animated ? 1.0 : 0.8)
                .opacity(animated ? 1.0 : 0.0)
                .animation(.spring(response: 0.6).delay(0.5), value: animated)
            }
            .padding(.top, 100)
        }
        .frame(height: 300)
    }
}

// MARK: - Lesson Node
struct LessonNode: View {
    let lesson: Lesson
    let index: Int
    let isUnlocked: Bool
    let isCompleted: Bool
    let unitColor: Color
    let animated: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var showTooltip = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                ProgressIndicator(
                    isCompleted: isCompleted,
                    isUnlocked: isUnlocked,
                    index: index,
                    unitColor: unitColor
                )
                .scaleEffect(isPressed ? 0.9 : 1.0)
                
                LessonInfo(
                    lesson: lesson,
                    isUnlocked: isUnlocked,
                    showTooltip: showTooltip,
                    unitColor: unitColor
                )
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundColor(isUnlocked ? .secondary : Color(.systemGray5))
                    .opacity(isUnlocked ? 1.0 : 0.5)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: isUnlocked ? unitColor.opacity(0.1) : Color.clear,
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isUnlocked ? unitColor.opacity(0.2) : Color.clear,
                        lineWidth: 1
                    )
            )
            .padding(.horizontal, 20)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
            if !isUnlocked && pressing {
                withAnimation(.spring(response: 0.3)) {
                    showTooltip = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.spring(response: 0.3)) {
                        showTooltip = false
                    }
                }
            }
        }, perform: {})
    }
}

// MARK: - Progress Indicator
struct ProgressIndicator: View {
    let isCompleted: Bool
    let isUnlocked: Bool
    let index: Int
    let unitColor: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    isUnlocked
                        ? (isCompleted ? unitColor.opacity(0.2) : Color(.systemGray5))
                        : Color(.systemGray6)
                )
                .frame(width: 70, height: 70)
            
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 35))
                    .foregroundColor(unitColor)
                    .transition(.scale.combined(with: .opacity))
            } else if isUnlocked {
                Text("\(index + 1)")
                    .font(.title2.bold())
                    .foregroundColor(unitColor)
            } else {
                Image(systemName: "lock.fill")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Lesson Info
struct LessonInfo: View {
    let lesson: Lesson
    let isUnlocked: Bool
    let showTooltip: Bool
    let unitColor: Color
    
    private var difficultyLevel: Int {
        switch lesson.difficulty.rawValue {
        case "Easy": return 1
        case "Medium": return 2
        case "Hard": return 3
        default: return 0
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(lesson.title)
                .font(.headline)
                .foregroundColor(isUnlocked ? .primary : .secondary)
                .lineLimit(2)
            
            HStack(spacing: 16) {
                Label("\(lesson.estimatedMinutes) min", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label("\(lesson.xpReward) XP", systemImage: "star.fill")
                    .font(.caption)
                    .foregroundColor(isUnlocked ? .orange : .secondary)
                
                HStack(spacing: 2) {
                    ForEach(0..<3) { i in
                        Image(systemName: "circle.fill")
                            .font(.system(size: 4))
                            .foregroundColor(
                                i < difficultyLevel
                                    ? (isUnlocked ? unitColor : .secondary)
                                    : Color(.systemGray5)
                            )
                    }
                }
            }
            
            if !isUnlocked && showTooltip {
                Text("Complete previous lesson to unlock")
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.orange.opacity(0.1))
                    )
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

// MARK: - Connection Line
struct ConnectionLine: View {
    let isCompleted: Bool
    let color: Color
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        isCompleted ? color.opacity(0.3) : Color(.systemGray5),
                        isCompleted ? color.opacity(0.1) : Color(.systemGray6)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 4, height: 30)
            .padding(.leading, 55)
    }
}

// MARK: - Helper Views
struct StatBadge: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
                .foregroundColor(color)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct LoadingLessonsView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading lessons...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(60)
    }
}

struct EmptyLessonsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No lessons found")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("This unit doesn't have any lessons yet")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(60)
    }
}

private struct LessonRowView: View {
    let lesson: Lesson // Fixed from LessonDob to Lesson
    let index: Int
    let unit: LearningUnit
    let unitColor: Color
    let completedLessons: Set<String>
    let showContent: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if index > 0 {
                ConnectionLine(
                    isCompleted: completedLessons.contains(unit.lessons[safe: index - 1] ?? ""),
                    color: unitColor
                )
            }

            LessonNode(
                lesson: lesson,
                index: index,
                isUnlocked: isLessonUnlocked,
                isCompleted: completedLessons.contains(lesson.id),
                unitColor: unitColor,
                animated: showContent,
                action: onTap
            )
            .scaleEffect(showContent ? 1.0 : 0.8)
            .opacity(showContent ? 1.0 : 0.0)
            .animation(
                .spring(response: 0.5)
                    .delay(Double(index) * 0.1),
                value: showContent
            )
        }
    }

    private var isLessonUnlocked: Bool {
        if index == 0 {
            return unit.isUnlocked
        }
        let previousLessonId = unit.lessons[safe: index - 1]
        return previousLessonId.map { completedLessons.contains($0) } ?? false
    }
}

// Safe subscript extension
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
