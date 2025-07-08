// MARK: - Lesson Service Implementation
// File: ArtOfTheFuture/Features/Lessons/Services/LessonService.swift

import Foundation

final class LessonService: LessonServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func loadLesson(id: String) async throws -> InteractiveLesson {
        // For now, return mock lessons. In production, this would load from a server or bundle
        let mockLessons = getMockInteractiveLessons()
        guard let lesson = mockLessons.first(where: { $0.id == id }) else {
            throw LessonServiceError.lessonNotFound
        }
        return lesson
    }
    
    func getLessonsForUser() async throws -> [InteractiveLesson] {
        let lessons = getMockInteractiveLessons()
        
        // Load user progress to determine which lessons are unlocked
        let completedLessons = getCompletedLessons()
        
        return lessons.map { lesson in
            var updatedLesson = lesson
            updatedLesson.isCompleted = completedLessons.contains(lesson.id)
            updatedLesson.isLocked = !shouldUnlockLesson(lesson, completedLessons: completedLessons)
            return updatedLesson
        }
    }
    
    func unlockNextLessons(after completedLesson: InteractiveLesson) async throws {
        // Logic to unlock dependent lessons
        let allLessons = try await getLessonsForUser()
        let completedLessons = getCompletedLessons()
        
        for lesson in allLessons {
            if lesson.prerequisites.contains(completedLesson.id) {
                // Unlock this lesson
                var unlockedLessons = getUnlockedLessons()
                unlockedLessons.insert(lesson.id)
                saveUnlockedLessons(unlockedLessons)
            }
        }
    }
    
    private func shouldUnlockLesson(_ lesson: InteractiveLesson, completedLessons: Set<String>) -> Bool {
        // First lesson is always unlocked
        if lesson.prerequisites.isEmpty {
            return true
        }
        
        // Check if all prerequisites are completed
        return lesson.prerequisites.allSatisfy { completedLessons.contains($0) }
    }
    
    private func getCompletedLessons() -> Set<String> {
        guard let data = userDefaults.data(forKey: "completedLessons"),
              let lessons = try? decoder.decode(Set<String>.self, from: data) else {
            return []
        }
        return lessons
    }
    
    private func getUnlockedLessons() -> Set<String> {
        guard let data = userDefaults.data(forKey: "unlockedLessons"),
              let lessons = try? decoder.decode(Set<String>.self, from: data) else {
            return ["lesson_001"] // First lesson always unlocked
        }
        return lessons
    }
    
    private func saveUnlockedLessons(_ lessons: Set<String>) {
        guard let data = try? encoder.encode(lessons) else { return }
        userDefaults.set(data, forKey: "unlockedLessons")
    }
    
    // MARK: - Mock Data
    private func getMockInteractiveLessons() -> [InteractiveLesson] {
        [
            InteractiveLesson(
                id: "lesson_001",
                title: "Drawing Your First Circle",
                description: "Learn the fundamentals of drawing perfect circles with confidence",
                category: .basics,
                difficulty: .beginner,
                estimatedMinutes: 5,
                xpReward: 50,
                prerequisites: [],
                steps: [
                    LessonStep(
                        id: "step_001_intro",
                        order: 0,
                        type: .introduction,
                        title: "Welcome to Circle Drawing",
                        instruction: "In this lesson, you'll learn how to draw smooth, confident circles. This is a fundamental skill for all types of drawing.",
                        duration: 30,
                        guideLines: nil,
                        referenceImage: "circle_intro",
                        animatedDemo: nil,
                        validationRules: [],
                        successCriteria: SuccessCriteria(
                            minimumScore: 0.0,
                            requiredValidations: [],
                            timeLimit: nil,
                            allowRetries: true,
                            maxRetries: nil
                        )
                    ),
                    LessonStep(
                        id: "step_001_demo",
                        order: 1,
                        type: .demonstration,
                        title: "Watch: How to Draw a Circle",
                        instruction: "Watch carefully as we demonstrate the proper technique for drawing circles.",
                        duration: 45,
                        guideLines: nil,
                        referenceImage: "circle_demo",
                        animatedDemo: "circle_animation",
                        validationRules: [],
                        successCriteria: SuccessCriteria(
                            minimumScore: 0.0,
                            requiredValidations: [],
                            timeLimit: nil,
                            allowRetries: true,
                            maxRetries: nil
                        )
                    ),
                    LessonStep(
                        id: "step_001_practice",
                        order: 2,
                        type: .guidedPractice,
                        title: "Practice: Draw a Circle",
                        instruction: "Now it's your turn! Follow the guide to draw your own circle. Start at the top and move clockwise.",
                        duration: 120,
                        guideLines: [
                            GuideLine(
                                id: "circle_guide",
                                type: .circle,
                                points: [CGPoint(x: 200, y: 200), CGPoint(x: 250, y: 200)],
                                style: GuideLine.GuideStyle(
                                    color: "#3B82F6",
                                    width: 2.0,
                                    dashPattern: [5, 5],
                                    opacity: 0.7
                                ),
                                isAnimated: false
                            )
                        ],
                        referenceImage: nil,
                        animatedDemo: nil,
                        validationRules: [
                            ValidationRule(
                                id: "circle_accuracy",
                                type: .shapeRecognition,
                                tolerance: 0.8,
                                weight: 1.0
                            )
                        ],
                        successCriteria: SuccessCriteria(
                            minimumScore: 0.7,
                            requiredValidations: ["circle_accuracy"],
                            timeLimit: 180,
                            allowRetries: true,
                            maxRetries: 3
                        )
                    )
                ],
                learningObjectives: [
                    "Draw smooth, confident circles",
                    "Understand proper hand positioning",
                    "Practice consistent circular motions"
                ],
                skillsToLearn: [
                    DrawingSkill(
                        id: "circle_drawing",
                        name: "Circle Drawing",
                        description: "Ability to draw smooth circles",
                        icon: "circle",
                        category: .basicShapes
                    )
                ],
                thumbnail: "lesson_circle_thumb"
            ),
            
            InteractiveLesson(
                id: "lesson_002",
                title: "Straight Lines & Control",
                description: "Master the art of drawing straight, confident lines",
                category: .basics,
                difficulty: .beginner,
                estimatedMinutes: 7,
                xpReward: 75,
                prerequisites: ["lesson_001"],
                steps: [
                    // Similar structure for line drawing lesson
                ],
                learningObjectives: [
                    "Draw straight lines without rulers",
                    "Develop hand-eye coordination",
                    "Build confidence in line work"
                ],
                skillsToLearn: [
                    DrawingSkill(
                        id: "line_control",
                        name: "Line Control",
                        description: "Precise line drawing skills",
                        icon: "line.diagonal",
                        category: .lineControl
                    )
                ],
                thumbnail: "lesson_lines_thumb"
            )
        ]
    }
}

