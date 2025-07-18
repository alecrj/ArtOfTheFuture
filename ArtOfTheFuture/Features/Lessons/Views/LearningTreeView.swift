// MARK: - Art-Focused Learning Tree View (Updated for existing models)
// File: ArtOfTheFuture/Features/Lessons/Views/LearningTreeView.swift

import SwiftUI

struct LearningTreeView: View {
    @StateObject private var viewModel = LearningTreeViewModel()
    @State private var selectedUnit: LearningUnit?
    @State private var selectedLesson: Lesson?
    @State private var scrollViewOffset: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Artistic background
                ArtLearningBackground()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Hero header
                        learningHeroSection
                        
                        // Overall progress
                        overallProgressCard
                        
                        // Learning sections
                        ForEach(viewModel.learningTree.sections) { section in
                            sectionView(section)
                        }
                        
                        // Bottom spacing
                        Color.clear.frame(height: 100)
                    }
                }
                .navigationTitle("Learning Path")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { viewModel.refreshTree() }) {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedUnit) { unit in
            ArtLearningUnitDetailView(unit: unit) { lesson in
                selectedLesson = lesson
            }
        }
        .fullScreenCover(item: $selectedLesson) { lesson in
            LessonPlayerView(lesson: lesson)
        }
        .task {
            await viewModel.loadTree()
        }
    }
    
    // MARK: - Hero Section
    
    private var learningHeroSection: some View {
        VStack(spacing: 20) {
            // Animated illustration
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.purple.opacity(0.3),
                                    Color.pink.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: CGFloat(100 + index * 30), height: CGFloat(100 + index * 30))
                        .blur(radius: 10)
                        .offset(x: CGFloat(index * 10), y: CGFloat(index * -5))
                }
                
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .frame(height: 150)
            
            VStack(spacing: 8) {
                Text("Master the Art")
                    .font(.largeTitle.bold())
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("\(viewModel.learningTree.totalLessons) lessons to explore")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Overall Progress Card
    
    private var overallProgressCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Overall Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(viewModel.learningTree.overallProgress * 100))%")
                        .font(.title2.bold())
                }
                
                Spacer()
                
                // Progress circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: viewModel.learningTree.overallProgress)
                        .stroke(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text("\(viewModel.learningTree.completedLessons)")
                            .font(.headline)
                        Text("Done")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Stats
            HStack(spacing: 20) {
                StatBadge(
                    value: "\(viewModel.completedLessons.count)",
                    label: "Completed",
                    color: .green
                )
                
                StatBadge(
                    value: "Lvl \(viewModel.currentLevel)",
                    label: "Level",
                    color: .purple
                )
                
                StatBadge(
                    value: "\(viewModel.totalXP)",
                    label: "Total XP",
                    color: .orange
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .purple.opacity(0.1), radius: 10, y: 5)
        )
        .padding(.horizontal)
    }
    
    // MARK: - Section View
    
    private func sectionView(_ section: LearningSection) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                Image(systemName: section.iconName)
                    .font(.title2)
                    .foregroundColor(section.color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(section.title)
                        .font(.title3.bold())
                    
                    Text("\(section.completedLessons)/\(section.totalLessons) lessons")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Section progress
                CircularProgress(
                    progress: section.progress,
                    color: section.color,
                    size: 40,
                    lineWidth: 4
                )
            }
            .padding(.horizontal)
            
            // Units in section
            VStack(spacing: 0) {
                ForEach(Array(section.units.enumerated()), id: \.element.id) { index, unit in
                    VStack(spacing: 0) {
                        // Connection line (except for first unit)
                        if index > 0 {
                            PathConnection(
                                isUnlocked: unit.isUnlocked,
                                progress: unit.progress,
                                color: section.color
                            )
                        }
                        
                        // Unit card
                        ArtisticUnitCard(
                            unit: unit,
                            section: section,
                            index: index
                        ) {
                            selectedUnit = unit
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .padding(.vertical)
    }
}

// MARK: - Supporting Components

struct ArtLearningBackground: View {
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.97, blue: 1.0),
                    Color(red: 0.97, green: 0.98, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Artistic elements
            GeometryReader { geometry in
                // Paint strokes
                ForEach(0..<5) { index in
                    PaintStroke()
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat(index) * geometry.size.height / 5
                        )
                        .opacity(0.02)
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct PaintStroke: View {
    let width = CGFloat.random(in: 100...300)
    let height = CGFloat.random(in: 20...50)
    let rotation = Double.random(in: -45...45)
    let color = [Color.purple, Color.pink, Color.blue, Color.orange].randomElement()!
    
    var body: some View {
        Capsule()
            .fill(color)
            .frame(width: width, height: height)
            .rotationEffect(.degrees(rotation))
            .blur(radius: 20)
    }
}

struct PathConnection: View {
    let isUnlocked: Bool
    let progress: Double
    let color: Color
    
    var body: some View {
        ZStack {
            // Background line
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 4, height: 60)
            
            // Progress line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: isUnlocked ? [color, color.opacity(0.6)] : [Color.gray.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 4, height: 60 * progress)
                .offset(y: 30 * (1 - progress))
            
            // Decorative dots
            VStack(spacing: 15) {
                ForEach(0..<3) { _ in
                    Circle()
                        .fill(isUnlocked ? color.opacity(0.3) : Color.gray.opacity(0.2))
                        .frame(width: 8, height: 8)
                }
            }
        }
    }
}

struct ArtisticUnitCard: View {
    let unit: LearningUnit
    let section: LearningSection
    let index: Int
    @StateObject private var viewModel = LearningTreeViewModel()
    
    @State private var isPressed = false
    @State private var showingGlow = false
    
    var action: () -> Void
    
    private var isCurrentUnit: Bool {
        // Check if this is the current unit user should work on
        if !unit.isUnlocked { return false }
        return unit.progress > 0 && unit.progress < 1.0
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Unit icon with artistic background
                ZStack {
                    // Animated background for current unit
                    if isCurrentUnit {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        section.color.opacity(0.3),
                                        section.color.opacity(0.2),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 50
                                )
                            )
                            .frame(width: 100, height: 100)
                            .blur(radius: 10)
                            .scaleEffect(showingGlow ? 1.2 : 1.0)
                            .animation(
                                .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                                value: showingGlow
                            )
                    }
                    
                    // Icon circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: unit.isUnlocked ?
                                    [section.color, section.color.opacity(0.7)] :
                                    [Color.gray.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .shadow(
                            color: unit.isUnlocked ? section.color.opacity(0.3) : .clear,
                            radius: 10,
                            y: 5
                        )
                    
                    Image(systemName: unit.iconName)
                        .font(.title)
                        .foregroundColor(.white)
                    
                    // Progress ring
                    Circle()
                        .trim(from: 0, to: unit.progress)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.8), .white.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 76, height: 76)
                        .rotationEffect(.degrees(-90))
                    
                    // Lock overlay
                    if !unit.isUnlocked {
                        Circle()
                            .fill(Color.black.opacity(0.5))
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: "lock.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(unit.title)
                        .font(.headline)
                        .foregroundColor(unit.isUnlocked ? .primary : .secondary)
                    
                    Text(unit.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Progress info
                    HStack(spacing: 12) {
                        Label("\(unit.completedLessons)/\(unit.lessons.count)", systemImage: "book.fill")
                            .font(.caption)
                            .foregroundColor(unit.isUnlocked ? section.color : .gray)
                        
                        // Calculate XP for this unit
                        let unitXP = unit.completedLessons * 50
                        let totalUnitXP = unit.lessons.count * 50
                        
                        Label("\(unitXP)/\(totalUnitXP) XP", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                // Arrow indicator
                Image(systemName: unit.isUnlocked ? "arrow.right.circle.fill" : "lock.circle.fill")
                    .font(.title2)
                    .foregroundColor(unit.isUnlocked ? section.color.opacity(0.5) : .gray.opacity(0.3))
                    .scaleEffect(isPressed ? 0.8 : 1.0)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .shadow(
                        color: isCurrentUnit ? section.color.opacity(0.2) : .black.opacity(0.05),
                        radius: isCurrentUnit ? 15 : 10,
                        y: 5
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        isCurrentUnit ?
                        LinearGradient(
                            colors: [section.color.opacity(0.5), section.color.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(colors: [Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: isCurrentUnit ? 2 : 0
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .disabled(!unit.isUnlocked)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        } perform: {}
        .onAppear {
            if isCurrentUnit {
                showingGlow = true
            }
        }
    }
}

struct StatBadge: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline.bold())
                .foregroundColor(color)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CircularProgress: View {
    let progress: Double
    let color: Color
    let size: CGFloat
    let lineWidth: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
            
            Text("\(Int(progress * 100))%")
                .font(.caption2.bold())
                .foregroundColor(color)
        }
    }
}

// MARK: - Unit Detail View
struct ArtLearningUnitDetailView: View {
    let unit: LearningUnit
    let onLessonSelect: (Lesson) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var lessons: [Lesson] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Unit Header
                    VStack(spacing: 16) {
                        Image(systemName: unit.iconName)
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text(unit.title)
                            .font(.title.bold())
                        
                        Text(unit.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                    
                    // Progress info
                    HStack(spacing: 40) {
                        VStack(spacing: 4) {
                            Text("\(unit.completedLessons)")
                                .font(.title2.bold())
                            Text("Completed")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(unit.lessons.count)")
                                .font(.title2.bold())
                            Text("Total")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(Int(unit.progress * 100))%")
                                .font(.title2.bold())
                                .foregroundColor(.purple)
                            Text("Progress")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.purple.opacity(0.1))
                    )
                    .padding(.horizontal)
                    
                    // Lessons List
                    VStack(spacing: 12) {
                        ForEach(Array(unit.lessons.enumerated()), id: \.element) { index, lessonId in
                            if let lesson = lessons.first(where: { $0.id == lessonId }) {
                                ArtLessonRow(
                                    lesson: lesson,
                                    index: index + 1,
                                    isCompleted: unit.completedLessonIds.contains(lessonId),
                                    isUnlocked: index == 0 || unit.completedLessonIds.contains(unit.lessons[max(0, index - 1)])
                                ) {
                                    onLessonSelect(lesson)
                                    dismiss()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Lessons")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await loadLessons()
        }
    }
    
    private func loadLessons() async {
        do {
            let allLessons = try await LessonService.shared.getAllLessons()
            lessons = unit.lessons.compactMap { lessonId in
                allLessons.first { $0.id == lessonId }
            }
        } catch {
            print("Failed to load lessons: \(error)")
        }
    }
}

// MARK: - Art Lesson Row
struct ArtLessonRow: View {
    let lesson: Lesson
    let index: Int
    let isCompleted: Bool
    let isUnlocked: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Number/Check Circle
                ZStack {
                    Circle()
                        .fill(
                            isCompleted ?
                            LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing) :
                            isUnlocked ?
                            LinearGradient(colors: [.purple.opacity(0.3), .pink.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                            LinearGradient(colors: [Color.gray.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 44, height: 44)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.body.weight(.bold))
                    } else {
                        Text("\(index)")
                            .foregroundColor(isUnlocked ? .primary : .secondary)
                            .font(.body.weight(.bold))
                    }
                }
                
                // Lesson Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.headline)
                        .foregroundColor(isUnlocked ? .primary : .secondary)
                    
                    HStack(spacing: 12) {
                        Label("\(lesson.estimatedMinutes) min", systemImage: "clock")
                        Label("\(lesson.xpReward) XP", systemImage: "star.fill")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .opacity(isUnlocked ? 1.0 : 0.6)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isUnlocked)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        } perform: {}
    }
}

#Preview {
    LearningTreeView()
}
