// MARK: - Complete Lessons Progress Service Implementation
// **REPLACE:** ArtOfTheFuture/Features/Lessons/Services/LessonsProgressService.swift

import Foundation
import SwiftUI

@MainActor
final class LessonsProgressService: ObservableObject {
    static let shared = LessonsProgressService()
    
    // MARK: - Published Properties
    @Published var currentUserProgress: UserLearningProgress = UserLearningProgress()
    @Published var dailyGoalProgress: DailyGoalProgress = DailyGoalProgress()
    @Published var weeklyStats: WeeklyLearningStats = WeeklyLearningStats()
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let progressService: ProgressServiceProtocol
    private let lessonService: LessonServiceProtocol
    
    // Storage Keys
    private let userProgressKey = "userLearningProgress"
    private let dailyGoalKey = "dailyGoalProgress"
    private let weeklyStatsKey = "weeklyLearningStats"
    private let lastActivityDateKey = "lastActivityDate"
    
    // MARK: - Initialization
    private init() {
        self.progressService = Container.shared.progressService
        self.lessonService = Container.shared.lessonService
        
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        
        loadUserProgress()
        checkDailyReset()
    }
    
    // MARK: - Core Progress Management
    
    /// Load user's learning progress from storage
    private func loadUserProgress() {
        // Load main progress
        if let data = userDefaults.data(forKey: userProgressKey),
           let progress = try? decoder.decode(UserLearningProgress.self, from: data) {
            currentUserProgress = progress
        }
        
        // Load daily goal progress
        if let data = userDefaults.data(forKey: dailyGoalKey),
           let dailyProgress = try? decoder.decode(DailyGoalProgress.self, from: data) {
            dailyGoalProgress = dailyProgress
        }
        
        // Load weekly stats
        if let data = userDefaults.data(forKey: weeklyStatsKey),
           let weekly = try? decoder.decode(WeeklyLearningStats.self, from: data) {
            weeklyStats = weekly
        }
    }
    
    /// Save user progress to storage
    private func saveUserProgress() {
        do {
            // Save main progress
            let progressData = try encoder.encode(currentUserProgress)
            userDefaults.set(progressData, forKey: userProgressKey)
            
            // Save daily goal progress
            let dailyData = try encoder.encode(dailyGoalProgress)
            userDefaults.set(dailyData, forKey: dailyGoalKey)
            
            // Save weekly stats
            let weeklyData = try encoder.encode(weeklyStats)
            userDefaults.set(weeklyData, forKey: weeklyStatsKey)
            
            // Update last activity
            userDefaults.set(Date(), forKey: lastActivityDateKey)
            
        } catch {
            print("❌ Failed to save user progress: \(error)")
        }
    }
    
