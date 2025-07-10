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
    
    func getCurrentUser() async throws -> UserProfile {
        if let data = userDefaults.data(forKey: currentUserKey),
           let profile = try? decoder.decode(UserProfile.self, from: data) {
            return profile
        }
        
        let newProfile = UserProfile(
            id: UUID().uuidString,
            displayName: "Artist",
            level: 1,
            totalXP: 0
        )
        
        try await saveUserProfile(newProfile)
        return newProfile
    }
    
    func saveUserProfile(_ profile: UserProfile) async throws {
        let data = try encoder.encode(profile)
        userDefaults.set(data, forKey: currentUserKey)
    }
    
    func updateLessonProgress(lessonId: String, stepId: String, score: Double, timeSpent: TimeInterval) async throws {
        var profile = try await getCurrentUser()
        
        var lessonProgress = profile.lessonProgress[lessonId] ?? LessonProgress(lessonId: lessonId)
        
        var stepProgress = lessonProgress.stepProgress[stepId] ?? StepProgress(stepId: stepId)
        stepProgress.attempts += 1
        stepProgress.bestScore = max(stepProgress.bestScore, score)
        stepProgress.timeSpent += timeSpent
        stepProgress.lastAttemptDate = Date()
        
        if score >= 0.7 {
            stepProgress.isCompleted = true
        }
        
        lessonProgress.stepProgress[stepId] = stepProgress
        lessonProgress.totalTimeSpent += timeSpent
        lessonProgress.lastAttemptDate = Date()
        
        if let lesson = try? await LessonService.shared.getLesson(id: lessonId) {
            let completedSteps = lessonProgress.stepProgress.values.filter { $0.isCompleted }.count
            if completedSteps == lesson.steps.count {
                lessonProgress.isCompleted = true
                profile.completedLessons.insert(lessonId)
                
                for unlockedId in lesson.unlocks {
                    profile.unlockedLessons.insert(unlockedId)
                }
            }
        }
        
        profile.lessonProgress[lessonId] = lessonProgress
        
        try await updateDailyActivity(minutesPracticed: Int(timeSpent / 60))
        try await saveUserProfile(profile)
    }
    
    func completeLesson(_ lessonId: String) async throws {
        var profile = try await getCurrentUser()
        
        guard let lesson = try? await LessonService.shared.getLesson(id: lessonId) else { return }
        
        profile.completedLessons.insert(lessonId)
        
        try await awardXP(lesson.xpReward)
        
        for unlockedId in lesson.unlocks {
            profile.unlockedLessons.insert(unlockedId)
        }
        
        if var lessonProgress = profile.lessonProgress[lessonId] {
            lessonProgress.isCompleted = true
            lessonProgress.totalAttempts += 1
            profile.lessonProgress[lessonId] = lessonProgress
        }
        
        try await updateDailyActivity(lessonsCompleted: 1)
        try await saveUserProfile(profile)
        try await checkAndAwardBadges()
    }
    
    func updateStreak() async throws {
        var profile = try await getCurrentUser()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastActive = calendar.startOfDay(for: profile.lastActiveDate)
        
        let daysSinceLastActive = calendar.dateComponents([.day], from: lastActive, to: today).day ?? 0
        
        if daysSinceLastActive == 0 {
            return
        } else if daysSinceLastActive == 1 {
            profile.currentStreak += 1
            profile.longestStreak = max(profile.longestStreak, profile.currentStreak)
        } else {
            profile.currentStreak = 1
        }
        
        profile.lastActiveDate = Date()
        try await saveUserProfile(profile)
    }
    
    func awardXP(_ amount: Int) async throws {
        var profile = try await getCurrentUser()
        
        profile.totalXP += amount
        
        let newLevel = (profile.totalXP / 100) + 1
        if newLevel > profile.level {
            profile.level = newLevel
        }
        
        try await updateDailyActivity(xpEarned: amount)
        try await saveUserProfile(profile)
    }
    
    func checkAndAwardBadges() async throws {
        var profile = try await getCurrentUser()
        let allBadges = Curriculum.allBadges
        
        for badge in allBadges {
            if profile.earnedBadges.contains(badge.id) {
                continue
            }
            
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
                isEarned = profile.skillProgress[skillId]?.level ?? 0 >= 10
            }
            
            if isEarned {
                profile.earnedBadges.insert(badge.id)
                try await awardXP(badge.xpReward)
            }
        }
        
        try await saveUserProfile(profile)
    }
    
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
        
        if activity.minutesPracticed == minutesPracticed && minutesPracticed > 0 {
            try await updateStreak()
        }
    }
    
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
                    completed: activity.minutesPracticed >= 15
                )
            },
            totalMinutes: totalMinutes,
            totalXP: totalXP,
            averageMinutesPerDay: activities.isEmpty ? 0 : Double(totalMinutes) / Double(activities.count)
        )
    }
}
