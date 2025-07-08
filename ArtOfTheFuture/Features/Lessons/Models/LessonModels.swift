// MARK: - Enhanced Lesson Models
// File: ArtOfTheFuture/Features/Models/LessonModels.swift

import Foundation
import SwiftUI
import PencilKit

// MARK: - Interactive Lesson Content
struct InteractiveLesson: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let category: Lesson.LessonCategory
    let difficulty: Lesson.Difficulty
    let estimatedMinutes: Int
    let xpReward: Int
    let prerequisites: [String] // Other lesson IDs
    
    // Interactive Components
    let steps: [LessonStep]
    let learningObjectives: [String]
    let skillsToLearn: [DrawingSkill]
    let thumbnail: String // Asset name
    
    var isLocked: Bool = true
    var isCompleted: Bool = false
    var completionDate: Date?
    var bestScore: Double = 0.0
}

struct LessonStep: Identifiable, Codable {
    let id: String
    let order: Int
    let type: StepType
    let title: String
    let instruction: String
    let duration: TimeInterval
    
    // Visual Guidance
    let guideLines: [GuideLine]?
    let referenceImage: String?
    let animatedDemo: String? // Lottie animation file
    
    // Validation
    let validationRules: [ValidationRule]
    let successCriteria: SuccessCriteria
    
    enum StepType: String, Codable {
        case introduction = "intro"
        case demonstration = "demo"
        case guidedPractice = "guided"
        case freePractice = "free"
        case assessment = "assessment"
    }
}

struct GuideLine: Codable {
    let id: String
    let type: GuideType
    let points: [CGPoint]
    let style: GuideStyle
    let isAnimated: Bool
    
    enum GuideType: String, Codable {
        case line, curve, circle, rectangle, freeform
    }
    
    struct GuideStyle: Codable {
        let color: String // Hex color
        let width: CGFloat
        let dashPattern: [CGFloat]?
        let opacity: Double
    }
}

struct ValidationRule: Codable {
    let id: String
    let type: ValidationType
    let tolerance: Double
    let weight: Double // Importance 0.0-1.0
    
    enum ValidationType: String, Codable {
        case strokeAccuracy = "stroke_accuracy"
        case shapeRecognition = "shape_recognition"
        case proportions = "proportions"
        case lineQuality = "line_quality"
        case completeness = "completeness"
    }
}

struct SuccessCriteria: Codable {
    let minimumScore: Double // 0.0-1.0
    let requiredValidations: [String] // ValidationRule IDs
    let timeLimit: TimeInterval?
    let allowRetries: Bool
    let maxRetries: Int?
}

struct DrawingSkill: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let category: SkillCategory
    
    enum SkillCategory: String, Codable, CaseIterable {
        case basicShapes = "Basic Shapes"
        case lineControl = "Line Control"
        case shading = "Shading"
        case proportion = "Proportion"
        case perspective = "Perspective"
        case colorTheory = "Color Theory"
    }
}

// MARK: - Lesson Player ViewModel
@MainActor
final class LessonPlayerViewModel: ObservableObject {
    @Published var currentLesson: InteractiveLesson
    @Published var currentStepIndex: Int = 0
    @Published var isPlaying: Bool = false
    @Published var stepProgress: Double = 0.0
    @Published var overallProgress: Double = 0.0
    @Published var userDrawing = PKDrawing()
    @Published var showGuidelines: Bool = true
    @Published var currentScore: Double = 0.0
    
    // Performance Tracking
    @Published var stepStartTime: Date?
    @Published var strokeCount: Int = 0
    @Published var mistakes: [ValidationError] = []
    
    private let lessonService: LessonServiceProtocol
    private let progressService: ProgressServiceProtocol
    
    var currentStep: LessonStep? {
        guard currentStepIndex < currentLesson.steps.count else { return nil }
        return currentLesson.steps[currentStepIndex]
    }
    
    var isLastStep: Bool {
        currentStepIndex >= currentLesson.steps.count - 1
    }
    