    /// Check if we need to reset daily progress
    private func checkDailyReset() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastActivity = userDefaults.object(forKey: lastActivityDateKey) as? Date {
            let lastActivityDay = calendar.startOfDay(for: lastActivity)
            
            if today > lastActivityDay {
                // Reset daily progress
                resetDailyProgress()
                
                // Update streak
                let daysDifference = calendar.dateComponents([.day], from: lastActivityDay, to: today).day ?? 0
                if daysDifference == 1 {
                    // Consecutive day - maintain streak
                    currentUserProgress.currentStreak = max(currentUserProgress.currentStreak, 1)
                } else if daysDifference > 1 {
                    // Streak broken
                    currentUserProgress.currentStreak = 0
                }
            }
        }
    }
    
    /// Reset daily progress for new day
    private func resetDailyProgress() {
        // Archive yesterday's progress to weekly stats
        archiveDailyToWeekly()
        
        // Reset daily counters
        dailyGoalProgress = DailyGoalProgress(
            targetMinutes: dailyGoalProgress.targetMinutes,
            targetLessons: dailyGoalProgress.targetLessons,
            targetXP: dailyGoalProgress.targetXP
        )
        
        saveUserProgress()
    }
    
    /// Archive daily progress to weekly stats
    private func archiveDailyToWeekly() {
        let dayStats = DailyLearningStats(
            date: Date(),
            minutesPracticed: dailyGoalProgress.completedMinutes,
            lessonsCompleted: dailyGoalProgress.completedLessons,
            xpEarned: dailyGoalProgress.completedXP,
            artworksCreated: dailyGoalProgress.artworksCreated,
            streakDay: currentUserProgress.currentStreak
        )
        
        weeklyStats.addDayStats(dayStats)
        
        // Keep only last 30 days
        weeklyStats.limitToRecentDays(30)
    }
    
    // MARK: - Progress Tracking Methods
    
    /// Record lesson completion
    func completeLesson(_ lesson: Lesson, timeSpent: TimeInterval, accuracy: Double) async {
        let minutes = Int(timeSpent / 60)
        
        // Update daily progress
        dailyGoalProgress.completedLessons += 1
        dailyGoalProgress.completedMinutes += minutes
        dailyGoalProgress.completedXP += lesson.xpReward
        
        // Update overall progress
        currentUserProgress.totalLessonsCompleted += 1
        currentUserProgress.totalMinutesLearned += minutes
        currentUserProgress.totalXP += lesson.xpReward
        currentUserProgress.lastLessonDate = Date()
        
        // Update accuracy tracking
        updateAccuracyHistory(accuracy)
        
        // Update skill progress for lesson category
        updateSkillProgress(for: lesson.category, xpGained: lesson.xpReward)
        
        // Check for streak update
        updateStreak()
        
        // Check achievements
        await checkAndUnlockAchievements()
        
        // Save progress
        saveUserProgress()
        
        // Post notification for UI updates
        NotificationCenter.default.post(name: .lessonCompleted, object: lesson)
        
        print("✅ Lesson completed: \(lesson.title) (+\(lesson.xpReward) XP)")
    }
    
    /// Record drawing/artwork creation
    func recordArtworkCreation(timeSpent: TimeInterval, strokeCount: Int, usedTechniques: [String] = []) {
        let minutes = Int(timeSpent / 60)
        
        // Update daily progress
        dailyGoalProgress.completedMinutes += minutes
        dailyGoalProgress.artworksCreated += 1
        
        // Update overall progress
        currentUserProgress.totalMinutesLearned += minutes
        currentUserProgress.totalArtworksCreated += 1
        currentUserProgress.lastActivityDate = Date()
        
        // Award XP for free drawing (based on time and complexity)
        let xpEarned = calculateFreeDrawingXP(timeSpent: timeSpent, strokeCount: strokeCount)
        dailyGoalProgress.completedXP += xpEarned
        currentUserProgress.totalXP += xpEarned
        
        // Update techniques used
        for technique in usedTechniques {
            currentUserProgress.techniquesUsed.insert(technique)
        }
        
        updateStreak()
        saveUserProgress()
        
        print("🎨 Artwork created: +\(xpEarned) XP (\(minutes) min)")
    }
    
    /// Record practice session (without completing lesson)
    func recordPracticeSession(timeSpent: TimeInterval, activityType: PracticeActivityType) {
        let minutes = Int(timeSpent / 60)
        
        dailyGoalProgress.completedMinutes += minutes
        currentUserProgress.totalMinutesLearned += minutes
        currentUserProgress.lastActivityDate = Date()
        
        // Award small XP for practice
        let xpEarned = max(5, minutes * 2)
        dailyGoalProgress.completedXP += xpEarned
        currentUserProgress.totalXP += xpEarned
        
        updateStreak()
        saveUserProgress()
    }
    
    /// Update accuracy history with weighted average
    private func updateAccuracyHistory(_ newAccuracy: Double) {
        currentUserProgress.accuracyHistory.append(newAccuracy)
        
        // Keep only last 20 scores
        if currentUserProgress.accuracyHistory.count > 20 {
            currentUserProgress.accuracyHistory.removeFirst()
        }
        
        // Calculate new average
        let totalAccuracy = currentUserProgress.accuracyHistory.reduce(0, +)
        currentUserProgress.averageAccuracy = totalAccuracy / Double(currentUserProgress.accuracyHistory.count)
    }
    
    /// Update skill progress for specific category
    private func updateSkillProgress(for category: LessonCategory, xpGained: Int) {
        let skillId = category.rawValue
        var skillProgress = currentUserProgress.skillProgress[skillId] ?? SkillCategoryProgress(
            categoryId: skillId,
            categoryName: category.rawValue
        )
        
        skillProgress.totalXP += xpGained
        skillProgress.lessonsCompleted += 1
        skillProgress.lastPracticed = Date()
        
        // Calculate new level (every 200 XP = 1 level)
        let newLevel = (skillProgress.totalXP / 200) + 1
        if newLevel > skillProgress.currentLevel {
            skillProgress.currentLevel = newLevel
            // Post notification for level up celebration
            NotificationCenter.default.post(
                name: .skillLevelUp,
                object: ["skill": skillId, "level": newLevel]
            )
        }
        
        currentUserProgress.skillProgress[skillId] = skillProgress
    }
    
    /// Update daily streak
    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastActivity = currentUserProgress.lastActivityDate {
            let lastActivityDay = calendar.startOfDay(for: lastActivity)
            
            if today == lastActivityDay {
                // Same day - already counted
                return
            } else if calendar.dateComponents([.day], from: lastActivityDay, to: today).day == 1 {
                // Next day - increment streak
                currentUserProgress.currentStreak += 1
                currentUserProgress.longestStreak = max(currentUserProgress.longestStreak, currentUserProgress.currentStreak)
            }
        } else {
            // First activity ever
            currentUserProgress.currentStreak = 1
        }
        
        currentUserProgress.lastActivityDate = Date()
    }
    
    /// Calculate XP for free drawing based on complexity
    private func calculateFreeDrawingXP(timeSpent: TimeInterval, strokeCount: Int) -> Int {
        let baseXP = Int(timeSpent / 60) * 5 // 5 XP per minute
        let complexityBonus = min(strokeCount / 10, 50) // Up to 50 bonus XP for complexity
        return baseXP + complexityBonus
    }
    
    // MARK: - Achievement System
    
    /// Check and unlock achievements based on current progress
    private func checkAndUnlockAchievements() async {
        let allAchievements = AchievementDefinitions.allAchievements
        
        for achievement in allAchievements {
            // Skip already unlocked achievements
            if currentUserProgress.unlockedAchievements.contains(achievement.id) {
                continue
            }
            
            // Check if requirements are met
            if checkAchievementRequirement(achievement) {
                unlockAchievement(achievement)
            }
        }
    }
    
    /// Check if specific achievement requirements are met
    private func checkAchievementRequirement(_ achievement: AchievementDefinition) -> Bool {
        switch achievement.requirement {
        case .completeLessons(let count):
            return currentUserProgress.totalLessonsCompleted >= count
            
        case .earnXP(let amount):
            return currentUserProgress.totalXP >= amount
            
        case .maintainStreak(let days):
            return currentUserProgress.currentStreak >= days
            
        case .createArtworks(let count):
            return currentUserProgress.totalArtworksCreated >= count
            
        case .masterSkill(let skillId, let level):
            return currentUserProgress.skillProgress[skillId]?.currentLevel ?? 0 >= level
            
        case .practiceMinutes(let minutes):
            return currentUserProgress.totalMinutesLearned >= minutes
            
        case .achieveAccuracy(let accuracy):
            return currentUserProgress.averageAccuracy >= accuracy
            
        case .useTechniques(let count):
            return currentUserProgress.techniquesUsed.count >= count
        }
    }
    
    /// Unlock achievement and notify UI
    private func unlockAchievement(_ achievement: AchievementDefinition) {
        currentUserProgress.unlockedAchievements.insert(achievement.id)
        
        // Award achievement XP
        currentUserProgress.totalXP += achievement.xpReward
        dailyGoalProgress.completedXP += achievement.xpReward
        
        saveUserProgress()
        
        // Post notification for celebration UI
        NotificationCenter.default.post(
            name: .achievementUnlocked,
            object: achievement
        )
        
        print("🏆 Achievement unlocked: \(achievement.title) (+\(achievement.xpReward) XP)")
    }
    
    // MARK: - Goal Management
    
    /// Update daily goal targets
    func updateDailyGoals(minutes: Int, lessons: Int, xp: Int) {
        dailyGoalProgress.targetMinutes = minutes
        dailyGoalProgress.targetLessons = lessons
        dailyGoalProgress.targetXP = xp
        saveUserProgress()
    }
    
    /// Get current daily goal completion percentage
    func getDailyGoalCompletion() -> DailyGoalCompletion {
        return DailyGoalCompletion(
            minutesProgress: min(1.0, Double(dailyGoalProgress.completedMinutes) / Double(dailyGoalProgress.targetMinutes)),
            lessonsProgress: min(1.0, Double(dailyGoalProgress.completedLessons) / Double(dailyGoalProgress.targetLessons)),
            xpProgress: min(1.0, Double(dailyGoalProgress.completedXP) / Double(dailyGoalProgress.targetXP)),
            isComplete: dailyGoalProgress.isComplete
        )
    }
    
    // MARK: - Analytics & Insights
    
    /// Get learning insights for the user
    func getLearningInsights() -> LearningInsights {
        let insights = LearningInsights(
            averageSessionTime: calculateAverageSessionTime(),
            mostProductiveTimeOfDay: findMostProductiveTime(),
            strongestSkills: getStrongestSkills(),
            improvementAreas: getImprovementAreas(),
            weeklyTrend: calculateWeeklyTrend(),
            motivationalMessage: generateMotivationalMessage()
        )
        
        return insights
    }
    
    private func calculateAverageSessionTime() -> TimeInterval {
        let recentSessions = weeklyStats.dailyStats.suffix(7)
        guard !recentSessions.isEmpty else { return 0 }
        
        let totalMinutes = recentSessions.reduce(0) { $0 + $1.minutesPracticed }
        let totalSessions = recentSessions.filter { $0.minutesPracticed > 0 }.count
        
        return totalSessions > 0 ? TimeInterval(totalMinutes * 60 / totalSessions) : 0
    }
    
    private func findMostProductiveTime() -> String {
        // This would analyze session times - simplified for now
        return "Evening"
    }
    
    private func getStrongestSkills() -> [String] {
        return currentUserProgress.skillProgress.values
            .sorted { $0.currentLevel > $1.currentLevel }
            .prefix(3)
            .map { $0.categoryName }
    }
    
    private func getImprovementAreas() -> [String] {
        return currentUserProgress.skillProgress.values
            .sorted { $0.currentLevel < $1.currentLevel }
            .prefix(2)
            .map { $0.categoryName }
    }
    
    private func calculateWeeklyTrend() -> Double {
        let recentWeeks = weeklyStats.getWeeklyTotals()
        guard recentWeeks.count >= 2 else { return 0 }
        
        let thisWeek = recentWeeks.last?.minutesPracticed ?? 0
        let lastWeek = recentWeeks[recentWeeks.count - 2].minutesPracticed
        
        guard lastWeek > 0 else { return 0 }
        return Double(thisWeek - lastWeek) / Double(lastWeek)
    }
    
    private func generateMotivationalMessage() -> String {
        let messages = [
            "You're making amazing progress! Keep it up! 🎨",
            "Your consistency is paying off - you're becoming a true artist! ✨",
            "Every stroke makes you better. You're on the right path! 🚀",
            "Your dedication to learning is inspiring! 🌟",
            "Art is a journey, and you're traveling it beautifully! 🎯"
        ]
        
        return messages.randomElement() ?? messages[0]
    }
    
    // MARK: - Data Export/Import
    
    /// Export user progress for backup
    func exportProgress() -> Data? {
        do {
            let exportData = ProgressExportData(
                userProgress: currentUserProgress,
                dailyGoal: dailyGoalProgress,
                weeklyStats: weeklyStats,
                exportDate: Date()
            )
            return try encoder.encode(exportData)
        } catch {
            print("❌ Failed to export progress: \(error)")
            return nil
        }
    }
    
    /// Import user progress from backup
    func importProgress(from data: Data) -> Bool {
        do {
            let importData = try decoder.decode(ProgressExportData.self, from: data)
            
            currentUserProgress = importData.userProgress
            dailyGoalProgress = importData.dailyGoal
            weeklyStats = importData.weeklyStats
            
            saveUserProgress()
            return true
        } catch {
            print("❌ Failed to import progress: \(error)")
            return false
        }
    }
    
    /// Reset all progress (for debugging or user request)
    func resetAllProgress() {
        currentUserProgress = UserLearningProgress()
        dailyGoalProgress = DailyGoalProgress()
        weeklyStats = WeeklyLearningStats()
        
        // Clear UserDefaults
        userDefaults.removeObject(forKey: userProgressKey)
        userDefaults.removeObject(forKey: dailyGoalKey)
        userDefaults.removeObject(forKey: weeklyStatsKey)
        userDefaults.removeObject(forKey: lastActivityDateKey)
        
        print("🗑️ All progress reset")
    }
}

