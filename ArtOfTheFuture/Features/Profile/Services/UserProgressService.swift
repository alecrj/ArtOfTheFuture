// MARK: - User Progress Service (Fixed)
// File: ArtOfTheFuture/Features/Profile/Services/UserProgressService.swift

import Foundation

protocol UserProgressServiceProtocol {
    func getCurrentUser() async throws -> UserProfile
    func saveUserProfile(_ profile: UserProfile) async throws
    func updateLessonProgress(lessonId: String, stepId: String, score: Double, timeSpent: TimeInterval) async throws
    func completeLesson(_ lessonId: String) async throws
    func updateStreak() async throws
    func awardXP(_ amount: Int) async throws
    func checkAndAwardBadges() async throws
}

final class UserProgressService: UserProgressServiceProtocol {
    static let shared = UserProgressService()
    
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private let currentUserKey = "currentUserProfile"
    private let dailyActivityKey = "dailyActivity"
    
    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Get Current User
    func getCurrentUser() async throws -> UserProfile {
        if let data = userDefaults.data(forKey: currentUserKey),
           let profile = try? decoder.decode(UserProfile.self, from: data) {
            return profile
        }
        
        // Create default profile
        let newProfile = UserProfile(
            id: UUID().uuidString,
            displayName: "Artist",
            level: 1,
            totalXP: 0
        )
        
        try await saveUserProfile(newProfile)
        return newProfile
    }
    
    // MARK: - Save User Profile
    func saveUserProfile(_ profile: UserProfile) async throws {
        let data = try encoder.encode(profile)
        userDefaults.set(data, forKey: currentUserKey)
    }
    
    // MARK: - Update Lesson Progress
    func updateLessonProgress(lessonId: String, stepId: String, score: Double, timeSpent: TimeInterval) async throws {
        var profile = try await getCurrentUser()
        
        // Get or create lesson progress
        var lessonProgress = profile.lessonProgress[lessonId] ?? LessonProgress(lessonId: lessonId)
        
        // Update step progress
        var stepProgress = lessonProgress.stepProgress[stepId] ?? StepProgress(stepId: stepId)
        stepProgress.attempts += 1
        stepProgress.bestScore = max(stepProgress.bestScore, score)
        stepProgress.timeSpent += timeSpent
        stepProgress.lastAttemptDate = Date()
        
        if score >= 0.7 { // 70% is passing
            stepProgress.isCompleted = true
        }
        
        lessonProgress.stepProgress[stepId] = stepProgress
        lessonProgress.totalTimeSpent += timeSpent
        lessonProgress.lastAttemptDate = Date()
        
        // Update lesson completion
        let lessonService = LessonService.shared
        if let lesson = try? await lessonService.getLesson(id: lessonId) {
            let completedSteps = lessonProgress.stepProgress.values.filter { $0.isCompleted }.count
            if completedSteps == lesson.steps.count {
                lessonProgress.isCompleted = true
                profile.completedLessons.insert(lessonId)
                
                // Unlock next lessons
                for unlockedId in lesson.unlocks {
                    profile.unlockedLessons.insert(unlockedId)
                }
            }
        }
        
        profile.lessonProgress[lessonId] = lessonProgress
        
        // Update daily activity
        try await updateDailyActivity(minutesPracticed: Int(timeSpent / 60))
        
        // Save
        try await saveUserProfile(profile)
    }
    
    // MARK: - Complete Lesson
    func completeLesson(_ lessonId: String) async throws {
        var profile = try await getCurrentUser()
        
        let lessonService = LessonService.shared
        guard let lesson = try? await lessonService.getLesson(id: lessonId) else { return }
        
        // Mark as completed
        profile.completedLessons.insert(lessonId)
        
        // Award XP
        try await awardXP(lesson.xpReward)
        
        // Unlock next lessons
        for unlockedId in lesson.unlocks {
            profile.unlockedLessons.insert(unlockedId)
        }
        
        // Update lesson progress
        if var lessonProgress = profile.lessonProgress[lessonId] {
            lessonProgress.isCompleted = true
            lessonProgress.totalAttempts += 1
            profile.lessonProgress[lessonId] = lessonProgress
        }
        
        // Update daily activity
        try await updateDailyActivity(lessonsCompleted: 1)
        
        // Save
        try await saveUserProfile(profile)
        
        // Check for new badges
        try await checkAndAwardBadges()
    }
    
    // MARK: - Update Streak
    func updateStreak() async throws {
        var profile = try await getCurrentUser()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastActive = calendar.startOfDay(for: profile.lastActiveDate ?? Date())
        
        let daysSinceLastActive = calendar.dateComponents([.day], from: lastActive, to: today).day ?? 0
        
        if daysSinceLastActive == 0 {
            // Already active today
            return
        } else if daysSinceLastActive == 1 {
            // Consecutive day
            profile.currentStreak += 1
            profile.longestStreak = max(profile.longestStreak ?? 0, profile.currentStreak)
        } else {
            // Streak broken
            profile.currentStreak = 1
        }
        
        profile.lastActiveDate = Date()
        try await saveUserProfile(profile)
    }
    
