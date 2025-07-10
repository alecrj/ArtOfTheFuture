// MARK: - User Model (Single Source of Truth)
// File: ArtOfTheFuture/Core/Models/User.swift

import Foundation

struct User: Identifiable, Codable {
    let id: String
    var displayName: String
    var email: String?
    var profileImageURL: String?
    var totalXP: Int = 0
    var currentLevel: Int = 1
    var currentStreak: Int = 0
    var joinedDate: Date = Date()
    
    var levelProgress: Double {
        // XP needed per level increases by 100 each level
        let xpForCurrentLevel = (currentLevel - 1) * 100
        let xpForNextLevel = currentLevel * 100
        let currentLevelXP = totalXP - xpForCurrentLevel
        return Double(currentLevelXP) / Double(xpForNextLevel - xpForCurrentLevel)
    }
    
    static var mock: User {
        User(
            id: "mock",
            displayName: "Demo User",
            email: "demo@example.com",
            profileImageURL: nil,
            totalXP: 1200,
            currentLevel: 4,
            currentStreak: 9,
            joinedDate: Date()
        )
    }
}

// MARK: - User Profile (Extended User Model)
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
    
    // Lesson Progress - Using types from LessonModels.swift
    var lessonProgress: [String: LessonProgress] = [:]
    var completedLessons: Set<String> = []
    var unlockedLessons: Set<String> = ["lesson_001"]
    
    // Skills & Badges
    var skillProgress: [String: SkillProgress] = [:]
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

// MARK: - Daily Activity
struct DailyActivity: Codable {
    let date: Date
    var minutesPracticed: Int = 0
    var xpEarned: Int = 0
    var lessonsCompleted: Int = 0
    var stepsCompleted: Int = 0
}

// MARK: - Supporting Progress Types
struct SkillProgress: Codable {
    let skillId: String
    var level: Int = 0
    var xp: Int = 0
    var lastPracticed: Date?
    
    var mastery: Double {
        return Double(level) / 10.0
    }
}

struct BadgeProgress: Codable {
    let badgeId: String
    var currentValue: Int = 0
    var targetValue: Int
    var isUnlocked: Bool = false
    var unlockedDate: Date?
    
    var progress: Double {
        return min(1.0, Double(currentValue) / Double(targetValue))
    }
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
