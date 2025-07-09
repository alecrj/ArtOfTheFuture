// MARK: - Enhanced Lesson Models
// File: ArtOfTheFuture/Features/Learning/Models/EnhancedLessonModels.swift

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
struct Lesson: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let type: LessonType
    let difficulty: DifficultyLevel
    let estimatedMinutes: Int
    let xpReward: Int
    let hearts: Int = 3 // Lives system
    
    // Content
    let exercises: [LessonStep]
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
struct LessonStep: Identifiable, Codable {
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
            
            enum CodingKeys: String, CodingKey {
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
                    try container.encode("colorSwatch", forKey: .type)
                    try container.encode(color, forKey: .value)
                case .diagram(let diagram):
                    try container.encode("diagram", forKey: .type)
                    try container.encode(diagram, forKey: .value)
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
                case "colorSwatch":
                    let color = try container.decode(String.self, forKey: .value)
                    self = .colorSwatch(color)
                case "diagram":
                    let diagram = try container.decode(DiagramData.self, forKey: .value)
                    self = .diagram(diagram)
                default:
                    throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown content type: \(type)")
                }
            }
        }
    }
    
    enum CorrectAnswer: Codable {
        case single(String)
        case multiple([String])
        case sequence([String])
        case range(min: Double, max: Double)
        
        enum CodingKeys: String, CodingKey {
            case type, value, min, max
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .single(let id):
                try container.encode("single", forKey: .type)
                try container.encode(id, forKey: .value)
            case .multiple(let ids):
                try container.encode("multiple", forKey: .type)
                try container.encode(ids, forKey: .value)
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
                let id = try container.decode(String.self, forKey: .value)
                self = .single(id)
            case "multiple":
                let ids = try container.decode([String].self, forKey: .value)
                self = .multiple(ids)
            case "sequence":
                let sequence = try container.decode([String].self, forKey: .value)
                self = .sequence(sequence)
            case "range":
                let min = try container.decode(Double.self, forKey: .min)
                let max = try container.decode(Double.self, forKey: .max)
                self = .range(min: min, max: max)
            default:
                throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown answer type: \(type)")
            }
        }
    }
}

// MARK: - DiagramData
struct DiagramData: Codable {
    let id: String
    let imageName: String
    let overlayPoints: [CGPoint]
    let description: String
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

// MARK: - Progress & Enhanced Achievements
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

// MARK: - Enhanced Achievement System
struct LessonAchievementBadge: Identifiable, Codable {
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
        
        enum CodingKeys: String, CodingKey {
            case type, lessonId, lessonType, count, streak, xp, seconds
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .completeLesson(let id):
                try container.encode("completeLesson", forKey: .type)
                try container.encode(id, forKey: .lessonId)
            case .completeLessonType(let type, let count):
                try container.encode("completeLessonType", forKey: .type)
                try container.encode(type, forKey: .lessonType)
                try container.encode(count, forKey: .count)
            case .achieveStreak(let streak):
                try container.encode("achieveStreak", forKey: .type)
                try container.encode(streak, forKey: .streak)
            case .earnXP(let xp):
                try container.encode("earnXP", forKey: .type)
                try container.encode(xp, forKey: .xp)
            case .perfectScore(let count):
                try container.encode("perfectScore", forKey: .type)
                try container.encode(count, forKey: .count)
            case .speedRun(let lessonId, let seconds):
                try container.encode("speedRun", forKey: .type)
                try container.encode(lessonId, forKey: .lessonId)
                try container.encode(seconds, forKey: .seconds)
            }
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            
            switch type {
            case "completeLesson":
                let id = try container.decode(String.self, forKey: .lessonId)
                self = .completeLesson(id)
            case "completeLessonType":
                let lessonType = try container.decode(LessonType.self, forKey: .lessonType)
                let count = try container.decode(Int.self, forKey: .count)
                self = .completeLessonType(lessonType, count: count)
            case "achieveStreak":
                let streak = try container.decode(Int.self, forKey: .streak)
                self = .achieveStreak(streak)
            case "earnXP":
                let xp = try container.decode(Int.self, forKey: .xp)
                self = .earnXP(xp)
            case "perfectScore":
                let count = try container.decode(Int.self, forKey: .count)
                self = .perfectScore(count: count)
            case "speedRun":
                let lessonId = try container.decode(String.self, forKey: .lessonId)
                let seconds = try container.decode(Int.self, forKey: .seconds)
                self = .speedRun(lessonId: lessonId, seconds: seconds)
            default:
                throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown criteria type: \(type)")
            }
        }
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
        
        enum ExerciseType: String, Codable {
            case quickTheory
            case drawBasicShape
            case identifyTechnique
            case proportionCheck
        }
    }
}

// MARK: - Services
protocol LessonServiceProtocol {
    func loadLesson(id: String) async throws -> Lesson
    func getLessonsForUser() async throws -> [Lesson]
    func unlockNextLessons(after completedLesson: Lesson) async throws
}

protocol ProgressServiceProtocol {
    func recordStepCompletion(lessonId: String, stepId: String, duration: TimeInterval, score: Double, drawing: PKDrawing) async
    func completeLesson(_ lesson: Lesson) async
    func getUserProgress() async throws -> UserProgress
}

struct UserProgress: Codable {
    let completedLessons: [String]
    let unlockedLessons: [String]
    let skillProgression: [DrawingSkill.SkillCategory: Double]
    let totalXP: Int
    let currentStreak: Int
}

// MARK: - Extension for Drawing Skill Categories
extension DrawingSkill.SkillCategory {
    static let theory = DrawingSkill.SkillCategory.colorTheory // Reuse existing
    static let observation = DrawingSkill.SkillCategory.basicShapes // Reuse existing
    static let creativity = DrawingSkill.SkillCategory.basicShapes // Reuse existing
    static let sketching = DrawingSkill.SkillCategory.lineControl // Reuse existing
    static let figure = DrawingSkill.SkillCategory.proportion // Reuse existing
    static let composition = DrawingSkill.SkillCategory.perspective // Reuse existing
}
