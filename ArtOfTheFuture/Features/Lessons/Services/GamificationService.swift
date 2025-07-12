// MARK: - Advanced Gamification System (Duolingo-Style)
// File: ArtOfTheFuture/Features/Lessons/Services/GamificationService.swift

import Foundation
import SwiftUI
import Combine

protocol GamificationServiceProtocol {
    // Hearts & Lives System
    func getCurrentHearts() async -> Int
    func consumeHeart() async throws
    func refillHearts() async throws
    func getHeartRefillTime() async -> Date?
    
    // Daily Quests & Challenges
    func getDailyQuests() async throws -> [DailyQuest]
    func completeDailyQuest(questId: String) async throws
    func getWeeklyChallenge() async throws -> WeeklyChallenge?
    func generateNewDailyQuests() async throws
    
    // Streak Management
    func updateStreak() async throws
    func getStreakInfo() async -> StreakInfo
    func getStreakFreeze() async -> Bool
    func useStreakFreeze() async throws
    
    // XP & Leveling
    func awardXP(_ amount: Int, source: XPSource) async throws
    func getCurrentLevel() async -> UserLevel
    func getLevelProgress() async -> LevelProgress
    
    // Badges & Achievements
    func checkBadgeProgress() async throws
    func awardBadge(_ badgeId: String) async throws
    func getAllBadges() async -> [GameBadge]
    func getUserBadges() async -> [GameBadge]
    
    // Leaderboards & Social
    func getLeaderboard(type: LeaderboardType, timeframe: TimeFrame) async throws -> Leaderboard
    func updateLeaderboardScore(score: Int, type: LeaderboardType) async throws
}

// MARK: - Gamification Service Implementation
final class GamificationService: GamificationServiceProtocol, ObservableObject {
    static let shared = GamificationService()
    
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // Keys for persistence
    private let heartsKey = "current_hearts"
    private let lastHeartRefillKey = "last_heart_refill"
    private let dailyQuestsKey = "daily_quests"
    private let weeklyQuestsKey = "weekly_quests"
    private let streakInfoKey = "streak_info"
    private let streakFreezeKey = "streak_freeze_available"
    private let userLevelKey = "user_level"
    private let badgeProgressKey = "badge_progress"
    private let leaderboardKey = "leaderboard_scores"
    
    // Published properties for UI
    @Published var currentHearts: Int = 5
    @Published var currentStreak: Int = 0
    @Published var currentLevel: UserLevel = UserLevel(level: 1, xp: 0)
    @Published var dailyQuests: [DailyQuest] = []
    @Published var weeklyChallenge: WeeklyChallenge?
    
