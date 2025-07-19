// MARK: - LessonModels.swift - MINIMAL FIX FOR COMPILATION ERRORS
// File Path: ArtOfTheFuture/Features/Lessons/Models/LessonModels.swift
// REPLACE ENTIRE FILE WITH THIS

import Foundation
import SwiftUI
import PencilKit

// MARK: - Core Lesson Model (EXISTING - NO CHANGES)
struct Lesson: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let type: LessonType
    let category: LessonCategory
    let difficulty: DifficultyLevel
    let estimatedMinutes: Int
    let xpReward: Int
    
    // Content
    let steps: [LessonStep]
    let exercises: [LessonExercise]
    let objectives: [String]
    let tips: [String]
    
    // Dependencies
    let prerequisites: [String]
    let unlocks: [String]
    
    // System properties for gamification - Made optional with default
    var hearts: Int = 3
    
    // Computed properties
    var totalSteps: Int { steps.count }
    var icon: String { category.iconName }
    var color: Color { category.categoryColor }
    var isLocked: Bool { false } // Will be computed based on user progress
    var isCompleted: Bool { false } // Will be computed based on user progress
}

// MARK: - Lesson Types (EXISTING)
enum LessonType: String, Codable, CaseIterable {
    case drawingPractice = "Practice"
    case theoryFundamentals = "Theory"
    case creativeChallenge = "Challenge"
    
    var iconName: String {
        switch self {
        case .drawingPractice: return "hand.draw.fill"
        case .theoryFundamentals: return "book.fill"
        case .creativeChallenge: return "sparkles"
        }
    }
    
    var color: Color {
        switch self {
        case .drawingPractice: return .blue
        case .theoryFundamentals: return .purple
        case .creativeChallenge: return .orange
        }
    }
}

enum LessonCategory: String, Codable, CaseIterable {
    case basics = "Basics"
    case drawing = "Drawing"
    case theory = "Theory"
    case shading = "Shading"
    case perspective = "Perspective"
    case color = "Color"
    case advanced = "Advanced"
    
    var iconName: String {
        switch self {
        case .basics: return "pencil"
        case .drawing: return "scribble"
        case .theory: return "book"
        case .shading: return "circle.lefthalf.filled"
        case .perspective: return "cube"
        case .color: return "paintpalette"
        case .advanced: return "star.fill"
        }
    }
    
    var categoryColor: Color {
        switch self {
        case .basics: return .blue
        case .drawing: return .green
        case .theory: return .purple
        case .shading: return .orange
        case .perspective: return .red
        case .color: return .pink
        case .advanced: return .indigo
        }
    }
}

enum DifficultyLevel: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var requiredLevel: Int {
        switch self {
        case .beginner: return 1
        case .intermediate: return 5
        case .advanced: return 10
        }
    }
    
    var difficultyColor: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

// MARK: - Lesson Step Model (EXISTING)
struct LessonStep: Identifiable, Codable {
    let id: String
    let order: Int
    let title: String
    let instruction: String
    let content: StepContent
    let validation: ValidationCriteria
    let xpValue: Int
}

// MARK: - Step Content Types (EXTENDED FOR VALIDATION)
enum StepContent: Codable {
    case introduction(IntroContent)
    case drawing(DrawingContent)
    case theory(TheoryContent)
    case challenge(ChallengeContent)
    
    private enum CodingKeys: String, CodingKey {
        case type, data
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .introduction(let content):
            try container.encode("introduction", forKey: .type)
            try container.encode(content, forKey: .data)
        case .drawing(let content):
            try container.encode("drawing", forKey: .type)
            try container.encode(content, forKey: .data)
        case .theory(let content):
            try container.encode("theory", forKey: .type)
            try container.encode(content, forKey: .data)
        case .challenge(let content):
            try container.encode("challenge", forKey: .type)
            try container.encode(content, forKey: .data)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "introduction":
            let content = try container.decode(IntroContent.self, forKey: .data)
            self = .introduction(content)
        case "drawing":
            let content = try container.decode(DrawingContent.self, forKey: .data)
            self = .drawing(content)
        case "theory":
            let content = try container.decode(TheoryContent.self, forKey: .data)
            self = .theory(content)
        case "challenge":
            let content = try container.decode(ChallengeContent.self, forKey: .data)
            self = .challenge(content)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown type: \(type)")
        }
    }
}

