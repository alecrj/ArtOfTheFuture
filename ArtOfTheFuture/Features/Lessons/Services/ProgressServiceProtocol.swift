// MARK: - Progress Service Protocol (FIXED)
// File: ArtOfTheFuture/Features/Lessons/Services/ProgressServiceProtocol.swift

import Foundation

protocol ProgressServiceProtocol {
    func updateLessonProgress(lessonId: String, stepId: String, score: Double, timeSpent: TimeInterval) async throws
    func completeLesson(_ lessonId: String) async throws
    func getLessonProgress(lessonId: String) async throws -> LessonProgress?
    func getOverallProgress() async throws -> OverallProgress
    func saveProgress(_ progress: LessonProgress) async throws
    func resetProgress(lessonId: String) async throws
}

// MARK: - Progress Service Implementation
final class ProgressService: ProgressServiceProtocol {
    static let shared = ProgressService()
    
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
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
    }
    
    func completeLesson(_ lessonId: String) async throws {
        var progress = try await getLessonProgress(lessonId: lessonId) ?? LessonProgress(lessonId: lessonId)
        progress.isCompleted = true
        progress.totalAttempts += 1
        try await saveProgress(progress)
    }
    
    func getLessonProgress(lessonId: String) async throws -> LessonProgress? {
        let key = "lesson_progress_\(lessonId)"
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try decoder.decode(LessonProgress.self, from: data)
    }
    
    func getOverallProgress() async throws -> OverallProgress {
        // Implementation for overall progress calculation
        return OverallProgress(
            totalLessonsStarted: 0,
            totalLessonsCompleted: 0,
            totalXPEarned: 0,
            totalTimeSpent: 0,
            averageScore: 0.0,
            currentStreak: 0
        )
    }
    
    func saveProgress(_ progress: LessonProgress) async throws {
        let key = "lesson_progress_\(progress.lessonId)"
        let data = try encoder.encode(progress)
        userDefaults.set(data, forKey: key)
    }
    
    func resetProgress(lessonId: String) async throws {
        let key = "lesson_progress_\(lessonId)"
        userDefaults.removeObject(forKey: key)
    }
}

// MARK: - Overall Progress (Non-conflicting)
struct OverallProgress: Codable {
    let totalLessonsStarted: Int
    let totalLessonsCompleted: Int
    let totalXPEarned: Int
    let totalTimeSpent: TimeInterval
    let averageScore: Double
    let currentStreak: Int
}
