// MARK: - Enhanced Progress Service with Simple Persistence
// File: ArtOfTheFuture/Features/Lessons/Services/ProgressServiceProtocol.swift

import Foundation

protocol ProgressServiceProtocol {
    func updateLessonProgress(lessonId: String, stepId: String, score: Double, timeSpent: TimeInterval) async throws
    func completeLesson(_ lessonId: String) async throws
    func getLessonProgress(lessonId: String) async throws -> LessonProgress?
    func getOverallProgress() async throws -> OverallProgress
    func saveProgress(_ progress: LessonProgress) async throws
    func resetProgress(lessonId: String) async throws
    func getCompletedLessons() async throws -> Set<String>
    func isLessonCompleted(lessonId: String) async throws -> Bool
}

// MARK: - Enhanced Progress Service Implementation
final class ProgressService: ProgressServiceProtocol {
    static let shared = ProgressService()
    
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // Keys for UserDefaults
    private let completedLessonsKey = "completedLessons"
    private let lessonProgressKeyPrefix = "lesson_progress_"
    private let totalXPKey = "totalXP"
    private let userStreakKey = "userStreak"
    
    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    func updateLessonProgress(lessonId: String, stepId: String, score: Double, timeSpent: TimeInterval) async throws {
        var progress = try await getLessonProgress(lessonId: lessonId) ?? LessonProgress(lessonId: lessonId)
        
        var stepProgress = progress.stepProgress[stepId] ?? StepProgress(stepId: stepId)
        stepProgress.attempts += 1
        stepProgress.bestScore = max(stepProgress.bestScore, score)
        stepProgress.timeSpent += timeSpent
        stepProgress.lastAttemptDate = Date()
        
        if score >= 0.7 {
            stepProgress.isCompleted = true
        }
        
        progress.stepProgress[stepId] = stepProgress
        progress.totalTimeSpent += timeSpent
        progress.lastAttemptDate = Date()
        
        try await saveProgress(progress)
        
        print("📊 Updated progress for lesson \(lessonId), step \(stepId)")
    }
    
    func completeLesson(_ lessonId: String) async throws {
        // Update lesson progress
        var progress = try await getLessonProgress(lessonId: lessonId) ?? LessonProgress(lessonId: lessonId)
        progress.isCompleted = true
        progress.totalAttempts += 1
        try await saveProgress(progress)
        
        // Add to completed lessons list
        var completedLessons = try await getCompletedLessons()
        completedLessons.insert(lessonId)
        
        // Save to UserDefaults
        let completedArray = Array(completedLessons)
        userDefaults.set(completedArray, forKey: completedLessonsKey)
        
        // Add XP to total
        if let lesson = Curriculum.allLessons.first(where: { $0.id == lessonId }) {
            let currentXP = userDefaults.integer(forKey: totalXPKey)
            let newXP = currentXP + lesson.xpReward
            userDefaults.set(newXP, forKey: totalXPKey)
            
            print("✅ Lesson \(lessonId) completed! Added \(lesson.xpReward) XP. Total: \(newXP)")
        }
        
        print("🎉 Lesson \(lessonId) marked as complete!")
    }
    
    func getLessonProgress(lessonId: String) async throws -> LessonProgress? {
        let key = lessonProgressKeyPrefix + lessonId
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try decoder.decode(LessonProgress.self, from: data)
    }
    
    func getOverallProgress() async throws -> OverallProgress {
        let completedLessons = try await getCompletedLessons()
        let totalXP = userDefaults.integer(forKey: totalXPKey)
        let streak = userDefaults.integer(forKey: userStreakKey)
        
        // Calculate total time spent across all lessons
        var totalTimeSpent: TimeInterval = 0
        var totalLessonsStarted = 0
        var totalScore = 0.0
        var scoreCount = 0
        
        for lesson in Curriculum.allLessons {
            if let progress = try? await getLessonProgress(lessonId: lesson.id) {
                totalLessonsStarted += 1
                totalTimeSpent += progress.totalTimeSpent
                if progress.bestScore > 0 {
                    totalScore += progress.bestScore
                    scoreCount += 1
                }
            }
        }
        
        let averageScore = scoreCount > 0 ? totalScore / Double(scoreCount) : 0.0
        
        return OverallProgress(
            totalLessonsStarted: totalLessonsStarted,
            totalLessonsCompleted: completedLessons.count,
            totalXPEarned: totalXP,
            totalTimeSpent: totalTimeSpent,
            averageScore: averageScore,
            currentStreak: streak
        )
    }
    