// MARK: - Data Models

struct UserLearningProgress: Codable {
    var totalXP: Int = 0
    var totalLessonsCompleted: Int = 0
    var totalMinutesLearned: Int = 0
    var totalArtworksCreated: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var averageAccuracy: Double = 0.0
    var lastActivityDate: Date?
    var lastLessonDate: Date?
    
    var skillProgress: [String: SkillCategoryProgress] = [:]
    var unlockedAchievements: Set<String> = []
    var accuracyHistory: [Double] = []
    var techniquesUsed: Set<String> = []
}

struct SkillCategoryProgress: Codable {
    let categoryId: String
    let categoryName: String
    var currentLevel: Int = 1
    var totalXP: Int = 0
    var lessonsCompleted: Int = 0
    var lastPracticed: Date?
    
    var progressToNextLevel: Double {
        let xpForNextLevel = currentLevel * 200
        let xpInCurrentLevel = totalXP % 200
        return Double(xpInCurrentLevel) / Double(xpForNextLevel)
    }
}

struct DailyGoalProgress: Codable {
    var targetMinutes: Int = 15
    var targetLessons: Int = 1
    var targetXP: Int = 50
    
    var completedMinutes: Int = 0
    var completedLessons: Int = 0
    var completedXP: Int = 0
    var artworksCreated: Int = 0
    
