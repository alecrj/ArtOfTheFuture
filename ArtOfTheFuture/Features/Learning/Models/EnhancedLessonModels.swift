// MARK: - Enhanced Lesson Models
// File: ArtOfTheFuture/Features/Lessons/Models/EnhancedLessonModels.swift

import Foundation
import SwiftUI
import PencilKit

// MARK: - Core Lesson Types
enum LessonType: String, Codable, CaseIterable {
    case drawingPractice = "Drawing Practice"
    case theoryFundamentals = "Theory Fundamentals"
    case creativeChallenge = "Creative Challenge"
    
    var icon: String {
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

enum DifficultyLevel: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var requiredXP: Int {
        switch self {
        case .beginner: return 0
        case .intermediate: return 500
        case .advanced: return 2000
        }
    }
}

// MARK: - Enhanced Lesson Structure
struct DuolingoLesson: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let type: LessonType
    let difficulty: DifficultyLevel
    let estimatedMinutes: Int
    let xpReward: Int
    let hearts: Int = 3 // Lives system
    
    // Content
    let exercises: [LessonExercise]
    let objectives: [String]
    let skills: [DrawingSkill]
    let tips: [String]
    
    // Progress Tracking
    var isUnlocked: Bool = false
    var isCompleted: Bool = false
    var bestScore: Double = 0.0
    var timesCompleted: Int = 0
    var lastCompletedDate: Date?
    
    // Dependencies
    let prerequisites: [String]
    let unlocks: [String]
}

// MARK: - Exercise Types
struct LessonExercise: Identifiable, Codable {
    let id: String
    let order: Int
    let type: ExerciseType
    let instruction: String
    let content: ExerciseContent
    let validation: ValidationCriteria
    let hints: [String]
    let xpValue: Int
    
    enum ExerciseType: String, Codable {
        // Drawing Practice Types
        case traceDrawing = "trace"
        case freehandDrawing = "freehand"
        case guidedDrawing = "guided"
        case gestureDrawing = "gesture"
        case shapeConstruction = "shapes"
        
        // Theory Types
        case multipleChoice = "multiple_choice"
        case tapToIdentify = "tap_identify"
        case dragAndDrop = "drag_drop"
        case orderSteps = "order_steps"
        case fillInBlank = "fill_blank"
        
        // Creative Challenge Types
        case completeDrawing = "complete"
        case spotDifference = "spot_diff"
        case quickSketch = "quick_sketch"
        case styleChallenge = "style"
        case memoryDraw = "memory"
    }
}

// MARK: - Exercise Content
enum ExerciseContent: Codable {
    case drawing(DrawingExercise)
    case theory(TheoryExercise)
    case challenge(ChallengeExercise)
    
    enum CodingKeys: String, CodingKey {
        case type, data
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .drawing(let exercise):
            try container.encode("drawing", forKey: .type)
            try container.encode(exercise, forKey: .data)
        case .theory(let exercise):
            try container.encode("theory", forKey: .type)
            try container.encode(exercise, forKey: .data)
        case .challenge(let exercise):
            try container.encode("challenge", forKey: .type)
            try container.encode(exercise, forKey: .data)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "drawing":
            let exercise = try container.decode(DrawingExercise.self, forKey: .data)
            self = .drawing(exercise)
        case "theory":
            let exercise = try container.decode(TheoryExercise.self, forKey: .data)
            self = .theory(exercise)
        case "challenge":
            let exercise = try container.decode(ChallengeExercise.self, forKey: .data)
            self = .challenge(exercise)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown type: \(type)")
        }
    }
}

// MARK: - Drawing Exercise
struct DrawingExercise: Codable {
    let canvas: CanvasSetup
    let guidelines: [DrawingGuideline]?
    let referenceImage: String?
    let animationDemo: String?
    let timeLimit: TimeInterval?
    let toolsAllowed: [DrawingTool]
    
    struct CanvasSetup: Codable {
        let width: CGFloat
        let height: CGFloat
        let backgroundColor: String
        let gridEnabled: Bool
        let gridSize: CGFloat?
    }
}

struct DrawingGuideline: Codable {
    let id: String
    let type: GuideType
    let path: [CGPoint]
    let style: GuideStyle
    let showTiming: ShowTiming
    