    func saveProgress(_ progress: LessonProgress) async throws {
        let key = lessonProgressKeyPrefix + progress.lessonId
        let data = try encoder.encode(progress)
        userDefaults.set(data, forKey: key)
    }
    
    func resetProgress(lessonId: String) async throws {
        let key = lessonProgressKeyPrefix + lessonId
        userDefaults.removeObject(forKey: key)
        
        // Remove from completed lessons
        var completedLessons = try await getCompletedLessons()
        completedLessons.remove(lessonId)
        let completedArray = Array(completedLessons)
        userDefaults.set(completedArray, forKey: completedLessonsKey)
        
        print("🗑️ Reset progress for lesson \(lessonId)")
    }
    
    func getCompletedLessons() async throws -> Set<String> {
        if let completedArray = userDefaults.array(forKey: completedLessonsKey) as? [String] {
            return Set(completedArray)
        }
        return Set<String>()
    }
    
    func isLessonCompleted(lessonId: String) async throws -> Bool {
        let completedLessons = try await getCompletedLessons()
        return completedLessons.contains(lessonId)
    }
    
    // MARK: - Additional Helper Methods
    func getTotalXP() -> Int {
        return userDefaults.integer(forKey: totalXPKey)
    }
    
    func getCurrentStreak() -> Int {
        return userDefaults.integer(forKey: userStreakKey)
    }
    
    func updateStreak() {
        let currentStreak = userDefaults.integer(forKey: userStreakKey)
        userDefaults.set(currentStreak + 1, forKey: userStreakKey)
    }
    
    func resetStreak() {
        userDefaults.set(0, forKey: userStreakKey)
    }
    
    // MARK: - Debug Methods
    func printAllProgress() async {
        print("🎯 === PROGRESS DEBUG ===")
        do {
            let completedLessons = try await getCompletedLessons()
            print("📚 Completed Lessons: \(completedLessons)")
            print("⭐ Total XP: \(getTotalXP())")
            print("🔥 Current Streak: \(getCurrentStreak())")
            
            for lessonId in completedLessons {
                if let progress = try await getLessonProgress(lessonId: lessonId) {
                    print("📊 \(lessonId): \(progress.stepProgress.count) steps, \(progress.totalTimeSpent)s")
                }
            }
        } catch {
            print("❌ Error printing progress: \(error)")
        }
        print("🎯 === END DEBUG ===")
    }
    
    func clearAllProgress() {
        userDefaults.removeObject(forKey: completedLessonsKey)
        userDefaults.removeObject(forKey: totalXPKey)
        userDefaults.removeObject(forKey: userStreakKey)
        
        // Clear individual lesson progress
        for lesson in Curriculum.allLessons {
            let key = lessonProgressKeyPrefix + lesson.id
            userDefaults.removeObject(forKey: key)
        }
        
        print("🗑️ All progress cleared!")
    }
}

// MARK: - Overall Progress (Enhanced)
struct OverallProgress: Codable {
    let totalLessonsStarted: Int
    let totalLessonsCompleted: Int
    let totalXPEarned: Int
    let totalTimeSpent: TimeInterval
    let averageScore: Double
    let currentStreak: Int
    
    var completionPercentage: Double {
        let totalLessons = Curriculum.allLessons.count
        guard totalLessons > 0 else { return 0 }
        return Double(totalLessonsCompleted) / Double(totalLessons)
    }
    
    var formattedTimeSpent: String {
        let hours = Int(totalTimeSpent) / 3600
        let minutes = (Int(totalTimeSpent) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
