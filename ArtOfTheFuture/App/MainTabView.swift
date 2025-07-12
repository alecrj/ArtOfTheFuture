// MARK: - Simplified Working MainTabView (REPLACE existing MainTabView.swift)
// File: ArtOfTheFuture/App/MainTabView.swift

import SwiftUI


struct MainTabView: View {
    @StateObject private var gamificationService = GamificationService.shared
    @StateObject private var userProgressService = UserProgressService.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Learn Tab - Enhanced with Section Navigation
            LearnNavigationView()
                .tabItem {
                    Label("Learn", systemImage: "graduationcap.fill")
                }
                .tag(0)
            
            // Practice Tab - Using existing LessonsView for now
            LessonsView()
                .tabItem {
                    Label("Practice", systemImage: "pencil.and.outline")
                }
                .tag(1)
            
            // Challenges Tab - Simple placeholder
            ChallengesView()
                .tabItem {
                    Label("Challenges", systemImage: "target")
                }
                .tag(2)
            
            // Gallery Tab - Using existing GalleryView
            GalleryView()
                .tabItem {
                    Label("Gallery", systemImage: "photo.stack.fill")
                }
                .tag(3)
            
            // Profile Tab - Using existing ProfileView
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
                .tag(4)
        }
        .accentColor(.blue) // Using system blue instead of ColorPalette.primary
        .overlay(
            // Floating Hearts Display
            VStack {
                HStack {
                    Spacer()
                    HeartsStatusView()
                }
                .padding(.top, 60)
                .padding(.trailing, 16)
                
                Spacer()
            }
        )
        .task {
            await initializeSystem()
        }
    }
    
    private func initializeSystem() async {
        do {
            // Initialize the enhanced system
            try await IntegrationHelper.shared.initializeEnhancedSystem()
            print("✅ Enhanced learning system initialized")
        } catch {
            print("❌ Failed to initialize enhanced system: \(error)")
        }
    }
}

// MARK: - Learn Navigation View (Simplified)
struct LearnNavigationView: View {
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            SectionSelectionView()
                .navigationDestination(for: Section.self) { section in
                    UnitGridView(section: section)
                }
                .navigationDestination(for: Unit.self) { unit in
                    UnitDetailView(unit: unit)
                }
                .navigationDestination(for: Lesson.self) { lesson in
                    LessonPlayerView(lesson: lesson)
                }
        }
    }
}