// MARK: - Content Types
struct IntroContent: Codable {
    let displayImage: String?
    let animationName: String?
    let bulletPoints: [String]
}

// MARK: - Enhanced Drawing Content (FOR VALIDATION)
struct DrawingContent: Codable {
    let canvasSize: CGSize
    let backgroundColor: String
    let guidelines: [Guideline]?
    let referenceImage: String?
    let toolsAllowed: [LessonDrawingTool]
    
    // NEW: Validation properties
    let expectedShape: ShapeType
    let drawingConstraints: DrawingConstraints?
    
    // Default initializer for backwards compatibility
    init(canvasSize: CGSize, backgroundColor: String, guidelines: [Guideline]? = nil, referenceImage: String? = nil, toolsAllowed: [LessonDrawingTool] = [.pen], expectedShape: ShapeType = .none, drawingConstraints: DrawingConstraints? = nil) {
        self.canvasSize = canvasSize
        self.backgroundColor = backgroundColor
        self.guidelines = guidelines
        self.referenceImage = referenceImage
        self.toolsAllowed = toolsAllowed
        self.expectedShape = expectedShape
        self.drawingConstraints = drawingConstraints
    }
    
    struct Guideline: Codable {
        let type: GuidelineType
        let startPoint: CGPoint
        let endPoint: CGPoint?
        let center: CGPoint?
        let radius: CGFloat?
        let color: String
        let opacity: Double
        
        enum GuidelineType: String, Codable {
            case line = "line"
            case circle = "circle"
            case point = "point"
        }
        
        // Convenience initializers
        static func line(from start: CGPoint, to end: CGPoint, color: String = "#4A90E2", opacity: Double = 0.3) -> Guideline {
            return Guideline(
                type: .line,
                startPoint: start,
                endPoint: end,
                center: nil,
                radius: nil,
                color: color,
                opacity: opacity
            )
        }
        
        static func circle(center: CGPoint, radius: CGFloat, color: String = "#9B59B6", opacity: Double = 0.2) -> Guideline {
            return Guideline(
                type: .circle,
                startPoint: CGPoint.zero,
                endPoint: nil,
                center: center,
                radius: radius,
                color: color,
                opacity: opacity
            )
        }
        
        static func point(at location: CGPoint, color: String = "#E74C3C", opacity: Double = 0.8) -> Guideline {
            return Guideline(
                type: .point,
                startPoint: location,
                endPoint: nil,
                center: nil,
                radius: nil,
                color: color,
                opacity: opacity
            )
        }
    }
}

// NEW: Shape types for validation
enum ShapeType: String, Codable {
    case line = "line"
    case circle = "circle"
    case square = "square"
    case none = "none"
}

struct TheoryContent: Codable {
    let question: String
    let visualAid: String?
    let answerType: AnswerType
    let options: [String] // Simplified from AnswerOption array
    let correctAnswer: Int // Index of correct answer
    let explanation: String
    
    enum AnswerType: String, Codable {
        case singleChoice
        case multipleChoice
        case trueFalse
        case matching
        case ordering
    }
    
    struct AnswerOption: Codable, Identifiable {
        let id: String
        let text: String
        let image: String?
    }
    
    // Computed property for compatibility
    var correctAnswers: [String] { ["\(correctAnswer)"] }
}

struct ChallengeContent: Codable {
    let challengeType: ChallengeType
    let prompt: String
    let resources: [String]
    let constraints: [String: String]?
    
    enum ChallengeType: String, Codable {
        case speedDraw
        case copyWork
        case freestyle
        case precision
    }
}

// MARK: - Validation (EXTENDED)
struct ValidationCriteria: Codable {
    let minScore: Double
    let maxAttempts: Int
    let rules: [ValidationRule]
    let feedback: FeedbackConfig
    let requiresAllCorrect: Bool
    