    // Constants
    private let maxHearts = 5
    private let heartRefillMinutes = 30
    
    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        
        Task {
            await loadCurrentState()
        }
    }
    
    // MARK: - Hearts & Lives System
    func getCurrentHearts() async -> Int {
        let hearts = userDefaults.integer(forKey: heartsKey)
        return hearts == 0 ? maxHearts : hearts // Default to full hearts
    }
    
    func consumeHeart() async throws {
        let currentHearts = await getCurrentHearts()
        
        guard currentHearts > 0 else {
            throw GamificationError.noHeartsRemaining
        }
        
        let newHearts = currentHearts - 1
        userDefaults.set(newHearts, forKey: heartsKey)
        
        // Start refill timer if we just consumed the last heart
        if newHearts == 0 {
            let refillTime = Date().addingTimeInterval(TimeInterval(heartRefillMinutes * 60))
            userDefaults.set(refillTime, forKey: lastHeartRefillKey)
        }
        
        await MainActor.run {
            self.currentHearts = newHearts
        }
        
        print("💔 Heart consumed. Remaining: \(newHearts)")
    }
    
    func refillHearts() async throws {
        userDefaults.set(maxHearts, forKey: heartsKey)
        userDefaults.removeObject(forKey: lastHeartRefillKey)
        
        await MainActor.run {
            self.currentHearts = maxHearts
        }
        
        print("💖 Hearts refilled to maximum")
    }
    
    func getHeartRefillTime() async -> Date? {
        return userDefaults.object(forKey: lastHeartRefillKey) as? Date
    }
    
    // MARK: - Daily Quests & Challenges
    func getDailyQuests() async throws -> [DailyQuest] {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let data = userDefaults.data(forKey: dailyQuestsKey),
           let questsData = try? decoder.decode(DailyQuestsData.self, from: data),
           Calendar.current.isDate(questsData.date, inSameDayAs: today) {
            return questsData.quests
        }
        
        // Generate new quests for today
        try await generateNewDailyQuests()
        return try await getDailyQuests()
    }
    
    func completeDailyQuest(questId: String) async throws {
        var quests = try await getDailyQuests()
        
        guard let questIndex = quests.firstIndex(where: { $0.id == questId }) else {
            throw GamificationError.questNotFound
        }
        
        quests[questIndex].isCompleted = true
        quests[questIndex].completionDate = Date()
        
        // Save updated quests
        let questsData = DailyQuestsData(date: Date(), quests: quests)
        let data = try encoder.encode(questsData)
        userDefaults.set(data, forKey: dailyQuestsKey)
        
        // Award XP
        try await awardXP(quests[questIndex].xpReward, source: .dailyQuest)
        
        await MainActor.run {
            self.dailyQuests = quests
        }
        
        print("✅ Daily quest completed: \(questId)")
    }
    
    func getWeeklyChallenge() async throws -> WeeklyChallenge? {
        let weekStart = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        
        if let data = userDefaults.data(forKey: weeklyQuestsKey),
           let challengeData = try? decoder.decode(WeeklyChallengeData.self, from: data),
           Calendar.current.isDate(challengeData.weekStart, inSameDayAs: weekStart) {
            return challengeData.challenge
        }
        
        // Generate new weekly challenge
        let newChallenge = generateWeeklyChallenge()
        let challengeData = WeeklyChallengeData(weekStart: weekStart, challenge: newChallenge)
        let data = try encoder.encode(challengeData)
        userDefaults.set(data, forKey: weeklyQuestsKey)
        
        return newChallenge
    }
    
    func generateNewDailyQuests() async throws {
        let newQuests = [
            DailyQuest(
                id: "daily_practice",
                title: "Daily Practice",
                description: "Complete any lesson",
                type: .lessonCompletion,
                target: 1,
                current: 0,
                xpReward: 25,
                icon: "book.fill"
            ),
            DailyQuest(
                id: "drawing_time",
                title: "Artist's Hour",
                description: "Practice for 15 minutes",
                type: .timeSpent,
                target: 15,
                current: 0,
                xpReward: 50,
                icon: "clock.fill"
            ),
            DailyQuest(
                id: "perfect_lesson",
                title: "Perfectionist",
                description: "Complete a lesson with 100% score",
                type: .perfectScore,
                target: 1,
                current: 0,
                xpReward: 75,
                icon: "star.fill"
            )
        ]
        
        let questsData = DailyQuestsData(date: Date(), quests: newQuests)
        let data = try encoder.encode(questsData)
        userDefaults.set(data, forKey: dailyQuestsKey)
        
        await MainActor.run {
            self.dailyQuests = newQuests
        }
    }
    
    // MARK: - Streak Management
    func updateStreak() async throws {
        var streakInfo = getStreakInfoSync()
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastActivity = streakInfo.lastActivityDate {
            let lastActivityDay = Calendar.current.startOfDay(for: lastActivity)
            let daysBetween = Calendar.current.dateComponents([.day], from: lastActivityDay, to: today).day ?? 0
            
            switch daysBetween {
            case 0:
                // Same day, no change to streak
                return
            case 1:
                // Consecutive day, increment streak
                streakInfo.currentStreak += 1
                streakInfo.longestStreak = max(streakInfo.longestStreak, streakInfo.currentStreak)
            default:
                // Missed days, reset streak (unless freeze is used)
                if streakInfo.freezeUsed {
                    streakInfo.freezeUsed = false
                } else {
                    streakInfo.currentStreak = 1
                }
            }
        } else {
            // First activity
            streakInfo.currentStreak = 1
        }
        
        streakInfo.lastActivityDate = Date()
        
        // Save updated streak
        let data = try encoder.encode(streakInfo)
        userDefaults.set(data, forKey: streakInfoKey)
        
        await MainActor.run {
            self.currentStreak = streakInfo.currentStreak
        }
        
        // Check for streak badges
        try await checkStreakBadges(streak: streakInfo.currentStreak)
        
        print("🔥 Streak updated: \(streakInfo.currentStreak)")
    }
    
    func getStreakInfo() async -> StreakInfo {
        return getStreakInfoSync()
    }
    
    func getStreakFreeze() async -> Bool {
        return userDefaults.bool(forKey: streakFreezeKey)
    }
    
    func useStreakFreeze() async throws {
        guard await getStreakFreeze() else {
            throw GamificationError.noStreakFreezeAvailable
        }
        
        var streakInfo = getStreakInfoSync()
        streakInfo.freezeUsed = true
        
        let data = try encoder.encode(streakInfo)
        userDefaults.set(data, forKey: streakInfoKey)
        
        userDefaults.set(false, forKey: streakFreezeKey)
        
        print("🧊 Streak freeze used")
    }
    
    // MARK: - XP & Leveling
    func awardXP(_ amount: Int, source: XPSource) async throws {
        var level = getCurrentLevelSync()
        level.xp += amount
        
        // Check for level up
        let newLevelNumber = calculateLevel(from: level.xp)
        if newLevelNumber > level.level {
            level.level = newLevelNumber
            try await handleLevelUp(newLevel: newLevelNumber)
        }
        
        // Save updated level
        let data = try encoder.encode(level)
        userDefaults.set(data, forKey: userLevelKey)
        
        await MainActor.run {
            self.currentLevel = level
        }
        
        // Also update user profile
        try await UserProgressService.shared.awardXP(amount)
        
        print("⭐ XP awarded: \(amount) from \(source). Total: \(level.xp)")
    }
    
    func getCurrentLevel() async -> UserLevel {
        return getCurrentLevelSync()
    }
    
    func getLevelProgress() async -> LevelProgress {
        let level = getCurrentLevelSync()
        let currentLevelXP = xpForLevel(level.level)
        let nextLevelXP = xpForLevel(level.level + 1)
        let progressInLevel = level.xp - currentLevelXP
        let xpNeeded = nextLevelXP - currentLevelXP
        
        return LevelProgress(
            currentLevel: level.level,
            totalXP: level.xp,
            progressInLevel: progressInLevel,
            xpForNextLevel: xpNeeded,
            progressPercentage: Double(progressInLevel) / Double(xpNeeded)
        )
    }
    
    // MARK: - Badges & Achievements
    func checkBadgeProgress() async throws {
        let allBadges = getAllAvailableBadges()
        let userBadges = Set(getUserBadgeIds())
        
        for badge in allBadges {
            if userBadges.contains(badge.id) { continue }
            
            if await checkBadgeRequirement(badge) {
                try await awardBadge(badge.id)
            }
        }
    }
    
    func awardBadge(_ badgeId: String) async throws {
        var userBadgeIds = getUserBadgeIds()
        
        guard !userBadgeIds.contains(badgeId) else {
            return // Already have this badge
        }
        
        userBadgeIds.append(badgeId)
        
        let data = try encoder.encode(userBadgeIds)
        userDefaults.set(data, forKey: "user_badges")
        
        // Award badge XP
        if let badge = getAllAvailableBadges().first(where: { $0.id == badgeId }) {
            try await awardXP(badge.xpReward, source: .badge)
        }
        
        print("🏆 Badge awarded: \(badgeId)")
        
        // Show celebration (would trigger UI animation)
        await showBadgeCelebration(badgeId: badgeId)
    }
    
    func getAllBadges() async -> [GameBadge] {
        return getAllAvailableBadges()
    }
    
    func getUserBadges() async -> [GameBadge] {
        let userBadgeIds = getUserBadgeIds()
        return getAllAvailableBadges().filter { userBadgeIds.contains($0.id) }
    }
    
    // MARK: - Leaderboards & Social
    func getLeaderboard(type: LeaderboardType, timeframe: TimeFrame) async throws -> Leaderboard {
        // This would typically fetch from a server, but for now we'll use local mock data
        return Leaderboard(
            type: type,
            timeframe: timeframe,
            entries: generateMockLeaderboardEntries(),
            userRank: 5,
            userScore: getCurrentLevelSync().xp
        )
    }
    
    func updateLeaderboardScore(score: Int, type: LeaderboardType) async throws {
        // In a real app, this would update server-side leaderboards
        print("📊 Leaderboard score updated: \(score) for \(type)")
    }
    
    // MARK: - Helper Methods
    private func loadCurrentState() async {
        currentHearts = await getCurrentHearts()
        currentLevel = getCurrentLevelSync()
        currentStreak = getStreakInfoSync().currentStreak
        
        do {
            dailyQuests = try await getDailyQuests()
            weeklyChallenge = try await getWeeklyChallenge()
        } catch {
            print("Error loading gamification state: \(error)")
        }
    }
    
    private func getStreakInfoSync() -> StreakInfo {
        guard let data = userDefaults.data(forKey: streakInfoKey),
              let streakInfo = try? decoder.decode(StreakInfo.self, from: data) else {
            return StreakInfo(currentStreak: 0, longestStreak: 0, lastActivityDate: nil, freezeUsed: false)
        }
        return streakInfo
    }
    
    private func getCurrentLevelSync() -> UserLevel {
        guard let data = userDefaults.data(forKey: userLevelKey),
              let level = try? decoder.decode(UserLevel.self, from: data) else {
            return UserLevel(level: 1, xp: 0)
        }
        return level
    }
    
    private func calculateLevel(from xp: Int) -> Int {
        // XP required increases by 100 per level
        return max(1, (xp / 100) + 1)
    }
    
    private func xpForLevel(_ level: Int) -> Int {
        return (level - 1) * 100
    }
    
    private func handleLevelUp(newLevel: Int) async throws {
        print("🎉 LEVEL UP! New level: \(newLevel)")
        
        // Award streak freeze for certain levels
        if newLevel % 5 == 0 {
            userDefaults.set(true, forKey: streakFreezeKey)
        }
        
        // Check for level-based badges
        try await checkBadgeProgress()
        
        // Show level up celebration (would trigger UI)
        await showLevelUpCelebration(level: newLevel)
    }
    
    private func checkStreakBadges(streak: Int) async throws {
        let streakMilestones = [3, 7, 14, 30, 50, 100]
        
        for milestone in streakMilestones {
            if streak >= milestone {
                try await awardBadge("streak_\(milestone)")
            }
        }
    }
    
    private func checkBadgeRequirement(_ badge: GameBadge) async -> Bool {
        switch badge.requirement {
        case .completeLesson:
            do {
                let user = try await UserProgressService.shared.getCurrentUser()
                return user.completedLessons.count >= 1
            } catch {
                return false
            }
        case .achieveStreak(let days):
            return getStreakInfoSync().currentStreak >= days
        case .earnXP(let amount):
            return getCurrentLevelSync().xp >= amount
        case .completeSection:
            return false // Will implement later
        case .perfectScore:
            return false // Will implement later
        }
    }

    
    private func getUserBadgeIds() -> [String] {
        guard let data = userDefaults.data(forKey: "user_badges"),
              let badgeIds = try? decoder.decode([String].self, from: data) else {
            return []
        }
        return badgeIds
    }
    
    private func getAllAvailableBadges() -> [GameBadge] {
        return [
            GameBadge(id: "first_lesson", name: "First Steps", description: "Complete your first lesson", icon: "star.fill", requirement: .completeLesson, xpReward: 50, tier: .bronze),
            GameBadge(id: "streak_3", name: "Consistent", description: "3 day streak", icon: "flame.fill", requirement: .achieveStreak(3), xpReward: 75, tier: .bronze),
            GameBadge(id: "streak_7", name: "Dedicated", description: "7 day streak", icon: "flame.fill", requirement: .achieveStreak(7), xpReward: 100, tier: .silver),
            GameBadge(id: "streak_30", name: "Unstoppable", description: "30 day streak", icon: "flame.fill", requirement: .achieveStreak(30), xpReward: 250, tier: .gold),
            GameBadge(id: "xp_1000", name: "Knowledge Seeker", description: "Earn 1000 XP", icon: "brain.head.profile", requirement: .earnXP(1000), xpReward: 100, tier: .silver)
        ]
    }
    
    private func generateWeeklyChallenge() -> WeeklyChallenge {
        let challenges = [
            ("weekly_practice", "Weekly Artist", "Complete 5 lessons this week", 5, 200),
            ("weekly_streak", "Streak Master", "Maintain your streak all week", 7, 300),
            ("weekly_perfect", "Perfectionist Week", "Get perfect scores on 3 lessons", 3, 250)
        ]
        
        let randomChallenge = challenges.randomElement()!
        
        return WeeklyChallenge(
            id: randomChallenge.0,
            title: randomChallenge.1,
            description: randomChallenge.2,
            target: randomChallenge.3,
            current: 0,
            xpReward: randomChallenge.4,
            deadline: Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date()
        )
    }
    
    private func generateMockLeaderboardEntries() -> [LeaderboardEntry] {
        return [
            LeaderboardEntry(rank: 1, displayName: "ArtMaster", score: 2500, avatar: "🎨"),
            LeaderboardEntry(rank: 2, displayName: "SketchPro", score: 2200, avatar: "✏️"),
            LeaderboardEntry(rank: 3, displayName: "ColorWizard", score: 1950, avatar: "🌈"),
            LeaderboardEntry(rank: 4, displayName: "LineArtist", score: 1800, avatar: "📏"),
            LeaderboardEntry(rank: 5, displayName: "You", score: getCurrentLevelSync().xp, avatar: "👤")
        ]
    }
    
    private func showBadgeCelebration(badgeId: String) async {
        // Would trigger UI celebration animation
        print("🎊 Badge celebration: \(badgeId)")
    }
    
    private func showLevelUpCelebration(level: Int) async {
        // Would trigger UI level up animation
        print("🎉 Level up celebration: Level \(level)")
    }
}