enum LessonServiceError: LocalizedError {
    case lessonNotFound
    case invalidData
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .lessonNotFound:
            return "Lesson not found"
        case .invalidData:
            return "Invalid lesson data"
        case .networkError:
            return "Network connection error"
        }
    }
}

// MARK: - Progress Service Implementation
// File: ArtOfTheFuture/Features/Lessons/Services/ProgressService.swift

import Foundation
import PencilKit

final class ProgressService: ProgressServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func recordStepCompletion(
        lessonId: String,
        stepId: String,
        duration: TimeInterval,
        score: Double,
        drawing: PKDrawing
    ) async {
        let completion = StepCompletion(
            lessonId: lessonId,
            stepId: stepId,
            completedAt: Date(),
            duration: duration,
            score: score,
            attempts: 1
        )
        
        var completions = getStepCompletions()
        completions.append(completion)
        saveStepCompletions(completions)
        
        // Save drawing if needed
        saveDrawingProgress(lessonId: lessonId, stepId: stepId, drawing: drawing)
    }
    
    func completeLesson(_ lesson: InteractiveLesson) async {
        // Mark lesson as completed
        var completedLessons = getCompletedLessons()
        completedLessons.insert(lesson.id)
        saveCompletedLessons(completedLessons)
        
        // Award XP
        await awardXP(lesson.xpReward)
        
        // Update user level if needed
        await updateUserLevel()
        
        // Record lesson completion
        let completion = LessonCompletion(
            lessonId: lesson.id,
            completedAt: Date(),
            finalScore: lesson.bestScore,
            totalDuration: lesson.estimatedMinutes * 60,
            xpAwarded: lesson.xpReward
        )
        
        var lessonCompletions = getLessonCompletions()
        lessonCompletions.append(completion)
        saveLessonCompletions(lessonCompletions)
    }
    
    func getUserProgress() async throws -> UserProgress {
        let completedLessons = Array(getCompletedLessons())
        let unlockedLessons = Array(getUnlockedLessons())
        let skillProgression = calculateSkillProgression()
        
        return UserProgress(
            completedLessons: completedLessons,
            unlockedLessons: unlockedLessons,
            skillProgression: skillProgression,
            totalXP: getCurrentXP(),
            currentStreak: getCurrentStreak()
        )
    }
    
    // MARK: - Private Methods
    private func getCompletedLessons() -> Set<String> {
        guard let data = userDefaults.data(forKey: "completedLessons"),
              let lessons = try? decoder.decode(Set<String>.self, from: data) else {
            return []
        }
        return lessons
    }
    
    private func saveCompletedLessons(_ lessons: Set<String>) {
        guard let data = try? encoder.encode(lessons) else { return }
        userDefaults.set(data, forKey: "completedLessons")
    }
    
    private func getUnlockedLessons() -> Set<String> {
        guard let data = userDefaults.data(forKey: "unlockedLessons"),
              let lessons = try? decoder.decode(Set<String>.self, from: data) else {
            return ["lesson_001"]
        }
        return lessons
    }
    
    private func getStepCompletions() -> [StepCompletion] {
        guard let data = userDefaults.data(forKey: "stepCompletions"),
              let completions = try? decoder.decode([StepCompletion].self, from: data) else {
            return []
        }
        return completions
    }
    
    private func saveStepCompletions(_ completions: [StepCompletion]) {
        guard let data = try? encoder.encode(completions) else { return }
        userDefaults.set(data, forKey: "stepCompletions")
    }
    
    private func getLessonCompletions() -> [LessonCompletion] {
        guard let data = userDefaults.data(forKey: "lessonCompletions"),
              let completions = try? decoder.decode([LessonCompletion].self, from: data) else {
            return []
        }
        return completions
    }
    
    private func saveLessonCompletions(_ completions: [LessonCompletion]) {
        guard let data = try? encoder.encode(completions) else { return }
        userDefaults.set(data, forKey: "lessonCompletions")
    }
    
    private func saveDrawingProgress(lessonId: String, stepId: String, drawing: PKDrawing) {
        let key = "drawing_\(lessonId)_\(stepId)"
        let data = drawing.dataRepresentation()
        userDefaults.set(data, forKey: key)
    }
    
    private func awardXP(_ xp: Int) async {
        let currentXP = getCurrentXP()
        userDefaults.set(currentXP + xp, forKey: "userXP")
    }
    
    private func getCurrentXP() -> Int {
        return userDefaults.integer(forKey: "userXP")
    }
    
    private func updateUserLevel() async {
        let xp = getCurrentXP()
        let newLevel = calculateLevel(from: xp)
        userDefaults.set(newLevel, forKey: "userLevel")
    }
    
    private func calculateLevel(from xp: Int) -> Int {
        // Simple level calculation: 100 XP per level
        return max(1, xp / 100)
    }
    
    private func getCurrentStreak() -> Int {
        return userDefaults.integer(forKey: "currentStreak")
    }
    
    private func calculateSkillProgression() -> [DrawingSkill.SkillCategory: Double] {
        let completions = getStepCompletions()
        var skillScores: [DrawingSkill.SkillCategory: [Double]] = [:]
        
        // This would analyze completed lessons and calculate skill progression
        // For now, return mock data
        return [
            .basicShapes: 0.75,
            .lineControl: 0.60,
            .shading: 0.30,
            .proportion: 0.20,
            .perspective: 0.10,
            .colorTheory: 0.05
        ]
    }
}

// MARK: - Progress Data Models
struct StepCompletion: Codable {
    let lessonId: String
    let stepId: String
    let completedAt: Date
    let duration: TimeInterval
    let score: Double
    let attempts: Int
}

struct LessonCompletion: Codable {
    let lessonId: String
    let completedAt: Date
    let finalScore: Double
    let totalDuration: TimeInterval
    let xpAwarded: Int
}
