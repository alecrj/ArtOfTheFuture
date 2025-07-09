// MARK: - User Profile & Progress Model
// File: ArtOfTheFuture/Core/Models/UserProfile.swift
// This is the SINGLE SOURCE OF TRUTH for all user progress data

import Foundation

struct UserProfile: Codable {
    let id: String
    var displayName: String
    var email: String?
    var avatarImageName: String?
    
    // Progress Data
    var level: Int = 1
    var totalXP: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastActiveDate: Date = Date()
    
    // Lesson Progress
    var lessonProgress: [String: LessonProgress] = [:] // lessonId -> progress
    var completedLessons: Set<String> = []
    var unlockedLessons: Set<String> = ["lesson_001"] // Start with first lesson unlocked
    
    // Skills & Badges
    var skillProgress: [String: SkillProgress] = [:] // skillId -> progress
    var earnedBadges: Set<String> = []
    var badgeProgress: [String: BadgeProgress] = [:]
    
    // Settings
    var dailyGoalMinutes: Int = 15
    var preferredDifficulty: DifficultyLevel = .beginner
    
    // Computed Properties
    var xpToNextLevel: Int {
        return (level + 1) * 100 - (totalXP % ((level + 1) * 100))
    }
    
    var levelProgress: Double {
        let xpInCurrentLevel = totalXP % ((level + 1) * 100)
        let xpNeededForLevel = (level + 1) * 100
        return Double(xpInCurrentLevel) / Double(xpNeededForLevel)
    }
}

// MARK: - Lesson Progress
struct LessonProgress: Codable {
    let lessonId: String
    var isCompleted: Bool = false
    var isUnlocked: Bool = false
    var bestScore: Double = 0.0
    var totalAttempts: Int = 0
    var stepProgress: [String: StepProgress] = [:] // stepId -> progress
    var lastAttemptDate: Date?
    var totalTimeSpent: TimeInterval = 0
    
    // Computed
    var completionPercentage: Double {
        guard !stepProgress.isEmpty else { return 0 }
        let completed = stepProgress.values.filter { $0.isCompleted }.count
        return Double(completed) / Double(stepProgress.count)
    }
}

// MARK: - Step Progress
struct StepProgress: Codable {
    let stepId: String
    var isCompleted: Bool = false
    var attempts: Int = 0
    var bestScore: Double = 0.0
    var timeSpent: TimeInterval = 0
    var lastAttemptDate: Date?
}

// MARK: - Skill Progress
struct SkillProgress: Codable {
    let skillId: String
    var level: Int = 0 // 0-10
    var xp: Int = 0
    var lastPracticed: Date?
    
    // Computed
    var mastery: Double {
        return Double(level) / 10.0
    }
}

// MARK: - Badge Progress
struct BadgeProgress: Codable {
    let badgeId: String
    var currentValue: Int = 0
    var targetValue: Int
    var isUnlocked: Bool = false
    var unlockedDate: Date?
    
    // Computed
    var progress: Double {
        return min(1.0, Double(currentValue) / Double(targetValue))
    }
}

// MARK: - Daily Activity
struct DailyActivity: Codable {
    let date: Date
    var minutesPracticed: Int = 0
    var xpEarned: Int = 0
    var lessonsCompleted: Int = 0
    var stepsCompleted: Int = 0
}

// MARK: - User Statistics
extension UserProfile {
    var statistics: UserStatistics {
        UserStatistics(
            totalLessonsCompleted: completedLessons.count,
            totalXP: totalXP,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            totalBadges: earnedBadges.count,
            averageScore: calculateAverageScore(),
            totalTimeSpent: calculateTotalTimeSpent(),
            favoriteCategory: calculateFavoriteCategory()
        )
    }
    
    private func calculateAverageScore() -> Double {
        let scores = lessonProgress.values.compactMap { $0.bestScore }
        guard !scores.isEmpty else { return 0 }
        return scores.reduce(0, +) / Double(scores.count)
    }
    
    private func calculateTotalTimeSpent() -> TimeInterval {
        return lessonProgress.values.reduce(0) { $0 + $1.totalTimeSpent }
    }
    
    private func calculateFavoriteCategory() -> LessonCategory? {
        // This would analyze completed lessons to find most practiced category
        return nil
    }
}

struct UserStatistics {
    let totalLessonsCompleted: Int
    let totalXP: Int
    let currentStreak: Int
    let longestStreak: Int
    let totalBadges: Int
    let averageScore: Double
    let totalTimeSpent: TimeInterval
    let favoriteCategory: LessonCategory?
}