    init(lesson: InteractiveLesson,
         lessonService: LessonServiceProtocol? = nil,
         progressService: ProgressServiceProtocol? = nil) {
        self.currentLesson = lesson
        self.lessonService = lessonService ?? LessonService()
        self.progressService = progressService ?? ProgressService()
    }
    
    // MARK: - Lesson Control
    func startLesson() {
        isPlaying = true
        stepStartTime = Date()
        startCurrentStep()
    }
    
    func pauseLesson() {
        isPlaying = false
    }
    
    func nextStep() {
        guard !isLastStep else {
            completeLesson()
            return
        }
        
        completeCurrentStep()
        currentStepIndex += 1
        startCurrentStep()
    }
    
    func previousStep() {
        guard currentStepIndex > 0 else { return }
        currentStepIndex -= 1
        startCurrentStep()
    }
    
    func resetCurrentStep() {
        userDrawing = PKDrawing()
        strokeCount = 0
        stepProgress = 0.0
        currentScore = 0.0
        startCurrentStep()
    }
    
    private func startCurrentStep() {
        stepStartTime = Date()
        stepProgress = 0.0
        
        Task {
            await HapticManager.shared.impact(.light)
        }
    }
    
    private func completeCurrentStep() {
        guard let step = currentStep,
              let startTime = stepStartTime else { return }
        
        let duration = Date().timeIntervalSince(startTime)
        
        Task {
            await progressService.recordStepCompletion(
                lessonId: currentLesson.id,
                stepId: step.id,
                duration: duration,
                score: currentScore,
                drawing: userDrawing
            )
        }
        
        updateOverallProgress()
    }
    
    private func completeLesson() {
        currentLesson.isCompleted = true
        currentLesson.completionDate = Date()
        currentLesson.bestScore = max(currentLesson.bestScore, calculateOverallScore())
        
        Task {
            await progressService.completeLesson(currentLesson)
            await HapticManager.shared.notification(.success)
        }
    }
    
    // MARK: - Drawing Validation
    func validateDrawing() {
        guard let step = currentStep else { return }
        
        let validator = DrawingValidator()
        let results = validator.validate(
            drawing: userDrawing,
            against: step.validationRules,
            withGuidelines: step.guideLines ?? []
        )
        
        currentScore = results.overallScore
        stepProgress = results.completionPercentage
        mistakes = results.errors
        
        if results.meetsSuccessCriteria(step.successCriteria) {
            // Auto-advance or show completion
            if step.type == .guidedPractice {
                nextStep()
            }
        }
    }
    
    private func updateOverallProgress() {
        let totalSteps = Double(currentLesson.steps.count)
        overallProgress = Double(currentStepIndex + 1) / totalSteps
    }
    
    private func calculateOverallScore() -> Double {
        // Implementation would calculate weighted average of all step scores
        return currentScore
    }
}

// MARK: - Drawing Validator
struct DrawingValidator {
    func validate(
        drawing: PKDrawing,
        against rules: [ValidationRule],
        withGuidelines guidelines: [GuideLine]
    ) -> ValidationResult {
        
        var scores: [String: Double] = [:]
        var errors: [ValidationError] = []
        
        for rule in rules {
            let result = validateRule(rule, drawing: drawing, guidelines: guidelines)
            scores[rule.id] = result.score
            errors.append(contentsOf: result.errors)
        }
        
        let weightedScore = calculateWeightedScore(scores: scores, rules: rules)
        let completionPercentage = calculateCompletionPercentage(drawing: drawing, guidelines: guidelines)
        
        return ValidationResult(
            overallScore: weightedScore,
            completionPercentage: completionPercentage,
            ruleScores: scores,
            errors: errors
        )
    }
    
