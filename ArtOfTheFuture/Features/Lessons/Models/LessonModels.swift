// MARK: - Complete Unified Lesson Models (NO HINTS - Clean & Focused)
// File: ArtOfTheFuture/Features/Lessons/Models/LessonModels.swift
// SINGLE SOURCE OF TRUTH for all lesson-related models

import Foundation
import SwiftUI
import PencilKit

// MARK: - Core Lesson Model
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

// MARK: - Lesson Types
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

// MARK: - Lesson Exercise Model (NO HINTS)
struct LessonExercise: Identifiable, Codable {
    let id: String
    let instruction: String
    let content: ExerciseContent
    let validation: ExerciseValidation
    let xpValue: Int
}

// MARK: - Exercise Content Types
enum ExerciseContent: Codable {
    case drawing(DrawingExercise)
    case theory(TheoryExercise)
    case challenge(ChallengeExercise)
    
    private enum CodingKeys: String, CodingKey {
        case type, data
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
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
        case "drawing":
            let content = try container.decode(DrawingExercise.self, forKey: .data)
            self = .drawing(content)
        case "theory":
            let content = try container.decode(TheoryExercise.self, forKey: .data)
            self = .theory(content)
        case "challenge":
            let content = try container.decode(ChallengeExercise.self, forKey: .data)
            self = .challenge(content)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown type: \(type)")
        }
    }
}

// MARK: - Drawing Exercise
struct DrawingExercise: Codable {
    let canvas: CanvasConfig
    let guidelines: [DrawingGuideline]?
    let referenceImage: String?
    let toolsAllowed: [LessonDrawingTool]
    let timeLimit: TimeInterval?
    
    struct CanvasConfig: Codable {
        let width: CGFloat
        let height: CGFloat
        let backgroundColor: String
        let gridEnabled: Bool
        let gridSize: CGFloat?
    }
}

// MARK: - Drawing Guideline
struct DrawingGuideline: Codable {
    let type: GuidelineType
    let path: [CGPoint]
    let style: GuidelineStyle
    
    enum GuidelineType: String, Codable {
        case line, circle, curve, rectangle
    }
    
    struct GuidelineStyle: Codable {
        let color: String
        let width: CGFloat
        let opacity: Double
        let dashPattern: [CGFloat]?
        let animated: Bool
    }
}

// MARK: - Theory Exercise
struct TheoryExercise: Codable {
    let question: String
    let visualAid: String?
    let interactionType: InteractionType
    let options: [TheoryOption]
    let correctAnswer: CorrectAnswer
    let explanation: String
    
    enum InteractionType: String, Codable {
        case multipleChoice
        case tapAreas
        case dragToMatch
        case orderSequence
        case slider
    }
    
    struct TheoryOption: Codable, Identifiable {
        let id: String
        let content: OptionContent
        
        enum OptionContent: Codable {
            case text(String)
            case image(String)
            case colorSwatch(String)
            case diagram(Data)
            
            private enum CodingKeys: String, CodingKey {
                case type, value
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                switch self {
                case .text(let text):
                    try container.encode("text", forKey: .type)
                    try container.encode(text, forKey: .value)
                case .image(let image):
                    try container.encode("image", forKey: .type)
                    try container.encode(image, forKey: .value)
                case .colorSwatch(let color):
                    try container.encode("color", forKey: .type)
                    try container.encode(color, forKey: .value)
                case .diagram(let data):
                    try container.encode("diagram", forKey: .type)
                    try container.encode(data, forKey: .value)
                }
            }
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let type = try container.decode(String.self, forKey: .type)
                
                switch type {
                case "text":
                    let text = try container.decode(String.self, forKey: .value)
                    self = .text(text)
                case "image":
                    let image = try container.decode(String.self, forKey: .value)
                    self = .image(image)
                case "color":
                    let color = try container.decode(String.self, forKey: .value)
                    self = .colorSwatch(color)
                case "diagram":
                    let data = try container.decode(Data.self, forKey: .value)
                    self = .diagram(data)
                default:
                    throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown type")
                }
            }
        }
    }
    
    enum CorrectAnswer: Codable {
        case single(String)
        case multiple([String])
        case sequence([String])
        case range(Double, Double)
        
        private enum CodingKeys: String, CodingKey {
            case type, value, min, max
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .single(let answer):
                try container.encode("single", forKey: .type)
                try container.encode(answer, forKey: .value)
            case .multiple(let answers):
                try container.encode("multiple", forKey: .type)
                try container.encode(answers, forKey: .value)
            case .sequence(let sequence):
                try container.encode("sequence", forKey: .type)
                try container.encode(sequence, forKey: .value)
            case .range(let min, let max):
                try container.encode("range", forKey: .type)
                try container.encode(min, forKey: .min)
                try container.encode(max, forKey: .max)
            }
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            
            switch type {
            case "single":
                let answer = try container.decode(String.self, forKey: .value)
                self = .single(answer)
            case "multiple":
                let answers = try container.decode([String].self, forKey: .value)
                self = .multiple(answers)
            case "sequence":
                let sequence = try container.decode([String].self, forKey: .value)
                self = .sequence(sequence)
            case "range":
                let min = try container.decode(Double.self, forKey: .min)
                let max = try container.decode(Double.self, forKey: .max)
                self = .range(min, max)
            default:
                throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown type")
            }
        }
    }
}