// MARK: - Supporting Types
struct DailyQuest: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let type: QuestType
    let target: Int
    var current: Int
    let xpReward: Int
    let icon: String
    var isCompleted: Bool = false
    var completionDate: Date?
    
    var progress: Double {
        guard target > 0 else { return 0 }
        return Double(current) / Double(target)
    }
    
    enum QuestType: String, Codable {
        case lessonCompletion = "lesson_completion"
        case timeSpent = "time_spent"
        case perfectScore = "perfect_score"
        case streakMaintenance = "streak_maintenance"
        case unitCompletion = "unit_completion"
    }
}

struct WeeklyChallenge: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let target: Int
    var current: Int
    let xpReward: Int
    let deadline: Date
    var isCompleted: Bool = false
    
    var progress: Double {
        guard target > 0 else { return 0 }
        return min(1.0, Double(current) / Double(target))
    }
    
    var daysRemaining: Int {
        let remaining = Calendar.current.dateComponents([.day], from: Date(), to: deadline).day ?? 0
        return max(0, remaining)
    }
}

struct StreakInfo: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var lastActivityDate: Date?
    var freezeUsed: Bool
}

struct UserLevel: Codable {
    var level: Int
    var xp: Int
}

struct LevelProgress {
    let currentLevel: Int
    let totalXP: Int
    let progressInLevel: Int
    let xpForNextLevel: Int
    let progressPercentage: Double
}