    var isComplete: Bool {
        return completedMinutes >= targetMinutes &&
               completedLessons >= targetLessons &&
               completedXP >= targetXP
    }
}

struct DailyLearningStats: Codable {
    let date: Date
    let minutesPracticed: Int
    let lessonsCompleted: Int
    let xpEarned: Int
    let artworksCreated: Int
    let streakDay: Int
}

struct WeeklyLearningStats: Codable {
    var dailyStats: [DailyLearningStats] = []
    
    mutating func addDayStats(_ stats: DailyLearningStats) {
        dailyStats.append(stats)
    }
    
    mutating func limitToRecentDays(_ days: Int) {
        if dailyStats.count > days {
            dailyStats = Array(dailyStats.suffix(days))
        }
    }
    
    func getWeeklyTotals() -> [WeeklyTotal] {
        let calendar = Calendar.current
        var weeklyTotals: [WeeklyTotal] = []
        
        for stats in dailyStats {
            let weekOfYear = calendar.component(.weekOfYear, from: stats.date)
            let year = calendar.component(.year, from: stats.date)
            
            if let existingWeek = weeklyTotals.first(where: { $0.week == weekOfYear && $0.year == year }) {
                existingWeek.minutesPracticed += stats.minutesPracticed
                existingWeek.xpEarned += stats.xpEarned
                existingWeek.lessonsCompleted += stats.lessonsCompleted
            } else {
                weeklyTotals.append(WeeklyTotal(
                    week: weekOfYear,
                    year: year,
                    minutesPracticed: stats.minutesPracticed,
                    xpEarned: stats.xpEarned,
                    lessonsCompleted: stats.lessonsCompleted
                ))
            }
        }
        
        return weeklyTotals
    }
}

