// MARK: - Lesson Service
// File: ArtOfTheFuture/Features/Lessons/Services/LessonsService.swift

import Foundation

protocol LessonServiceProtocol {
    func getAllLessons() async throws -> [Lesson]
    func getLesson(id: String) async throws -> Lesson?
    func getLessonsForUser() async throws -> [Lesson]
    func getUnlockedLessons(for profile: UserProfile) -> Set<String>
    func checkPrerequisites(for lessonId: String, profile: UserProfile) -> Bool
}

final class LessonService: LessonServiceProtocol {
    static let shared = LessonService()
    
    private init() {}
    
    func getAllLessons() async throws -> [Lesson] {
        return Curriculum.allLessons
    }
    
    func getLesson(id: String) async throws -> Lesson? {
        return Curriculum.allLessons.first { $0.id == id }
    }
    
    func getLessonsForUser() async throws -> [Lesson] {
        return try await getAllLessons()
    }
    
    func getUnlockedLessons(for profile: UserProfile) -> Set<String> {
        var unlocked = profile.unlockedLessons
        
        for lesson in Curriculum.allLessons {
            if checkPrerequisites(for: lesson.id, profile: profile) {
                unlocked.insert(lesson.id)
            }
        }
        
        return unlocked
    }
    
    func checkPrerequisites(for lessonId: String, profile: UserProfile) -> Bool {
        guard let lesson = Curriculum.allLessons.first(where: { $0.id == lessonId }) else {
            return false
        }
        
        if lesson.prerequisites.isEmpty {
            return true
        }
        
        return lesson.prerequisites.allSatisfy { prerequisiteId in
            profile.completedLessons.contains(prerequisiteId)
        }
    }
}
