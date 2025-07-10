// MARK: - Dependency Injection Container
// File: ArtOfTheFuture/Core/Container.swift

import Foundation

@MainActor
final class Container {
    static let shared = Container()
    
    // MARK: - Services
    lazy var galleryService: GalleryServiceProtocol = {
        GalleryService()
    }()
    
    lazy var userService: UserServiceProtocol = {
        UserService()
    }()
    
    lazy var lessonService: LessonServiceProtocol = {
        LessonService.shared // Use shared instance since it has internal initialization
    }()

    lazy var progressService: ProgressServiceProtocol = {
        ProgressService.shared // Use shared instance
    }()
    
    private init() {
        print("Container initialized")
    }
}

// MARK: - LessonServiceProtocol
protocol LessonServiceProtocol {
    func getAllLessons() async throws -> [Lesson]
    func getLesson(id: String) async throws -> Lesson?
    func getLessonsForUser() async throws -> [Lesson]
    func getUnlockedLessons(for profile: UserProfile) -> Set<String>
    func checkPrerequisites(for lessonId: String, profile: UserProfile) -> Bool
}

// MARK: - LessonService (Public Access Fixed)
final class LessonService: LessonServiceProtocol {
    static let shared = LessonService()
    
    // Make initializer internal instead of private for Container access
    init() {}
    
    func getAllLessons() async throws -> [Lesson] {
        return Curriculum.allLessons
    }
    
    func getLesson(id: String) async throws -> Lesson? {
        return Curriculum.allLessons.first { $0.id == id }
    }
    
    func getLessonsForUser() async throws -> [Lesson] {
        // For now, return all lessons
        // In production, this would filter based on user progress
        return try await getAllLessons()
    }
    
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

// MARK: - Curriculum
struct Curriculum {
    static var allLessons: [Lesson] {
        // Return a simplified lesson set for now to avoid curriculum complexity
        return [
            Lesson(
                id: "lesson_001",
                title: "Basic Lines",
                description: "Learn to draw straight lines",
                type: .practice,
                category: .basics,
                difficulty: .beginner,
                estimatedMinutes: 5,
                xpReward: 50,
                steps: [],
                objectives: ["Draw straight lines"],
                tips: ["Keep your hand steady"],
                prerequisites: [],
                unlocks: ["lesson_002"]
            ),
            Lesson(
                id: "lesson_002",
                title: "Basic Shapes",
                description: "Learn to draw circles and squares",
                type: .practice,
                category: .basics,
                difficulty: .beginner,
                estimatedMinutes: 10,
                xpReward: 100,
                steps: [],
                objectives: ["Draw circles", "Draw squares"],
                tips: ["Use your whole arm"],
                prerequisites: ["lesson_001"],
                unlocks: ["lesson_003"]
            )
        ]
    }
    
    static var allBadges: [Badge] {
        return [
            Badge(
                id: "first_lesson",
                name: "First Steps",
                description: "Complete your first lesson",
                icon: "star.fill",
                requirement: .completeLesson(lessonId: "lesson_001"),
                xpReward: 50
            )
        ]
    }
}