class WeeklyTotal {
    let week: Int
    let year: Int
    var minutesPracticed: Int
    var xpEarned: Int
    var lessonsCompleted: Int
    
    init(week: Int, year: Int, minutesPracticed: Int, xpEarned: Int, lessonsCompleted: Int) {
        self.week = week
        self.year = year
        self.minutesPracticed = minutesPracticed
        self.xpEarned = xpEarned
        self.lessonsCompleted = lessonsCompleted
    }
}

struct DailyGoalCompletion {
    let minutesProgress: Double
    let lessonsProgress: Double
    let xpProgress: Double
    let isComplete: Bool
}

struct LearningInsights {
    let averageSessionTime: TimeInterval
    let mostProductiveTimeOfDay: String
    let strongestSkills: [String]
    let improvementAreas: [String]
    let weeklyTrend: Double
    let motivationalMessage: String
}

struct ProgressExportData: Codable {
    let userProgress: UserLearningProgress
    let dailyGoal: DailyGoalProgress
    let weeklyStats: WeeklyLearningStats
    let exportDate: Date
}

enum PracticeActivityType: String, Codable {
    case freeDrawing = "Free Drawing"
    case lessonPractice = "Lesson Practice"
    case dailyChallenge = "Daily Challenge"
    case skillPractice = "Skill Practice"
}