// MARK: - Challenge Exercise
struct ChallengeExercise: Codable {
    let challengeType: ChallengeType
    let prompt: String
    let resources: [String]
    let constraints: ChallengeConstraints
    
    enum ChallengeType: String, Codable {
        case completeHalfDrawing
        case transformShape
        case speedSketch
        case memoryRecreation
        case styleMimic
        case findMistakes
        case composition
    }
    
    struct ChallengeConstraints: Codable {
        let timeLimit: TimeInterval?
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

// MARK: - Lesson Step Model (NO HINTS - Clean & Simple)
struct LessonStep: Identifiable, Codable {
    let id: String
    let order: Int
    let title: String
    let instruction: String
    let content: StepContent
    let validation: ValidationCriteria
    let xpValue: Int
    // REMOVED: hints property for cleaner UX
}

// MARK: - Step Content Types
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

struct DrawingContent: Codable {
    let canvasSize: CGSize
    let backgroundColor: String
    let guidelines: [Guideline]?
    let referenceImage: String?
    let toolsAllowed: [LessonDrawingTool]
    
    struct Guideline: Codable {
        let type: GuidelineType
        let path: [CGPoint]
        let color: String
        let width: CGFloat
        let dashed: Bool
        
        enum GuidelineType: String, Codable {
            case line, circle, rectangle, curve
        }
    }
}

struct TheoryContent: Codable {
    let question: String
    let visualAid: String?
    let answerType: AnswerType
    let options: [AnswerOption]
    let correctAnswers: [String]
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

// MARK: - Validation (Simplified - Focus on Clear Instructions)
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
        // REMOVED: showHints - focusing on clear instructions instead
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

// MARK: - Progress Models (SINGLE SOURCE OF TRUTH)
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

// MARK: - Weekly Stats
struct WeeklyStats: Codable {
    let days: [DayStats]
    let totalMinutes: Int
    let totalXP: Int
    let averageMinutesPerDay: Double
    
    struct DayStats: Codable, Identifiable {
        let id = UUID()
        let date: Date
        let minutes: Int
        let xp: Int
        let completed: Bool
        
        enum CodingKeys: String, CodingKey {
            case date, minutes, xp, completed
        }
    }
}

// MARK: - Badge System
struct Badge: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let requirement: BadgeRequirement
    let xpReward: Int
    
    enum BadgeRequirement: Codable {
        case completeLesson(lessonId: String)
        case completeLessonsCount(count: Int)
        case achieveStreak(days: Int)
        case earnXP(amount: Int)
        case masterSkill(skillId: String)
        
        private enum CodingKeys: String, CodingKey {
            case type, value, count, days, amount, lessonId, skillId
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .completeLesson(let id):
                try container.encode("lesson", forKey: .type)
                try container.encode(id, forKey: .lessonId)
            case .completeLessonsCount(let count):
                try container.encode("count", forKey: .type)
                try container.encode(count, forKey: .count)
            case .achieveStreak(let days):
                try container.encode("streak", forKey: .type)
                try container.encode(days, forKey: .days)
            case .earnXP(let amount):
                try container.encode("xp", forKey: .type)
                try container.encode(amount, forKey: .amount)
            case .masterSkill(let id):
                try container.encode("skill", forKey: .type)
                try container.encode(id, forKey: .skillId)
            }
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            
            switch type {
            case "lesson":
                let id = try container.decode(String.self, forKey: .lessonId)
                self = .completeLesson(lessonId: id)
            case "count":
                let count = try container.decode(Int.self, forKey: .count)
                self = .completeLessonsCount(count: count)
            case "streak":
                let days = try container.decode(Int.self, forKey: .days)
                self = .achieveStreak(days: days)
            case "xp":
                let amount = try container.decode(Int.self, forKey: .amount)
                self = .earnXP(amount: amount)
            case "skill":
                let id = try container.decode(String.self, forKey: .skillId)
                self = .masterSkill(skillId: id)
            default:
                throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown type")
            }
        }
    }
}
