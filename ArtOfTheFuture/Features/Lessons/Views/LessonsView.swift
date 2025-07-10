// MARK: - Enhanced Lessons View with Completion Tracking
// File: ArtOfTheFuture/Features/Lessons/Views/LessonsView.swift

import SwiftUI

struct LessonsView: View {
    @StateObject private var viewModel = LessonsViewModel()
    @State private var selectedLesson: Lesson?
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Progress Overview
                    if viewModel.lessons.count > 0 {
                        ProgressOverviewCard(
                            completedCount: viewModel.completedLessonsCount,
                            totalCount: viewModel.lessons.count,
                            totalXP: viewModel.totalXPEarned
                        )
                        .padding(.horizontal)
                    }
                    
                    // Filter Buttons
                    FilterButtonsView(
                        selectedFilter: $viewModel.selectedFilter,
                        onFilterChanged: viewModel.filterLessons
                    )
                    .padding(.horizontal)
                    
                    // Lessons Grid
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredLessons) { lesson in
                            EnhancedLessonCard(
                                lesson: lesson,
                                isCompleted: viewModel.completedLessons.contains(lesson.id),
                                isLocked: !viewModel.unlockedLessons.contains(lesson.id) && lesson.id != "lesson_001"
                            ) {
                                print("📚 Opening lesson: \(lesson.title)")
                                print("📊 Lesson has \(lesson.steps.count) steps")
                                selectedLesson = lesson
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Learn")
            .searchable(text: $searchText, prompt: "Search lessons")
            .onChange(of: searchText) { oldValue, newValue in
                viewModel.searchLessons(query: newValue)
            }
            .background(Color(.systemGroupedBackground))
            .refreshable {
                await viewModel.loadLessons()
            }
        }
        .sheet(item: $selectedLesson) { lesson in
            LessonPlayerView(lesson: lesson)
                .onDisappear {
                    // Refresh lessons when returning from lesson player
                    Task {
                        await viewModel.loadLessons()
                    }
                }
        }
        .task {
            await viewModel.loadLessons()
        }
    }
}

// MARK: - Enhanced Lesson Card with Proper Status
struct EnhancedLessonCard: View {
    let lesson: Lesson
    let isCompleted: Bool
    let isLocked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Status Icon
                ZStack {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: statusIcon)
                        .foregroundColor(.white)
                        .font(.title2)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    // Title and Type Badge
                    HStack {
                        Text(lesson.title)
                            .font(.headline)
                            .foregroundColor(isLocked ? .secondary : .primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        TypeBadge(type: lesson.type)
                    }
                    
                    Text(lesson.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Stats
                    HStack(spacing: 16) {
                        Label("\(lesson.estimatedMinutes)m", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label("\(lesson.xpReward) XP", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label("\(lesson.steps.count) steps", systemImage: "list.number")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(lesson.difficulty.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(lesson.difficulty.difficultyColor)
                    }
                }
                
                // Chevron or lock
                Image(systemName: isLocked ? "lock.fill" : "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isCompleted ? Color.green.opacity(0.3) : Color.clear,
                        lineWidth: 2
                    )
            )
            .opacity(isLocked ? 0.6 : 1.0)
        }
        .disabled(isLocked)
        .buttonStyle(.plain)
    }
    
    private var statusColor: Color {
        if isLocked {
            return .gray
        } else if isCompleted {
            return .green
        } else {
            return lesson.category.categoryColor
        }
    }
    
    private var statusIcon: String {
        if isLocked {
            return "lock.fill"
        } else if isCompleted {
            return "checkmark.circle.fill"
        } else {
            return lesson.category.iconName
        }
    }
}

// MARK: - Supporting Views
struct ProgressOverviewCard: View {
    let completedCount: Int
    let totalCount: Int
    let totalXP: Int
    
    private var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Progress")
                        .font(.headline)
                    Text("\(completedCount) of \(totalCount) lessons completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(totalXP) XP")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Total Earned")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.spring(response: 0.6), value: progress)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

struct FilterButtonsView: View {
    @Binding var selectedFilter: LessonFilter
    let onFilterChanged: (LessonFilter) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(LessonFilter.allCases, id: \.self) { filter in
                    FilterButton(
                        title: filter.displayName,
                        isSelected: selectedFilter == filter,
                        action: {
                            selectedFilter = filter
                            onFilterChanged(filter)
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color(.systemGray5))
                )
        }
        .buttonStyle(.plain)
    }
}

struct TypeBadge: View {
    let type: LessonType
    