    enum GuideType: String, Codable {
        case line, curve, circle, ellipse, rectangle, polygon, freeform
    }
    
    struct GuideStyle: Codable {
        let color: String
        let width: CGFloat
        let opacity: Double
        let dashPattern: [CGFloat]?
        let animated: Bool
        let animationDuration: TimeInterval?
    }
    
    enum ShowTiming: String, Codable {
        case always, initial, onHint, never
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
        let feedback: String?
        
        enum OptionContent: Codable {
            case text(String)
            case image(String)
            case colorSwatch(String)
            case diagram(DiagramData)
        }
    }
    
    enum CorrectAnswer: Codable {
        case single(String)
        case multiple([String])
        case sequence([String])
        case range(min: Double, max: Double)
    }
}

// MARK: - Challenge Exercise
struct ChallengeExercise: Codable {
    let challengeType: ChallengeType
    let prompt: String
    let resources: [String]
    let constraints: ChallengeConstraints
    let judgingCriteria: [JudgingCriterion]
    
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
        let toolRestrictions: [String]?
        let colorPalette: [String]?
    }
}

// MARK: - Validation & Scoring
struct ValidationCriteria: Codable {
    let minScore: Double
    let maxAttempts: Int
    let rules: [ValidationRule]
    let feedback: FeedbackSettings
    
    struct FeedbackSettings: Codable {
        let showRealtime: Bool
        let showHints: Bool
        let encouragementThreshold: Double
    }
}

struct JudgingCriterion: Codable {
    let id: String
    let name: String
    let weight: Double
    let evaluationType: EvaluationType
    
    enum EvaluationType: String, Codable {
        case automatic
        case selfAssess
        case peerReview
        case aiAssisted
    }
}

// MARK: - Progress & Achievements
struct LessonProgress: Codable {
    let lessonId: String
    let userId: String
    let startedAt: Date
    let completedAt: Date?
    let exerciseScores: [String: ExerciseScore]
    let heartsRemaining: Int
    let hintsUsed: Int
    let totalXPEarned: Int
    let streak: Int
    
    struct ExerciseScore: Codable {
        let exerciseId: String
        let score: Double
        let attempts: Int
        let timeSpent: TimeInterval
        let mistakesMade: [String]
    }
}

// MARK: - Gamification Elements
struct AchievementBadge: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let rarity: Rarity
    let criteria: UnlockCriteria
    var isUnlocked: Bool = false
    var unlockedDate: Date?
    
    enum Rarity: String, Codable {
        case common, rare, epic, legendary
        
        var color: Color {
            switch self {
            case .common: return .gray
            case .rare: return .blue
            case .epic: return .purple
            case .legendary: return .orange
            }
        }
    }
    
    enum UnlockCriteria: Codable {
        case completeLesson(String)
        case completeLessonType(LessonType, count: Int)
        case achieveStreak(Int)
        case earnXP(Int)
        case perfectScore(count: Int)
        case speedRun(lessonId: String, seconds: Int)
    }
}

// MARK: - User Skill Profile
struct UserSkillProfile: Codable {
    let userId: String
    var currentLevel: DifficultyLevel
    var totalXP: Int
    var currentStreak: Int
    var longestStreak: Int
    var skillLevels: [DrawingSkill.SkillCategory: SkillLevel]
    var unlockedLessons: Set<String>
    var completedLessons: Set<String>
    var achievements: [String]
    var weeklyGoal: WeeklyGoal
    
    struct SkillLevel: Codable {
        let level: Int // 1-10
        let xp: Int
        let lastPracticed: Date
    }
    
    struct WeeklyGoal: Codable {
        let targetXP: Int
        let currentXP: Int
        let targetLessons: Int
        let completedLessons: Int
        let resetDate: Date
    }
}

// MARK: - Placement Test
struct PlacementTest: Codable {
    let id: String
    let exercises: [PlacementExercise]
    
    struct PlacementExercise: Codable {
        let id: String
        let type: ExerciseType
        let difficulty: DifficultyLevel
        let skill: DrawingSkill.SkillCategory
        let content: ExerciseContent
        let weight: Double
    }
    
    enum ExerciseType: String, Codable {
        case quickTheory
        case drawBasicShape
        case identifyTechnique
        case proportionCheck
    }
}
