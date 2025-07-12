// MARK: - Fixed User Progress Service (REPLACE existing UserProgressService.swift)
// File: ArtOfTheFuture/Features/Profile/Services/UserProgressService.swift

import Foundation
import Combine


protocol UserProgressServiceProtocol {
    func getCurrentUser() async throws -> UserProfile
    func saveUserProfile(_ profile: UserProfile) async throws
    func updateLessonProgress(lessonId: String, stepId: String, score: Double, timeSpent: TimeInterval) async throws
    func completeLesson(_ lessonId: String) async throws
    func updateStreak() async throws
    func awardXP(_ amount: Int) async throws
    func checkAndAwardBadges() async throws
}

// MARK: - User Progress Service Implementation (NOW OBSERVABLEOBJECT)
final class UserProgressService: UserProgressServiceProtocol, ObservableObject {
    static let shared = UserProgressService()
    
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private let currentUserKey = "currentUserProfile"
    private let dailyActivityKey = "dailyActivity"
    
    // Published properties for UI updates
    @Published var currentUser: UserProfile?
    @Published var isLoading = false
    
    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        
        // Load current user on initialization
        Task {
            try? await loadCurrentUser()
        }
    }
    
    private func loadCurrentUser() async throws {
        let user = try await getCurrentUser()
        await MainActor.run {
            self.currentUser = user
        }
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
        
        await MainActor.run {
            self.currentUser = profile
        }
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
        
        // Check if lesson is now complete
        if let lesson = try await LessonService.shared.getLesson(id: lessonId) {
            let allStepsCompleted = lesson.steps.allSatisfy { step in
                lessonProgress.stepProgress[step.id]?.isCompleted ?? false
            }
            
            if allStepsCompleted && !lessonProgress.isCompleted {
                lessonProgress.isCompleted = true
                lessonProgress.completionDate = Date()
                profile.completedLessons.insert(lessonId)
                
                // Award lesson XP
                try await awardXP(lesson.xpReward)
            }
        }
        
        profile.lessonProgress[lessonId] = lessonProgress
        try await saveUserProfile(profile)
        
        print("📊 Updated lesson progress for \(lessonId), step \(stepId)")
    }
    
    func completeLesson(_ lessonId: String) async throws {
        var profile = try await getCurrentUser()
        
        if !profile.completedLessons.contains(lessonId) {
            profile.completedLessons.insert(lessonId)
            
            // Award XP for lesson completion
            if let lesson = try await LessonService.shared.getLesson(id: lessonId) {
                try await awardXP(lesson.xpReward)
            }
            
            // Update lesson progress
            var lessonProgress = profile.lessonProgress[lessonId] ?? LessonProgress(lessonId: lessonId)
            lessonProgress.isCompleted = true
            lessonProgress.completionDate = Date()
            profile.lessonProgress[lessonId] = lessonProgress
            
            try await saveUserProfile(profile)
            try await updateStreak()
            try await checkAndAwardBadges()
            
            print("🎉 Lesson completed: \(lessonId)")
        }
    }
    
    func updateStreak() async throws {
        var profile = try await getCurrentUser()
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastActive = profile.lastActiveDate {
            let lastActiveDay = Calendar.current.startOfDay(for: lastActive)
            let daysBetween = Calendar.current.dateComponents([.day], from: lastActiveDay, to: today).day ?? 0
            
            switch daysBetween {
            case 0:
                // Same day, no change to streak
                return
            case 1:
                // Consecutive day, increment streak
                profile.currentStreak += 1
                profile.longestStreak = max(profile.longestStreak, profile.currentStreak)
            default:
                // Missed days, reset streak
                profile.currentStreak = 1
            }
        } else {
            // First activity
            profile.currentStreak = 1
        }
        
        profile.lastActiveDate = Date()
        try await saveUserProfile(profile)
        
        print("🔥 Streak updated: \(profile.currentStreak)")
    }
    
    func awardXP(_ amount: Int) async throws {
        var profile = try await getCurrentUser()
        
        profile.totalXP += amount
        
        let newLevel = (profile.totalXP / 100) + 1
        if newLevel > profile.level {
            profile.level = newLevel
            print("🎉 LEVEL UP! New level: \(newLevel)")
        }
        
        try await updateDailyActivity(xpEarned: amount)
        try await saveUserProfile(profile)
        
        print("⭐ XP awarded: \(amount). Total: \(profile.totalXP)")
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
                print("🏆 Badge earned: \(badge.name)")
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
    }
}