    var body: some View {
        Text(type.rawValue)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(type.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(type.color.opacity(0.15))
            .cornerRadius(8)
    }
}

// MARK: - Enhanced View Model with Completion Tracking
@MainActor
final class LessonsViewModel: ObservableObject {
    @Published var lessons: [Lesson] = []
    @Published var filteredLessons: [Lesson] = []
    @Published var selectedFilter: LessonFilter = .all
    @Published var isLoading = false
    @Published var searchQuery = ""
    @Published var completedLessons: Set<String> = []
    @Published var unlockedLessons: Set<String> = ["lesson_001"] // First lesson always unlocked
    
    private let lessonService: LessonServiceProtocol
    private let progressService: ProgressServiceProtocol
    
    var completedLessonsCount: Int {
        completedLessons.count
    }
    
    var totalXPEarned: Int {
        lessons.filter { completedLessons.contains($0.id) }
               .reduce(0) { $0 + $1.xpReward }
    }
    
    init() {
        self.lessonService = LessonService.shared
        self.progressService = Container.shared.progressService
    }
    
    func loadLessons() async {
        isLoading = true
        print("🔄 Loading lessons with completion status...")
        
        do {
            // Load lessons
            lessons = try await lessonService.getAllLessons()
            print("✅ Loaded \(lessons.count) lessons")
            
            // Load completion status
            await loadCompletionStatus()
            
            // Apply filters
            applyFilters()
            
        } catch {
            print("❌ Error loading lessons: \(error)")
        }
        
        isLoading = false
    }
    
    private func loadCompletionStatus() async {
        // Load completed lessons from UserDefaults (simple approach)
        let defaults = UserDefaults.standard
        
        // Get completed lessons
        if let completedArray = defaults.array(forKey: "completedLessons") as? [String] {
            completedLessons = Set(completedArray)
            print("📚 Found \(completedLessons.count) completed lessons: \(completedLessons)")
        }
        
        // Calculate unlocked lessons based on completion
        var newUnlockedLessons: Set<String> = ["lesson_001"] // First lesson always unlocked
        
        for lesson in lessons {
            // If all prerequisites are completed, unlock this lesson
            if lesson.prerequisites.allSatisfy({ completedLessons.contains($0) }) {
                newUnlockedLessons.insert(lesson.id)
            }
            
            // If this lesson is completed, unlock its unlocks
            if completedLessons.contains(lesson.id) {
                for unlockedId in lesson.unlocks {
                    newUnlockedLessons.insert(unlockedId)
                }
            }
        }
        
        unlockedLessons = newUnlockedLessons
        print("🔓 Unlocked lessons: \(unlockedLessons)")
    }
    
    func filterLessons(by filter: LessonFilter) {
        selectedFilter = filter
        applyFilters()
    }
    
    func searchLessons(query: String) {
        searchQuery = query
        applyFilters()
    }
    
    private func applyFilters() {
        var filtered = lessons
        
        // Apply category filter
        switch selectedFilter {
        case .all:
            break
        case .drawing:
            filtered = filtered.filter { $0.type == .drawingPractice }
        case .theory:
            filtered = filtered.filter { $0.type == .theoryFundamentals }
        case .challenges:
            filtered = filtered.filter { $0.type == .creativeChallenge }
        case .completed:
            filtered = filtered.filter { completedLessons.contains($0.id) }
        case .available:
            filtered = filtered.filter { unlockedLessons.contains($0.id) }
        }
        
        // Apply search filter
        if !searchQuery.isEmpty {
            filtered = filtered.filter { lesson in
                lesson.title.localizedCaseInsensitiveContains(searchQuery) ||
                lesson.description.localizedCaseInsensitiveContains(searchQuery)
            }
        }
        
        filteredLessons = filtered
    }
}

// MARK: - Filter Types
enum LessonFilter: String, CaseIterable {
    case all = "all"
    case drawing = "drawing"
    case theory = "theory"
    case challenges = "challenges"
    case completed = "completed"
    case available = "available"
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .drawing: return "Drawing"
        case .theory: return "Theory"
        case .challenges: return "Challenges"
        case .completed: return "Completed"
        case .available: return "Available"
        }
    }
}

#Preview {
    LessonsView()
}
