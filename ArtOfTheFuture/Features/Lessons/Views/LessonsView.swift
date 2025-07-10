// MARK: - Enhanced Lessons View with Visible XP System
// File: ArtOfTheFuture/Features/Lessons/Views/LessonsView.swift

import SwiftUI

struct LessonsView: View {
    @StateObject private var viewModel = LessonsViewModel()
    @State private var selectedLesson: Lesson?
    @State private var searchText = ""
    @State private var showingXPAnimation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // XP and Level Header
                    xpHeaderSection
                    
                    // Progress Overview
                    if viewModel.lessons.count > 0 {
                        ProgressOverviewCard(
                            completedCount: viewModel.completedLessonsCount,
                            totalCount: viewModel.lessons.count,
                            totalXP: viewModel.totalXPEarned,
                            currentXP: viewModel.currentTotalXP
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
                    // Refresh when returning from lesson
                    Task {
                        let previousXP = viewModel.currentTotalXP
                        await viewModel.loadLessons()
                        
                        // Show XP gain animation if XP increased
                        if viewModel.currentTotalXP > previousXP {
                            showingXPAnimation = true
                        }
                    }
                }
        }
        .overlay(
            Group {
                if showingXPAnimation {
                    XPGainOverlay(
                        xpGained: viewModel.currentTotalXP - viewModel.previousXP,
                        newLevel: viewModel.currentLevel,
                        onDismiss: {
                            showingXPAnimation = false
                        }
                    )
                }
            }
        )
        .task {
            await viewModel.loadLessons()
        }
    }
    
    // MARK: - XP Header Section
    private var xpHeaderSection: some View {
        HStack(spacing: 16) {
            // Level Badge
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Text("\(viewModel.currentLevel)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Text("Level")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // XP Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(viewModel.currentTotalXP) XP")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("\(viewModel.xpToNextLevel) to next level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // XP Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.systemGray5))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * viewModel.levelProgress, height: 12)
                            .animation(.spring(response: 0.6), value: viewModel.levelProgress)
                    }
                }
                .frame(height: 12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        .padding(.horizontal)
    }
}

// MARK: - Enhanced Progress Overview Card
struct ProgressOverviewCard: View {
    let completedCount: Int
    let totalCount: Int
    let totalXP: Int
    let currentXP: Int
    
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
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        
                        Text("\(currentXP)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    Text("Total XP")
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
            
            // XP Breakdown
            if currentXP > 0 {
                HStack(spacing: 20) {
                    VStack(spacing: 2) {
                        Text("\(totalXP)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                        Text("From Lessons")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 2) {
                        Text("\(currentXP - totalXP)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                        Text("From Other")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("\(Int(progress * 100))%")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        Text("Complete")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

// MARK: - Enhanced Lesson Card with XP Display
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
                    // Title and XP Badge
                    HStack {
                        Text(lesson.title)
                            .font(.headline)
                            .foregroundColor(isLocked ? .secondary : .primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if !isLocked {
                            XPBadge(xp: lesson.xpReward, isCompleted: isCompleted)
                        }
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

// MARK: - XP Badge
struct XPBadge: View {
    let xp: Int
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.caption2)
                .foregroundColor(isCompleted ? .yellow : .orange)
            
            Text("\(xp)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(isCompleted ? .yellow : .orange)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCompleted ? Color.yellow.opacity(0.2) : Color.orange.opacity(0.2))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCompleted ? Color.yellow : Color.orange, lineWidth: 1)
        )
    }
}

// MARK: - XP Gain Overlay
struct XPGainOverlay: View {
    let xpGained: Int
    let newLevel: Int
    let onDismiss: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)
            
            VStack(spacing: 24) {
                // XP Stars Animation
                ZStack {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: "star.fill")
                            .font(.title)
                            .foregroundColor(.yellow)
                            .offset(
                                x: isAnimating ? CGFloat.random(in: -50...50) : 0,
                                y: isAnimating ? CGFloat.random(in: -50...50) : 0
                            )
                            .opacity(isAnimating ? 0.3 : 1.0)
                            .animation(
                                .easeOut(duration: 1.0).delay(Double(index) * 0.1),
                                value: isAnimating
                            )
                    }
                    
                    Text("+\(xpGained)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .animation(.spring(response: 0.6), value: isAnimating)
                }
                
                VStack(spacing: 8) {
                    Text("XP Earned!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Keep up the great work!")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            )
            .padding()
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onDismiss()
            }
        }
    }
}

// MARK: - Enhanced Lessons View Model with XP Tracking
@MainActor
final class LessonsViewModel: ObservableObject {
    @Published var lessons: [Lesson] = []
    @Published var filteredLessons: [Lesson] = []
    @Published var selectedFilter: LessonFilter = .all
    @Published var isLoading = false
    @Published var searchQuery = ""
    @Published var completedLessons: Set<String> = []
    @Published var unlockedLessons: Set<String> = ["lesson_001"]
    
    // XP Tracking
    @Published var currentTotalXP = 0
    @Published var currentLevel = 1
    @Published var levelProgress: Double = 0
    @Published var xpToNextLevel = 100
    @Published var previousXP = 0
    
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
        
        // Store previous XP for animation detection
        previousXP = currentTotalXP
        
        do {
            // Load lessons
            lessons = try await lessonService.getAllLessons()
            print("✅ Loaded \(lessons.count) lessons")
            
            // Load completion status
            await loadCompletionStatus()
            
            // Load XP data
            await loadXPData()
            
            // Apply filters
            applyFilters()
            
        } catch {
            print("❌ Error loading lessons: \(error)")
        }
        
        isLoading = false
    }
    
    private func loadXPData() async {
        let progressService = self.progressService as! ProgressService
        currentTotalXP = progressService.getTotalXP()
        
        // Calculate level and progress
        currentLevel = (currentTotalXP / 100) + 1
        let currentLevelXP = currentTotalXP % 100
        levelProgress = Double(currentLevelXP) / 100.0
        xpToNextLevel = 100 - currentLevelXP
        
        print("📊 XP Data: Total=\(currentTotalXP), Level=\(currentLevel), Progress=\(levelProgress)")
    }
    
    private func loadCompletionStatus() async {
        let defaults = UserDefaults.standard
        
        if let completedArray = defaults.array(forKey: "completedLessons") as? [String] {
            completedLessons = Set(completedArray)
            print("📚 Found \(completedLessons.count) completed lessons: \(completedLessons)")
        }
        
        var newUnlockedLessons: Set<String> = ["lesson_001"]
        
        for lesson in lessons {
            if lesson.prerequisites.allSatisfy({ completedLessons.contains($0) }) {
                newUnlockedLessons.insert(lesson.id)
            }
            
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
        
        if !searchQuery.isEmpty {
            filtered = filtered.filter { lesson in
                lesson.title.localizedCaseInsensitiveContains(searchQuery) ||
                lesson.description.localizedCaseInsensitiveContains(searchQuery)
            }
        }
        
        filteredLessons = filtered
    }
}

// MARK: - Supporting Views (FilterButtonsView, etc. remain the same)
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
