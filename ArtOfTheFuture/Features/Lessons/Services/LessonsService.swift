// MARK: - Lesson Service
// File: ArtOfTheFuture/Services/LessonService.swift
// Uses the curriculum as the single source of truth

import Foundation

protocol LessonServiceProtocol {
    func getAllLessons() async throws -> [Lesson]
    func getLesson(id: String) async throws -> Lesson?
    func getLessonsForUser(_ profile: UserProfile) async throws -> [LessonWithProgress]
    func getUnlockedLessons(for profile: UserProfile) -> Set<String>
    func checkPrerequisites(for lessonId: String, profile: UserProfile) -> Bool
}

final class LessonService: LessonServiceProtocol {
    static let shared = LessonService()
    
    private init() {}
    
    // MARK: - Get All Lessons
    func getAllLessons() async throws -> [Lesson] {
        // Return lessons from curriculum
        return Curriculum.allLessons
    }
    
    // MARK: - Get Single Lesson
    func getLesson(id: String) async throws -> Lesson? {
        return Curriculum.allLessons.first { $0.id == id }
    }
    
    // MARK: - Get Lessons with Progress
    func getLessonsForUser(_ profile: UserProfile) async throws -> [LessonWithProgress] {
        let allLessons = try await getAllLessons()
        
        return allLessons.map { lesson in
            let progress = profile.lessonProgress[lesson.id]
            let isUnlocked = profile.unlockedLessons.contains(lesson.id) ||
                           checkPrerequisites(for: lesson.id, profile: profile)
            let isCompleted = profile.completedLessons.contains(lesson.id)
            
            return LessonWithProgress(
                lesson: lesson,
                isUnlocked: isUnlocked,
                isCompleted: isCompleted,
                progress: progress,
                bestScore: progress?.bestScore ?? 0
            )
        }
    }
    
    // MARK: - Get Unlocked Lessons
    func getUnlockedLessons(for profile: UserProfile) -> Set<String> {
        var unlocked = profile.unlockedLessons
        
        // Check all lessons to see if prerequisites are met
        for lesson in Curriculum.allLessons {
            if checkPrerequisites(for: lesson.id, profile: profile) {
                unlocked.insert(lesson.id)
            }
        }
        
        return unlocked
    }
    
    // MARK: - Check Prerequisites
    func checkPrerequisites(for lessonId: String, profile: UserProfile) -> Bool {
        guard let lesson = Curriculum.allLessons.first(where: { $0.id == lessonId }) else {
            return false
        }
        
        // If no prerequisites, it's unlocked
        if lesson.prerequisites.isEmpty {
            return true
        }
        
        // Check if all prerequisites are completed
        return lesson.prerequisites.allSatisfy { prerequisiteId in
            profile.completedLessons.contains(prerequisiteId)
        }
    }
}

// MARK: - Lesson with Progress Wrapper
struct LessonWithProgress {
    let lesson: Lesson
    let isUnlocked: Bool
    let isCompleted: Bool
    let progress: LessonProgress?
    let bestScore: Double
}