    struct ValidationRule: Codable {
        let id: String
        let type: String
        let threshold: Double
    }
    
    struct FeedbackConfig: Codable {
        let showRealtime: Bool
        let encouragementThreshold: Double
    }
}

// MARK: - Drawing Tools
enum LessonDrawingTool: String, Codable, CaseIterable {
    case pen = "Pen"
    case pencil = "Pencil"
    case marker = "Marker"
    case eraser = "Eraser"
    
    var icon: String {
        switch self {
        case .pen: return "pencil.tip"
        case .pencil: return "pencil"
        case .marker: return "highlighter"
        case .eraser: return "eraser"
        }
    }
    
    func pkTool(color: UIColor, width: CGFloat) -> PKTool {
        switch self {
        case .pen:
            return PKInkingTool(.pen, color: color, width: width)
        case .pencil:
            return PKInkingTool(.pencil, color: color, width: width)
        case .marker:
            return PKInkingTool(.marker, color: color, width: width)
        case .eraser:
            return PKEraserTool(.bitmap)
        }
    }
}

struct DrawingConstraints: Codable {
    let strokeLimit: Int?
    let colorPalette: [String]?
    let toolRestrictions: [LessonDrawingTool]?
}

// MARK: - Lesson Exercise Model
struct LessonExercise: Identifiable, Codable {
    let id: String
    let instruction: String
    let content: ExerciseContent
    let validation: ExerciseValidation
    let xpValue: Int
}

// MARK: - Exercise Content Types
enum ExerciseContent: Codable {
    case drawing(DrawingExerciseContent)
    
    struct DrawingExerciseContent: Codable {
        let canvasSize: CGSize
        let backgroundColor: String
        let toolsAllowed: [LessonDrawingTool]
        let timeLimit: Int?
        let strokeLimit: Int?
        let colorPalette: [String]?
        let toolRestrictions: [LessonDrawingTool]?
    }
}

// MARK: - Exercise Validation
struct ExerciseValidation: Codable {
    let minScore: Double
    let maxAttempts: Int
    let autoCheck: Bool
}

// MARK: - Progress Models
struct LessonProgress: Codable {
    let lessonId: String
    var isCompleted: Bool = false
    var isUnlocked: Bool = false
    var bestScore: Double = 0.0
    var totalAttempts: Int = 0
    var stepProgress: [String: StepProgress] = [:]
    var lastAttemptDate: Date?
    var totalTimeSpent: TimeInterval = 0
    
    var completionPercentage: Double {
        guard !stepProgress.isEmpty else { return 0 }
        let completed = stepProgress.values.filter { $0.isCompleted }.count
        return Double(completed) / Double(stepProgress.count)
    }
}

struct StepProgress: Codable {
    let stepId: String
    var isCompleted: Bool = false
    var attempts: Int = 0
    var bestScore: Double = 0.0
    var timeSpent: TimeInterval = 0
    var lastAttemptDate: Date?
}

// MARK: - Badge System
struct Badge: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let requirement: BadgeRequirement
    let xpReward: Int
}

enum BadgeRequirement: Codable {
    case completeLesson(lessonId: String)
    case completeLessonsCount(count: Int)
    case achieveStreak(days: Int)
    
    enum CodingKeys: String, CodingKey {
        case type, value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .completeLesson(let lessonId):
            try container.encode("completeLesson", forKey: .type)
            try container.encode(lessonId, forKey: .value)
        case .completeLessonsCount(let count):
            try container.encode("completeLessonsCount", forKey: .type)
            try container.encode(count, forKey: .value)
        case .achieveStreak(let days):
            try container.encode("achieveStreak", forKey: .type)
            try container.encode(days, forKey: .value)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "completeLesson":
            let lessonId = try container.decode(String.self, forKey: .value)
            self = .completeLesson(lessonId: lessonId)
        case "completeLessonsCount":
            let count = try container.decode(Int.self, forKey: .value)
            self = .completeLessonsCount(count: count)
        case "achieveStreak":
            let days = try container.decode(Int.self, forKey: .value)
            self = .achieveStreak(days: days)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown type: \(type)")
        }
    }
}
