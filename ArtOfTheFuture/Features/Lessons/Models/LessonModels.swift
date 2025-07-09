// MARK: - Unified Lesson Models
// File: ArtOfTheFuture/Core/Models/LessonModels.swift
// This is the SINGLE SOURCE OF TRUTH for all lesson-related models

import Foundation
import SwiftUI

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
    let objectives: [String]
    let tips: [String]
    
    // Dependencies
    let prerequisites: [String]
    let unlocks: [String]
    
    // Computed properties
    var totalSteps: Int { steps.count }
    var icon: String { category.icon }
    var color: Color { category.color }
}

// MARK: - Lesson Types
enum LessonType: String, Codable, CaseIterable {
    case practice = "Practice"
    case theory = "Theory"
    case challenge = "Challenge"
    
    var icon: String {
        switch self {
        case .practice: return "hand.draw.fill"
        case .theory: return "book.fill"
        case .challenge: return "sparkles"
        }
    }
    
    var color: Color {
        switch self {
        case .practice: return .blue
        case .theory: return .purple
        case .challenge: return .orange
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
    
    var icon: String {
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
    
    var color: Color {
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
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

// MARK: - Lesson Step Model
struct LessonStep: Identifiable, Codable {
    let id: String
    let order: Int
    let title: String
    let instruction: String
    let content: StepContent
    let validation: ValidationCriteria
    let hints: [String]
    let xpValue: Int
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
    let toolsAllowed: [DrawingTool]
    let timeLimit: TimeInterval?
    
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
    let constraints: [String: Any]?
    
    enum ChallengeType: String, Codable {
        case speedDraw
        case copyWork
        case freestyle
        case precision
    }
    
    enum CodingKeys: String, CodingKey {
        case challengeType, prompt, resources, constraints
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        challengeType = try container.decode(ChallengeType.self, forKey: .challengeType)
        prompt = try container.decode(String.self, forKey: .prompt)
        resources = try container.decode([String].self, forKey: .resources)
        constraints = nil // Simplified for now
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(challengeType, forKey: .challengeType)
        try container.encode(prompt, forKey: .prompt)
        try container.encode(resources, forKey: .resources)
        // Skip constraints for now
    }
}

// MARK: - Validation
struct ValidationCriteria: Codable {
    let minScore: Double
    let maxAttempts: Int
    let requiresAllCorrect: Bool
}

// MARK: - Drawing Tools
enum DrawingTool: String, Codable, CaseIterable {
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
}

// MARK: - Skill System
struct Skill: Codable, Identifiable {
    let id: String
    let name: String
    let category: SkillCategory
    let description: String
    let icon: String
    
    enum SkillCategory: String, Codable, CaseIterable {
        case fundamental = "Fundamental"
        case technique = "Technique"
        case creative = "Creative"
        case advanced = "Advanced"
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
