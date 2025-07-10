// MARK: - XP System Integration for Home Dashboard
// File: ArtOfTheFuture/Features/Home/Views/HomeDashboardView.swift

import SwiftUI

struct HomeDashboardView: View {
    @StateObject private var viewModel = HomeDashboardViewModel()
    @State private var showingProfile = false
    @State private var selectedLesson: Lesson?
    @State private var showingStreakCelebration = false
    @State private var showingXPAnimation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with XP and Level
                    enhancedHeaderSection
                    
                    // XP Progress to Next Level
                    xpProgressSection
                    
                    // Daily Progress
                    dailyProgressSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Recommended Lessons
                    recommendedLessonsSection
                    
                    // Recent Artwork
                    if !viewModel.recentArtworks.isEmpty {
                        recentArtworkSection
                    }
                    
                    // Weekly Stats
                    weeklyStatsSection
                    
                    // Achievements
                    if !viewModel.achievements.isEmpty {
                        achievementsSection
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .refreshable {
                await viewModel.refreshDashboard()
            }
            .task {
                await viewModel.loadDashboard()
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
            }
            .sheet(item: $selectedLesson) { lesson in
                LessonPlayerView(lesson: lesson)
                    .onDisappear {
                        // Refresh XP when returning from lesson
                        Task {
                            await viewModel.refreshXP()
                            if viewModel.hasNewXP {
                                showingXPAnimation = true
                            }
                        }
                    }
            }
            .overlay(
                Group {
                    if showingStreakCelebration {
                        StreakCelebrationView(
                            streak: viewModel.currentStreak,
                            onDismiss: {
                                showingStreakCelebration = false
                            }
                        )
                    }
                    
                    if showingXPAnimation {
                        XPGainAnimationView(
                            xpGained: viewModel.newXPGained,
                            onDismiss: {
                                showingXPAnimation = false
                            }
                        )
                    }
                }
            )
        }
    }
    
    // MARK: - Enhanced Header with XP System
    private var enhancedHeaderSection: some View {
        HStack(spacing: 16) {
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(viewModel.userName)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            // XP and Level Display
            HStack(spacing: 12) {
                // Current Level Badge
                LevelBadgeView(
                    level: viewModel.currentLevel,
                    xp: viewModel.totalXP,
                    nextLevelXP: viewModel.nextLevelXP
                )
                
                // Streak Badge
                StreakBadge(
                    streak: viewModel.currentStreak,
                    onTap: {
                        if viewModel.currentStreak > 0 {
                            showingStreakCelebration = true
                            Task {
                                await HapticManager.shared.notification(.success)
                            }
                        }
                    }
                )
            }
            
            // Profile Button
            Button(action: { showingProfile = true }) {
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(viewModel.userName.prefix(1).uppercased())
                            .font(.headline)
                            .foregroundColor(.white)
                    )
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - XP Progress Section
    private var xpProgressSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Level \(viewModel.currentLevel)")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(viewModel.currentLevelXP) / \(viewModel.xpNeededForNextLevel) XP")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // XP Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * viewModel.levelProgress, height: 12)
                        .animation(.spring(response: 0.8), value: viewModel.levelProgress)
                }
            }
            .frame(height: 12)
            
            // Total XP Display
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                
                Text("Total: \(viewModel.totalXP) XP")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                if viewModel.totalXP > 0 {
                    Text("Keep going! \(viewModel.xpNeededForNextLevel - viewModel.currentLevelXP) XP to level up!")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        .padding(.horizontal)
    }
    
    // MARK: - Rest of the sections remain the same...
    private var dailyProgressSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Today's Progress")
                    .font(.headline)
                
                Spacer()
                
                Text("\(viewModel.todayProgress.completedMinutes) / \(viewModel.todayProgress.targetMinutes) min")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Progress Ring
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 12)
                
                Circle()
                    .trim(from: 0, to: viewModel.todayProgress.progressPercentage)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6), value: viewModel.todayProgress.progressPercentage)
                
                VStack(spacing: 8) {
                    if viewModel.todayProgress.isComplete {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                    } else {
                        Text("\(Int(viewModel.todayProgress.progressPercentage * 100))%")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                    Text("\(viewModel.todayProgress.xpEarned) XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 150, height: 150)
            .padding(.vertical)
            
            HStack(spacing: 32) {
                VStack(spacing: 4) {
                    Text("\(viewModel.todayProgress.lessonsCompleted)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Lessons")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(viewModel.todayProgress.completedMinutes)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Minutes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(viewModel.todayProgress.xpEarned)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("XP Earned")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        .padding(.horizontal)
    }
    
    // MARK: - Quick Actions (same)
    private var quickActionsSection: some View {
        HStack(spacing: 12) {
            QuickActionButton(
                title: "Draw",
                icon: "paintbrush.fill",
                color: .blue,
                action: {}
            )
            
            QuickActionButton(
                title: "Learn",
                icon: "book.fill",
                color: .green,
                action: {}
            )
            
            QuickActionButton(
                title: "Challenge",
                icon: "flag.fill",
                color: .orange,
                action: {}
            )
            
            QuickActionButton(
                title: "Gallery",
                icon: "photo.stack",
                color: .purple,
                action: {}
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Recommended Lessons (same structure)
    private var recommendedLessonsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Continue Learning")
                    .font(.headline)
                
                Spacer()
                
                Button("See All") {}
                    .font(.caption)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.recommendedLessons) { lesson in
                        RecommendedLessonCard(
                            lesson: lesson,
                            action: {
                                selectedLesson = lesson
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Other sections omitted for brevity but remain the same
    private var recentArtworkSection: some View {
        VStack { Text("Recent Artwork Section") }
    }
    
    private var weeklyStatsSection: some View {
        VStack { Text("Weekly Stats Section") }
    }
    
    private var achievementsSection: some View {
        VStack { Text("Achievements Section") }
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }
}

// MARK: - Level Badge View
struct LevelBadgeView: View {
    let level: Int
    let xp: Int
    let nextLevelXP: Int
    
    var progress: Double {
        let currentLevelXP = xp % 100
        return Double(currentLevelXP) / 100.0
    }
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Text("\(level)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Text("Level")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - XP Gain Animation
struct XPGainAnimationView: View {
    let xpGained: Int
    let onDismiss: () -> Void
    
    @State private var isAnimating = false
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)
            
            VStack(spacing: 32) {
                // XP Animation
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.yellow.opacity(0.8),
                                    Color.orange.opacity(0.4),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.yellow)
                        .scaleEffect(isAnimating ? 1.0 : 0)
                        .rotationEffect(.degrees(isAnimating ? 0 : -20))
                }
                
                VStack(spacing: 16) {
                    Text("+\(xpGained) XP")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Great progress!")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAnimating = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showContent = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                onDismiss()
            }
        }
    }
}

// MARK: - Enhanced Home Dashboard ViewModel
@MainActor
final class HomeDashboardViewModel: ObservableObject {
    @Published var userName = "Artist"
    @Published var currentStreak = 0
    @Published var todayProgress = DailyProgress(
        targetMinutes: 15,
        completedMinutes: 0,
        lessonsCompleted: 0,
        xpEarned: 0
    )
    @Published var recommendedLessons: [Lesson] = []
    @Published var recentArtworks: [Artwork] = []
    @Published var weeklyStats = WeeklyStats(
        days: [],
        totalMinutes: 0,
        totalXP: 0,
        averageMinutesPerDay: 0
    )
    @Published var achievements: [Achievement] = []
    @Published var isLoading = false
    
    // XP System Properties
    @Published var totalXP = 0
    @Published var currentLevel = 1
    @Published var currentLevelXP = 0
    @Published var xpNeededForNextLevel = 100
    @Published var nextLevelXP = 100
    @Published var levelProgress: Double = 0
    @Published var hasNewXP = false
    @Published var newXPGained = 0
    
    private let userService: UserServiceProtocol
    private let galleryService: GalleryServiceProtocol
    private let progressService: ProgressServiceProtocol
    private var previousXP = 0
    
    init(
        userService: UserServiceProtocol? = nil,
        galleryService: GalleryServiceProtocol? = nil
    ) {
        self.userService = userService ?? UserService()
        self.galleryService = galleryService ?? Container.shared.galleryService
        self.progressService = Container.shared.progressService
    }
    
    func loadDashboard() async {
        isLoading = true
        
        // Load XP and level data
        await loadXPData()
        
        // Load user data
        if let userId = UserDefaults.standard.string(forKey: "currentUserId"),
           let user = try? await userService.getUser(id: userId) {
            userName = user.displayName
            currentStreak = user.currentStreak
        }
        
        // Load today's progress
        await loadTodayProgress()
        
        // Load weekly stats
        if let stats = try? await userService.getWeeklyStats() {
            weeklyStats = stats
        }
        
        // Load recommended lessons
        await loadRecommendedLessons()
        
        // Load recent artworks
        await loadRecentArtworks()
        
        // Load achievements
        loadAchievements()
        
        isLoading = false
    }
    
    func refreshDashboard() async {
        await loadDashboard()
    }
    
    func refreshXP() async {
        previousXP = totalXP
        await loadXPData()
        
        if totalXP > previousXP {
            hasNewXP = true
            newXPGained = totalXP - previousXP
        }
    }
    
    private func loadXPData() async {
        // Get XP from progress service
        let progressService = self.progressService as! ProgressService
        totalXP = progressService.getTotalXP()
        
        // Calculate level and progress
        currentLevel = (totalXP / 100) + 1
        currentLevelXP = totalXP % 100
        xpNeededForNextLevel = 100
        nextLevelXP = currentLevel * 100
        levelProgress = Double(currentLevelXP) / Double(xpNeededForNextLevel)
        
        print("📊 XP Data: Total=\(totalXP), Level=\(currentLevel), Progress=\(levelProgress)")
    }
    
    private func loadTodayProgress() async {
        // This would load from actual data
        let targetMinutes = UserDefaults.standard.object(forKey: "dailyGoalMinutes") as? Int ?? 15
        
        todayProgress = DailyProgress(
            targetMinutes: targetMinutes,
            completedMinutes: Int.random(in: 0...targetMinutes),
            lessonsCompleted: Int.random(in: 0...3),
            xpEarned: currentLevelXP
        )
    }
    
    private func loadRecommendedLessons() async {
        recommendedLessons = MockDataService.shared.getMockLessons()
            .prefix(3)
            .map { $0 }
    }
    
    private func loadRecentArtworks() async {
        if let artworks = try? await galleryService.loadArtworks() {
            recentArtworks = artworks
                .sorted { $0.modifiedAt > $1.modifiedAt }
                .prefix(3)
                .map { $0 }
        }
    }
    
    private func loadAchievements() {
        achievements = [
            Achievement(
                id: "1",
                title: "First Steps",
                description: "Complete your first lesson",
                icon: "star.fill",
                unlockedDate: totalXP > 0 ? Date() : nil,
                progress: totalXP > 0 ? 1.0 : 0.0,
                xpReward: 50
            ),
            Achievement(
                id: "2",
                title: "Rising Artist",
                description: "Earn 200 XP",
                icon: "paintpalette.fill",
                unlockedDate: totalXP >= 200 ? Date() : nil,
                progress: min(Double(totalXP) / 200.0, 1.0),
                xpReward: 100
            )
        ]
    }
}

#Preview {
    HomeDashboardView()
}
