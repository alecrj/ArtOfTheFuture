// MARK: - Updated Home Dashboard View Model (Real Firestore Data)
// File: ArtOfTheFuture/Features/Home/ViewModels/HomeDashboardViewModel.swift

import SwiftUI
import Combine

@MainActor
final class HomeDashboardViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var userName = ""
    @Published var totalXP = 0
    @Published var currentLevel = 1
    @Published var xpToNextLevel = 100
    @Published var levelProgress: Double = 0.0
    @Published var currentStreak = 0
    
    // Today's Progress
    @Published var todayMinutes = 0
    @Published var targetMinutes = 15
    @Published var lessonsCompleted = 0
    @Published var todayXP = 0
    
    // Content
    @Published var recommendedLessons: [Lesson] = []
    @Published var recentArtworks: [String] = []
    @Published var weeklyStats = WeeklyStats(
        days: [],
        totalMinutes: 0,
        totalXP: 0,
        averageMinutesPerDay: 0
    )
    @Published var achievements: [Achievement] = []
    
    // UI State
    @Published var isLoading = true
    @Published var showStreakCelebration = false
    @Published var showLevelUpCelebration = false
    @Published var showXPAnimation = false
    @Published var newXPGained = 0
    
    // MARK: - Services
    private let userDataService = UserDataService.shared
    private let lessonService = LessonService.shared
    private let progressService = ProgressService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Listen to user data changes
        userDataService.$currentUser
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.updateFromUser(user)
            }
            .store(in: &cancellables)
        
        userDataService.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                self?.isLoading = loading
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    func loadDashboard() async {
        isLoading = true
        
        // If user data service has current user, update immediately
        if let user = userDataService.currentUser {
            updateFromUser(user)
        }
        
        // Load additional content
        await loadTodayProgress()
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
        
        // Reload user data to get latest XP
        if let uid = userDataService.currentUserUID {
            await userDataService.loadUserData(uid: uid)
        }
        
        if totalXP > previousXP {
            newXPGained = totalXP - previousXP
            showXPAnimation = true
        }
    }
    
    // MARK: - Private Methods
    
    private func updateFromUser(_ user: User) {
        userName = user.displayName
        totalXP = user.totalXP
        currentLevel = user.currentLevel
        currentStreak = user.currentStreak
        
        // Calculate level progress
        let currentLevelXP = totalXP % 100
        xpToNextLevel = 100 - currentLevelXP
        levelProgress = Double(currentLevelXP) / 100.0
        
        print("🔥 Dashboard updated with real user data: \(userName), XP: \(totalXP)")
    }
    
    private func loadTodayProgress() async {
        // Get target from user preferences or default
        targetMinutes = UserDefaults.standard.object(forKey: "dailyGoalMinutes") as? Int ?? 15
        
        // For now, simulate today's progress
        // TODO: Implement real daily progress tracking in Firestore
        todayMinutes = Int.random(in: 0...targetMinutes)
        lessonsCompleted = Int.random(in: 0...3)
        todayXP = lessonsCompleted * 25
    }
    
    private func loadRecommendedLessons() async {
        // Load recommended lessons based on user level
        do {
            let allLessons = try await lessonService.getAllLessons()
            recommendedLessons = Array(allLessons.prefix(3))
        } catch {
            print("Failed to load lessons: \(error)")
            recommendedLessons = []
        }
    }
    
    private func loadRecentArtworks() async {
        // TODO: Load real artworks from Firestore
        recentArtworks = [
            "drawing_1", "drawing_2", "drawing_3"
        ]
    }
    
    private func loadWeeklyStats() async {
        // TODO: Calculate real weekly stats from Firestore
        weeklyStats = WeeklyStats(
            days: [], // Empty for now - will be populated with real data later
            totalMinutes: todayMinutes * 7,
            totalXP: todayXP * 7,
            averageMinutesPerDay: Double(todayMinutes)
        )
    }
    
    private func loadAchievements() {
        // TODO: Load real achievements from Firestore
        achievements = [
            Achievement(
                id: "first_lesson",
                title: "First Steps",
                description: "Complete your first lesson",
                icon: "star.fill",
                unlockedDate: currentStreak > 0 ? Date() : nil,
                progress: currentStreak > 0 ? 1.0 : 0.0,
                xpReward: 50
            ),
            Achievement(
                id: "streak_7",
                title: "Week Warrior",
                description: "Maintain a 7-day streak",
                icon: "flame.fill",
                unlockedDate: currentStreak >= 7 ? Date() : nil,
                progress: min(Double(currentStreak) / 7.0, 1.0),
                xpReward: 100
            )
        ]
    }
    
    private func checkForCelebrations() {
        // Check for level up
        if currentLevel > UserDefaults.standard.integer(forKey: "lastKnownLevel") {
            showLevelUpCelebration = true
            UserDefaults.standard.set(currentLevel, forKey: "lastKnownLevel")
        }
        
        // Check for streak milestone
        if currentStreak > 0 && currentStreak % 7 == 0 {
            showStreakCelebration = true
        }
    }
    
    // MARK: - Actions
    
    func completeLesson(xpGained: Int) async {
        let newTotalXP = totalXP + xpGained
        await userDataService.updateUserXP(newXP: newTotalXP)
        
        // Animate XP gain
        newXPGained = xpGained
        showXPAnimation = true
    }
    
    func updateStreak() async {
        let newStreak = currentStreak + 1
        await userDataService.updateUserStreak(newStreak: newStreak)
    }
}