// MARK: - Hearts Status View
struct HeartsStatusView: View {
    @StateObject private var gamificationService = GamificationService.shared
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: index < gamificationService.currentHearts ? "heart.fill" : "heart")
                    .foregroundColor(index < gamificationService.currentHearts ? .red : .gray)
                    .font(.caption)
                    .scaleEffect(index < gamificationService.currentHearts ? 1.0 : 0.8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Section Selection View
struct SectionSelectionView: View {
    @StateObject private var lessonService = LessonService.shared
    @StateObject private var userProgressService = UserProgressService.shared
    @StateObject private var gamificationService = GamificationService.shared
    
    @State private var sections: [Section] = []
    @State private var userProfile: UserProfile?
    @State private var unlockedSections: Set<String> = []
    @State private var dailyQuests: [DailyQuest] = []
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Header with user progress
                HeaderProgressView(userProfile: userProfile)
                
                // Daily Quests Section (if available)
                if !dailyQuests.isEmpty {
                    DailyQuestsSection(quests: dailyQuests)
                }
                
                // Learning Path Sections
                ForEach(sections) { section in
                    SectionCard(
                        section: section,
                        isUnlocked: unlockedSections.contains(section.id),
                        progress: calculateSectionProgress(section)
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Your Art Journey")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            await loadData()
        }
        .task {
            await loadData()
        }
    }
    
    private func loadData() async {
        do {
            sections = try await lessonService.getAllSections()
            userProfile = try await userProgressService.getCurrentUser()
            dailyQuests = try await gamificationService.getDailyQuests()
            
            if let profile = userProfile {
                unlockedSections = lessonService.getUnlockedSections(for: profile)
            }
        } catch {
            print("Error loading data: \(error)")
        }
    }
    
    private func calculateSectionProgress(_ section: Section) -> Double {
        guard let profile = userProfile else { return 0 }
        
        let completedUnits = section.units.filter { unit in
            unit.lessonIds.allSatisfy { lessonId in
                profile.completedLessons.contains(lessonId)
            }
        }.count
        
        return section.units.isEmpty ? 0 : Double(completedUnits) / Double(section.units.count)
    }
}

// MARK: - Header Progress View
struct HeaderProgressView: View {
    let userProfile: UserProfile?
    @StateObject private var gamificationService = GamificationService.shared
    
    var body: some View {
        VStack(spacing: 16) {
            // User Level and XP
            HStack {
                VStack(alignment: .leading) {
                    Text("Level \(userProfile?.level ?? 1)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Total XP: \(userProfile?.totalXP ?? 0)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Streak Display
                VStack {
                    Text("🔥")
                        .font(.title)
                    Text("\(gamificationService.currentStreak)")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("day streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Overall Progress
            if let profile = userProfile {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Overall Progress")
                            .font(.headline)
                        Spacer()
                        Text("\(profile.completedLessons.count) lessons completed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(value: calculateOverallProgress(profile))
                        .tint(.blue)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
    
    private func calculateOverallProgress(_ profile: UserProfile) -> Double {
        let totalLessons = Curriculum.allLessons.count
        guard totalLessons > 0 else { return 0 }
        return Double(profile.completedLessons.count) / Double(totalLessons)
    }
}

// MARK: - Daily Quests Section
struct DailyQuestsSection: View {
    let quests: [DailyQuest]
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Text("Daily Quests")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(completedQuests)/\(quests.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(.primary)
            
            if isExpanded {
                ForEach(quests) { quest in
                    QuestRow(quest: quest)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var completedQuests: Int {
        quests.filter { $0.isCompleted }.count
    }
}

// MARK: - Quest Row
struct QuestRow: View {
    let quest: DailyQuest
    
    var body: some View {
        HStack {
            Image(systemName: quest.icon)
                .foregroundColor(quest.isCompleted ? .green : .blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(quest.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(quest.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                if quest.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Text("\(quest.current)/\(quest.target)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("+\(quest.xpReward) XP")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
        }
        .opacity(quest.isCompleted ? 0.7 : 1.0)
    }
}

// MARK: - Section Card
struct SectionCard: View {
    let section: Section
    let isUnlocked: Bool
    let progress: Double
    
    var body: some View {
        NavigationLink(value: section) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    // Section Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: section.backgroundGradient.compactMap { Color(hex: $0) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: section.iconName)
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(section.title)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(section.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    if !isUnlocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                    }
                }
                
                // Progress and Stats
                VStack(spacing: 8) {
                    HStack {
                        Text("Progress")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(progress * 100))%")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    ProgressView(value: progress)
                        .tint(section.color)
                    
                    HStack {
                        Label("\(section.totalUnits) units", systemImage: "square.grid.3x3")
                        
                        Spacer()
                        
                        Label("\(section.estimatedHours)h", systemImage: "clock")
                        
                        Spacer()
                        
                        Label("\(section.totalXP) XP", systemImage: "star.fill")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .disabled(!isUnlocked)
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

// MARK: - Placeholder Views (Will be replaced with full implementations)
struct UnitGridView: View {
    let section: Section
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(section.units) { unit in
                    NavigationLink(value: unit) {
                        VStack {
                            Image(systemName: unit.iconName)
                                .font(.title)
                                .foregroundColor(unit.color)
                            Text(unit.title)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                            Text("\(unit.totalLessons) lessons")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(section.title)
    }
}

struct UnitDetailView: View {
    let unit: Unit
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Unit: \(unit.title)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(unit.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                
                ForEach(unit.lessonIds, id: \.self) { lessonId in
                    if let lesson = Curriculum.allLessons.first(where: { $0.id == lessonId }) {
                        NavigationLink(value: lesson) {
                            HStack {
                                Text(lesson.title)
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(unit.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Integration Helper
final class IntegrationHelper {
    static let shared = IntegrationHelper()
    
    private init() {}
    
    func initializeEnhancedSystem() async throws {
        print("🚀 Initializing enhanced learning system...")
        
        // Initialize user profile if needed
        _ = try await UserProgressService.shared.getCurrentUser()
        
        // Initialize gamification
        try await GamificationService.shared.generateNewDailyQuests()
        try await GamificationService.shared.refillHearts()
        
        print("✅ Enhanced learning system ready")
    }
}