    // MARK: - Award XP
    func awardXP(_ amount: Int) async throws {
        var profile = try await getCurrentUser()
        
        profile.totalXP += amount
        
        // Check for level up
        let newLevel = (profile.totalXP / 100) + 1
        if newLevel > profile.level {
            profile.level = newLevel
            // Could trigger level up celebration here
        }
        
        // Update daily XP
        try await updateDailyActivity(xpEarned: amount)
        
        try await saveUserProfile(profile)
    }
    
    // MARK: - Check and Award Badges
    func checkAndAwardBadges() async throws {
        var profile = try await getCurrentUser()
        let allBadges = SimplifiedCurriculum.basicBadges // Use simplified curriculum
        
        for badge in allBadges {
            // Skip if already earned
            if profile.earnedBadges?.contains(badge.id) == true {
                continue
            }
            
            // Check requirement
            let isEarned: Bool
            switch badge.requirement {
            case .completeLesson(let lessonId):
                isEarned = profile.completedLessons.contains(lessonId)
                
            case .completeLessonsCount(let count):
                isEarned = profile.completedLessons.count >= count
                
            case .achieveStreak(let days):
                isEarned = profile.currentStreak >= days
                
            case .earnXP(let amount):
                isEarned = profile.totalXP >= amount
                
            case .masterSkill(let skillId):
                isEarned = profile.skillProgress?[skillId]?.level ?? 0 >= 10
            }
            
            if isEarned {
                if profile.earnedBadges == nil {
                    profile.earnedBadges = Set<String>()
                }
                profile.earnedBadges?.insert(badge.id)
                
                // Award badge XP
                try await awardXP(badge.xpReward)
            }
        }
        
        try await saveUserProfile(profile)
    }
    
    // MARK: - Private: Update Daily Activity
    private func updateDailyActivity(
        minutesPracticed: Int = 0,
        xpEarned: Int = 0,
        lessonsCompleted: Int = 0,
        stepsCompleted: Int = 0
    ) async throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let key = "\(dailyActivityKey)_\(today.timeIntervalSince1970)"
        
        var activity: DailyActivity
        if let data = userDefaults.data(forKey: key),
           let existing = try? decoder.decode(DailyActivity.self, from: data) {
            activity = existing
        } else {
            activity = DailyActivity(date: today)
        }
        
        activity.minutesPracticed += minutesPracticed
        activity.xpEarned += xpEarned
        activity.lessonsCompleted += lessonsCompleted
        activity.stepsCompleted += stepsCompleted
        
        let data = try encoder.encode(activity)
        userDefaults.set(data, forKey: key)
        
        // Update streak if this is first activity today
        if activity.minutesPracticed == minutesPracticed && minutesPracticed > 0 {
            try await updateStreak()
        }
    }
    
    // MARK: - Get Weekly Stats
    func getWeeklyStats() async throws -> WeeklyStats {
        let calendar = Calendar.current
        let today = Date()
        var activities: [DailyActivity] = []
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let startOfDay = calendar.startOfDay(for: date)
            let key = "\(dailyActivityKey)_\(startOfDay.timeIntervalSince1970)"
            
            if let data = userDefaults.data(forKey: key),
               let activity = try? decoder.decode(DailyActivity.self, from: data) {
                activities.append(activity)
            }
        }
        
        let totalMinutes = activities.reduce(0) { $0 + $1.minutesPracticed }
        let totalXP = activities.reduce(0) { $0 + $1.xpEarned }
        
        return WeeklyStats(
            days: activities.map { activity in
                WeeklyStats.DayStats(
                    date: activity.date,
                    minutes: activity.minutesPracticed,
                    xp: activity.xpEarned,
                    completed: activity.minutesPracticed >= 15 // 15 min goal
                )
            },
            totalMinutes: totalMinutes,
            totalXP: totalXP,
            averageMinutesPerDay: activities.isEmpty ? 0 : Double(totalMinutes) / Double(activities.count)
        )
    }
}

// MARK: - Supporting Models
struct DailyActivity: Codable {
    let date: Date
    var minutesPracticed: Int = 0
    var xpEarned: Int = 0
    var lessonsCompleted: Int = 0
    var stepsCompleted: Int = 0
}

// MARK: - Extended UserProfile
extension UserProfile {
    var lessonProgress: [String: LessonProgress] {
        get { _lessonProgress ?? [:] }
        set { _lessonProgress = newValue }
    }
    
    var skillProgress: [String: SkillProgress]? {
        get { _skillProgress }
        set { _skillProgress = newValue }
    }
    
    var earnedBadges: Set<String>? {
        get { _earnedBadges }
        set { _earnedBadges = newValue }
    }
    
    var lastActiveDate: Date? {
        get { _lastActiveDate }
        set { _lastActiveDate = newValue }
    }
    
    var longestStreak: Int? {
        get { _longestStreak }
        set { _longestStreak = newValue }
    }
    
    // Private stored properties
    private var _lessonProgress: [String: LessonProgress]?
    private var _skillProgress: [String: SkillProgress]?
    private var _earnedBadges: Set<String>?
    private var _lastActiveDate: Date?
    private var _longestStreak: Int?
}

// MARK: - Skill Progress
struct SkillProgress: Codable {
    let skillId: String
    var level: Int = 0
    var xp: Int = 0
    var lastPracticed: Date?
}