struct GameBadge: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let requirement: BadgeRequirement
    let xpReward: Int
    let tier: BadgeTier
    
    enum BadgeRequirement: Codable {
        case completeLesson
        case achieveStreak(Int)
        case earnXP(Int)
        case completeSection
        case perfectScore
    }
    
    enum BadgeTier: String, Codable {
        case bronze = "Bronze"
        case silver = "Silver"
        case gold = "Gold"
        case platinum = "Platinum"
        
        var color: Color {
            switch self {
            case .bronze: return .orange
            case .silver: return .gray
            case .gold: return .yellow
            case .platinum: return .purple
            }
        }
    }
}

struct Leaderboard {
    let type: LeaderboardType
    let timeframe: TimeFrame
    let entries: [LeaderboardEntry]
    let userRank: Int
    let userScore: Int
}

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let rank: Int
    let displayName: String
    let score: Int
    let avatar: String
}

enum LeaderboardType: String, CaseIterable {
    case xp = "XP"
    case streak = "Streak"
    case lessonsCompleted = "Lessons"
    
    var title: String {
        switch self {
        case .xp: return "Experience Points"
        case .streak: return "Current Streak"
        case .lessonsCompleted: return "Lessons Completed"
        }
    }
}

enum TimeFrame: String, CaseIterable {
    case daily = "Today"
    case weekly = "This Week"
    case monthly = "This Month"
    case allTime = "All Time"
}

enum XPSource: String {
    case lesson = "Lesson Completion"
    case dailyQuest = "Daily Quest"
    case weeklyChallenge = "Weekly Challenge"
    case badge = "Badge Achievement"
    case perfectScore = "Perfect Score"
    case streak = "Streak Bonus"
}

// MARK: - Data Containers
struct DailyQuestsData: Codable {
    let date: Date
    let quests: [DailyQuest]
}

struct WeeklyChallengeData: Codable {
    let weekStart: Date
    let challenge: WeeklyChallenge
}

// MARK: - Errors
enum GamificationError: LocalizedError {
    case noHeartsRemaining
    case questNotFound
    case noStreakFreezeAvailable
    
    var errorDescription: String? {
        switch self {
        case .noHeartsRemaining:
            return "No hearts remaining. Please wait for refill or purchase hearts."
        case .questNotFound:
            return "Quest not found."
        case .noStreakFreezeAvailable:
            return "No streak freeze available."
        }
    }
}
