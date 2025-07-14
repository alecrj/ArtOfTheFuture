// MARK: - Learning Tree View
// File: ArtOfTheFuture/Features/Lessons/Views/LearningTreeView.swift

import SwiftUI

struct LearningTreeView: View {
    @StateObject private var viewModel = LearningTreeViewModel()
    @State private var selectedSection: LearningSection?
    @State private var selectedUnit: LearningUnit?
    @State private var selectedLesson: Lesson?
    @State private var expandedSections: Set<String> = ["section_beginner"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGroupedBackground).opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Content
                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        treeHeader
                            .padding(.horizontal)
                            .padding(.bottom, 24)
                        
                        // Tree Content
                        LazyVStack(spacing: 20) {
                            ForEach(viewModel.learningTree.sections) { section in
                                SectionView(
                                    section: section,
                                    isExpanded: expandedSections.contains(section.id),
                                    onToggle: { toggleSection(section.id) },
                                    onUnitTap: { unit in
                                        withAnimation(.spring(response: 0.4)) {
                                            selectedUnit = unit
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
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
        .sheet(item: $selectedUnit) { unit in
            UnitDetailView(unit: unit, onLessonSelect: { lesson in
                selectedLesson = lesson
            })
        }
        .fullScreenCover(item: $selectedLesson) { lesson in
            LessonPlayerView(lesson: lesson)
        }
        .task {
            await viewModel.loadTree()
        }
    }
    
    // MARK: - Tree Header
    private var treeHeader: some View {
        VStack(spacing: 16) {
            // Progress Overview
            VStack(spacing: 8) {
                HStack {
                    Text("Overall Progress")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(viewModel.learningTree.overallProgress * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                ProgressView(value: viewModel.learningTree.overallProgress)
                    .progressViewStyle(RoundedProgressViewStyle())
                
                HStack {
                    Label("\(viewModel.learningTree.completedLessons) completed", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Label("\(viewModel.learningTree.totalLessons) total lessons", systemImage: "book.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        }
    }
    
    // MARK: - Helper Methods
    private func toggleSection(_ sectionId: String) {
        withAnimation(.spring(response: 0.3)) {
            if expandedSections.contains(sectionId) {
                expandedSections.remove(sectionId)
            } else {
                expandedSections.insert(sectionId)
            }
        }
    }
}

// MARK: - Section View
struct SectionView: View {
    let section: LearningSection
    let isExpanded: Bool
    let onToggle: () -> Void
    let onUnitTap: (LearningUnit) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Section Header
            Button(action: onToggle) {
                HStack(spacing: 16) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(section.color.gradient)
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: section.iconName)
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    
                    // Title & Progress
                    VStack(alignment: .leading, spacing: 4) {
                        Text(section.title)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(section.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Progress & Chevron
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(Int(section.progress * 100))%")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(section.color)
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: section.color.opacity(0.2), radius: 10, y: 5)
            }
            .buttonStyle(ScaleButtonStyle())
            
            // Units (when expanded)
            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(section.units) { unit in
                        UnitRow(
                            unit: unit,
                            sectionColor: section.color,
                            onTap: { onUnitTap(unit) }
                        )
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .scale(scale: 0.8).combined(with: .opacity)
                        ))
                    }
                }
                .padding(.top, 12)
            }
        }
    }
}

// MARK: - Unit Row
struct UnitRow: View {
    let unit: LearningUnit
    let sectionColor: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Progress Circle
                ZStack {
                    Circle()
                        .stroke(sectionColor.opacity(0.2), lineWidth: 3)
                        .frame(width: 40, height: 40)
                    
                    Circle()
                        .trim(from: 0, to: unit.progress)
                        .stroke(sectionColor, lineWidth: 3)
                        .frame(width: 40, height: 40)
                        .rotationEffect(.degrees(-90))
                    
                    if unit.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .foregroundColor(sectionColor)
                    } else {
                        Text("\(unit.completedLessons)/\(unit.lessons.count)")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                }
                
                // Unit Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(unit.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(unit.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Lock/Arrow
                Image(systemName: unit.isUnlocked ? "chevron.right" : "lock.fill")
                    .font(.caption)
                    .foregroundColor(unit.isUnlocked ? .secondary : .orange)
            }
            .padding(12)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .opacity(unit.isUnlocked ? 1.0 : 0.7)
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.98))
        .disabled(!unit.isUnlocked)
    }
}

// MARK: - Unit Detail View
struct UnitDetailView: View {
    let unit: LearningUnit
    let onLessonSelect: (Lesson) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var lessons: [Lesson] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Unit Header
                    VStack(spacing: 12) {
                        Image(systemName: unit.iconName)
                            .font(.largeTitle)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text(unit.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(unit.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // Progress
                        HStack {
                            ProgressView(value: unit.progress)
                                .progressViewStyle(RoundedProgressViewStyle())
                            
                            Text("\(unit.completedLessons)/\(unit.lessons.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    
                    // Lessons List
                    VStack(spacing: 12) {
                        ForEach(Array(unit.lessons.enumerated()), id: \.element) { index, lessonId in
                            if let lesson = lessons.first(where: { $0.id == lessonId }) {
                                LessonRowInUnit(
                                    lesson: lesson,
                                    index: index + 1,
                                    isCompleted: unit.completedLessonIds.contains(lessonId),
                                    isUnlocked: index == 0 || unit.completedLessonIds.contains(unit.lessons[max(0, index - 1)]),
                                    onTap: {
                                        onLessonSelect(lesson)
                                        dismiss()
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Unit Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            // Load lessons for this unit
            loadLessons()
        }
    }
    
    private func loadLessons() {
        // For now, create placeholder lessons
        lessons = unit.lessons.enumerated().map { index, lessonId in
            Lesson(
                id: lessonId,
                title: "Lesson \(index + 1)",
                description: "Complete this lesson to progress",
                type: .drawingPractice,
                category: .basics,
                difficulty: .beginner,
                estimatedMinutes: 10,
                xpReward: 50,
                steps: [],
                exercises: [],
                objectives: [],
                tips: [],
                prerequisites: index > 0 ? [unit.lessons[index - 1]] : [],
                unlocks: index < unit.lessons.count - 1 ? [unit.lessons[index + 1]] : []
            )
        }
    }
}

// MARK: - Lesson Row in Unit
struct LessonRowInUnit: View {
    let lesson: Lesson
    let index: Int
    let isCompleted: Bool
    let isUnlocked: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Number/Check Circle
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.green : (isUnlocked ? Color.blue : Color.gray.opacity(0.3)))
                        .frame(width: 44, height: 44)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.body.weight(.bold))
                    } else {
                        Text("\(index)")
                            .foregroundColor(.white)
                            .font(.body.weight(.bold))
                    }
                }
                
                // Lesson Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(isUnlocked ? .primary : .secondary)
                    
                    HStack(spacing: 8) {
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
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
            .opacity(isUnlocked ? 1.0 : 0.6)
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!isUnlocked)
    }
}

// MARK: - Supporting Views
struct RoundedProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * (configuration.fractionCompleted ?? 0), height: 8)
            }
        }
        .frame(height: 8)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.95
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
