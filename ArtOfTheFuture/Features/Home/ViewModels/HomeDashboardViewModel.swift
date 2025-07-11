// MARK: - Home Dashboard ViewModel
// **CREATE:** ArtOfTheFuture/Features/Home/ViewModels/HomeDashboardViewModel.swift

import SwiftUI
import Combine

@MainActor
final class HomeDashboardViewModel: ObservableObject {
    // MARK: - User Info
    @Published var userName = "Artist"
    @Published var currentStreak = 0
    @Published var hasNotifications = false
    
    // MARK: - XP & Level
    @Published var totalXP = 0
    @Published var currentLevel = 1
    @Published var xpToNextLevel = 100
    @Published var levelProgress: Double = 0
    
    // MARK: - Daily Progress
    @Published var todayProgress = DailyProgress(
        targetMinutes: 15,
        completedMinutes: 0,
        lessonsCompleted: 0,
        xpEarned: 0
    )
    
    // MARK: - Content
    @Published var recommendedLessons: [Lesson] = []
    @Published var recentArtworks: [Artwork] = []
    @Published var achievements: [Achievement] = []
    @Published var weeklyStats = WeeklyStats(
        days: [],
        totalMinutes: 0,
        totalXP: 0,
        averageMinutesPerDay: 0
    )
    
    // MARK: - UI State
    @Published var isLoading = false
    @Published var showStreakCelebration = false
    @Published var showXPAnimation = false
    @Published var newXPGained = 0
    
    // MARK: - Services
    private let userService: UserServiceProtocol
    private let galleryService: GalleryServiceProtocol
    private let progressService: ProgressServiceProtocol
    private let lessonService: LessonServiceProtocol
    
    // MARK: - Initialization
    init(
        userService: UserServiceProtocol? = nil,
        galleryService: GalleryServiceProtocol? = nil,
        progressService: ProgressServiceProtocol? = nil,
        lessonService: LessonServiceProtocol? = nil
    ) {
        self.userService = userService ?? UserService()
        self.galleryService = galleryService ?? Container.shared.galleryService
        self.progressService = progressService ?? Container.shared.progressService
        self.lessonService = lessonService ?? LessonService.shared
    }
    
    // MARK: - Data Loading
    func loadDashboard() async {
        isLoading = true
        
        // Load user data
        await loadUserData()
        
        // Load XP and level
        await loadXPData()
        
        // Load today's progress
        await loadTodayProgress()
        
        // Load content
        await loadRecommendedLessons()
        await loadRecentArtworks()
        await loadWeeklyStats()
        loadAchievements()
        
        isLoading = false
        
        // Check for celebrations
        checkForCelebrations()
    }
    
    func refreshDashboard() async {
        await loadDashboard()
    }
    
    func refreshXP() async {
        let previousXP = totalXP
        await loadXPData()
        
        if totalXP > previousXP {
            newXPGained = totalXP - previousXP
            showXPAnimation = true
        }
    }
    
    // MARK: - Private Loading Methods
    private func loadUserData() async {
        if let userId = UserDefaults.standard.string(forKey: "currentUserId"),
           let user = try? await userService.getUser(id: userId) {
            userName = user.displayName
            currentStreak = user.currentStreak
        } else {
            // Load from onboarding data
            if let onboardingData = try? await userService.getOnboardingData() {
                userName = onboardingData.userName
            }
        }
    }
    
    private func loadXPData() async {
        let progressService = self.progressService as! ProgressService
        totalXP = progressService.getTotalXP()
        
        // Calculate level and progress
        currentLevel = (totalXP / 100) + 1
        let currentLevelXP = totalXP % 100
        xpToNextLevel = 100 - currentLevelXP
        levelProgress = Double(currentLevelXP) / 100.0
    }
    
    private func loadTodayProgress() async {
        // Get target from user preferences
        let targetMinutes = UserDefaults.standard.object(forKey: "dailyGoalMinutes") as? Int ?? 15
        
        // This would load from actual progress data
        todayProgress = DailyProgress(
            targetMinutes: targetMinutes,
            completedMinutes: min(Int.random(in: 0...targetMinutes), targetMinutes),
            lessonsCompleted: Int.random(in: 0...3),
            xpEarned: Int.random(in: 0...150)
        )
    }
    
    private func loadRecommendedLessons() async {
        do {
            let allLessons = try await lessonService.getAllLessons()
            
            // Get completed lessons
            let completedLessons = try await progressService.getCompletedLessons()
            
            // Filter and recommend
            recommendedLessons = allLessons
                .filter { !completedLessons.contains($0.id) }
                .prefix(5)
                .map { $0 }
        } catch {
            print("Failed to load lessons: \(error)")
            // Use mock data as fallback
            recommendedLessons = MockDataService.shared.getMockLessons()
        }
    }
    
    private func loadRecentArtworks() async {
        do {
            let artworks = await galleryService.loadArtworks()
            recentArtworks = artworks
                .sorted { $0.modifiedAt > $1.modifiedAt }
                .prefix(5)
                .map { $0 }
        } catch {
            print("Failed to load artworks: \(error)")
        }
    }
    
    private func loadWeeklyStats() async {
        do {
            weeklyStats = try await userService.getWeeklyStats()
        } catch {
            print("Failed to load weekly stats: \(error)")
        }
    }
    
    private func loadAchievements() {
        // Mock achievements for now
        achievements = [
            Achievement(
                id: "first_lesson",
                title: "First Steps",
                description: "Complete your first lesson",
                icon: "star.fill",
                unlockedDate: totalXP > 0 ? Date() : nil,
                progress: totalXP > 0 ? 1.0 : 0.0,
                xpReward: 50
            ),
            Achievement(
                id: "week_streak",
                title: "Week Warrior",
                description: "7 day streak",
                icon: "flame.fill",
                unlockedDate: currentStreak >= 7 ? Date() : nil,
                progress: min(Double(currentStreak) / 7.0, 1.0),
                xpReward: 100
            ),
            Achievement(
                id: "xp_milestone",
                title: "XP Master",
                description: "Earn 500 XP",
                icon: "star.circle.fill",
                unlockedDate: totalXP >= 500 ? Date() : nil,
                progress: min(Double(totalXP) / 500.0, 1.0),
                xpReward: 150
            )
        ]
    }
    
    // MARK: - Celebrations
    private func checkForCelebrations() {
        // Check for streak milestones
        if currentStreak > 0 && currentStreak % 7 == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showStreakCelebration = true
            }
        }
    }
    
    // MARK: - Lesson Progress
    func getLessonProgress(for lessonId: String) -> Double? {
        // This would fetch from actual progress data
        // Mock implementation for now
        return Double.random(in: 0.1...0.8)
    }
}