// MARK: - Achievement Definitions

struct AchievementDefinition {
    let id: String
    let title: String
    let description: String
    let icon: String
    let xpReward: Int
    let requirement: AchievementRequirement
}

enum AchievementRequirement {
    case completeLessons(Int)
    case earnXP(Int)
    case maintainStreak(Int)
    case createArtworks(Int)
    case masterSkill(String, level: Int)
    case practiceMinutes(Int)
    case achieveAccuracy(Double)
    case useTechniques(Int)
}

struct AchievementDefinitions {
    static let allAchievements: [AchievementDefinition] = [
        // Learning Achievements
        AchievementDefinition(
            id: "first_lesson",
            title: "First Steps",
            description: "Complete your first lesson",
            icon: "star.fill",
            xpReward: 50,
            requirement: .completeLessons(1)
        ),
        AchievementDefinition(
            id: "lesson_streak_3",
            title: "Getting Started",
            description: "Complete 3 lessons",
            icon: "flame.fill",
            xpReward: 100,
            requirement: .completeLessons(3)
        ),
        AchievementDefinition(
            id: "lesson_streak_10",
            title: "Dedicated Learner",
            description: "Complete 10 lessons",
            icon: "book.fill",
            xpReward: 200,
            requirement: .completeLessons(10)
        ),
        
        // Streak Achievements
        AchievementDefinition(
            id: "daily_streak_3",
            title: "Building Habits",
            description: "Practice 3 days in a row",
            icon: "calendar",
            xpReward: 75,
            requirement: .maintainStreak(3)
        ),
        AchievementDefinition(
            id: "daily_streak_7",
            title: "Week Warrior",
            description: "Practice 7 days in a row",
            icon: "flame.fill",
            xpReward: 150,
            requirement: .maintainStreak(7)
        ),
        AchievementDefinition(
            id: "daily_streak_30",
            title: "Monthly Master",
            description: "Practice 30 days in a row",
            icon: "crown.fill",
            xpReward: 500,
            requirement: .maintainStreak(30)
        ),
        
        // XP Achievements
        AchievementDefinition(
            id: "xp_milestone_500",
            title: "Rising Artist",
            description: "Earn 500 XP",
            icon: "star.circle.fill",
            xpReward: 100,
            requirement: .earnXP(500)
        ),
        AchievementDefinition(
            id: "xp_milestone_2000",
            title: "Skilled Creator",
            description: "Earn 2000 XP",
            icon: "sparkles",
            xpReward: 250,
            requirement: .earnXP(2000)
        ),
        
        // Creative Achievements
        AchievementDefinition(
            id: "artwork_creator_5",
            title: "Creative Spirit",
            description: "Create 5 artworks",
            icon: "paintbrush.fill",
            xpReward: 125,
            requirement: .createArtworks(5)
        ),
        AchievementDefinition(
            id: "artwork_creator_25",
            title: "Prolific Artist",
            description: "Create 25 artworks",
            icon: "photo.stack.fill",
            xpReward: 300,
            requirement: .createArtworks(25)
        ),
        
        // Time Achievements
        AchievementDefinition(
            id: "practice_time_600",
            title: "Dedicated Practicer",
            description: "Practice for 10 hours total",
            icon: "clock.fill",
            xpReward: 200,
            requirement: .practiceMinutes(600)
        ),
        
        // Skill Mastery
        AchievementDefinition(
            id: "master_basics",
            title: "Basics Master",
            description: "Master the Basics skill category",
            icon: "checkmark.seal.fill",
            xpReward: 400,
            requirement: .masterSkill("Basics", level: 5)
        )
    ]
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let skillLevelUp = Notification.Name("skillLevelUp")
}