    private func validateRule(
        _ rule: ValidationRule,
        drawing: PKDrawing,
        guidelines: [GuideLine]
    ) -> RuleValidationResult {
        
        switch rule.type {
        case .strokeAccuracy:
            return validateStrokeAccuracy(drawing: drawing, guidelines: guidelines, tolerance: rule.tolerance)
        case .shapeRecognition:
            return validateShapeRecognition(drawing: drawing, guidelines: guidelines)
        case .proportions:
            return validateProportions(drawing: drawing, guidelines: guidelines)
        case .lineQuality:
            return validateLineQuality(drawing: drawing)
        case .completeness:
            return validateCompleteness(drawing: drawing, guidelines: guidelines)
        }
    }
    
    // Validation implementations would go here...
    private func validateStrokeAccuracy(drawing: PKDrawing, guidelines: [GuideLine], tolerance: Double) -> RuleValidationResult {
        // Implementation for stroke accuracy validation
        return RuleValidationResult(score: 0.8, errors: [])
    }
    
    private func validateShapeRecognition(drawing: PKDrawing, guidelines: [GuideLine]) -> RuleValidationResult {
        // Implementation for shape recognition
        return RuleValidationResult(score: 0.9, errors: [])
    }
    
    private func validateProportions(drawing: PKDrawing, guidelines: [GuideLine]) -> RuleValidationResult {
        // Implementation for proportion validation
        return RuleValidationResult(score: 0.85, errors: [])
    }
    
    private func validateLineQuality(drawing: PKDrawing) -> RuleValidationResult {
        // Implementation for line quality assessment
        return RuleValidationResult(score: 0.75, errors: [])
    }
    
    private func validateCompleteness(drawing: PKDrawing, guidelines: [GuideLine]) -> RuleValidationResult {
        // Implementation for completeness check
        return RuleValidationResult(score: 0.95, errors: [])
    }
    
    private func calculateWeightedScore(scores: [String: Double], rules: [ValidationRule]) -> Double {
        let totalWeight = rules.reduce(0.0) { $0 + $1.weight }
        let weightedSum = rules.reduce(0.0) { sum, rule in
            sum + (scores[rule.id] ?? 0.0) * rule.weight
        }
        return weightedSum / totalWeight
    }
    
    private func calculateCompletionPercentage(drawing: PKDrawing, guidelines: [GuideLine]) -> Double {
        // Calculate how much of the expected drawing is completed
        return 0.8 // Placeholder
    }
}

// MARK: - Validation Results
struct ValidationResult {
    let overallScore: Double
    let completionPercentage: Double
    let ruleScores: [String: Double]
    let errors: [ValidationError]
    
    func meetsSuccessCriteria(_ criteria: SuccessCriteria) -> Bool {
        return overallScore >= criteria.minimumScore &&
               criteria.requiredValidations.allSatisfy { ruleId in
                   ruleScores[ruleId] ?? 0.0 >= criteria.minimumScore
               }
    }
}

struct RuleValidationResult {
    let score: Double
    let errors: [ValidationError]
}

struct ValidationError: Identifiable {
    let id = UUID()
    let type: ErrorType
    let message: String
    let severity: Severity
    let location: CGPoint?
    
    enum ErrorType {
        case strokeTooFar, shapeMismatch, proportionOff, lineShaky, incomplete
    }
    
    enum Severity {
        case info, warning, error
    }
}

// MARK: - Services
protocol LessonServiceProtocol {
    func loadLesson(id: String) async throws -> InteractiveLesson
    func getLessonsForUser() async throws -> [InteractiveLesson]
    func unlockNextLessons(after completedLesson: InteractiveLesson) async throws
}

protocol ProgressServiceProtocol {
    func recordStepCompletion(lessonId: String, stepId: String, duration: TimeInterval, score: Double, drawing: PKDrawing) async
    func completeLesson(_ lesson: InteractiveLesson) async
    func getUserProgress() async throws -> UserProgress
}

struct UserProgress: Codable {
    let completedLessons: [String]
    let unlockedLessons: [String]
    let skillProgression: [DrawingSkill.SkillCategory: Double]
    let totalXP: Int
    let currentStreak: Int
}
