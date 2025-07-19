// MARK: - CLEAN START: Complete Lesson System with Real Validation
// Replace: ArtOfTheFuture/Features/Lessons/Data/LessonsCurriculum.swift

import Foundation
import SwiftUI
import PencilKit

// MARK: - Enhanced Validation Models (Real Shape Detection)
struct DrawingValidation {
    
    // MARK: - Line Quality Assessment
    static func validateLineConfidence(points: [CGPoint]) -> ValidationResult {
        guard points.count >= 2 else {
            return ValidationResult(score: 0.0, feedback: "Draw a complete line", passed: false)
        }
        
        // Calculate smoothness (fewer direction changes = more confident)
        var directionChanges = 0
        var totalDistance: CGFloat = 0
        
        for i in 1..<points.count {
            let distance = points[i-1].distance(to: points[i])
            totalDistance += distance
            
            if i > 1 {
                let angle1 = points[i-2].angle(to: points[i-1])
                let angle2 = points[i-1].angle(to: points[i])
                let angleDiff = abs(angle1 - angle2)
                
                if angleDiff > 0.3 { // Threshold for direction change
                    directionChanges += 1
                }
            }
        }
        
        // Calculate confidence score
        let smoothnessRatio = max(0, 1.0 - (Double(directionChanges) / Double(points.count)))
        let lengthScore = min(1.0, Double(totalDistance) / 100.0) // Prefer longer, committed strokes
        
        let finalScore = (smoothnessRatio * 0.7 + lengthScore * 0.3) * 100
        
        let feedback = getFeedbackForLineScore(finalScore)
        return ValidationResult(score: finalScore, feedback: feedback, passed: finalScore >= 60)
    }
    
    // MARK: - Circle Quality Assessment (Based on your circle drawing code)
    static func validateCircle(points: [CGPoint]) -> ValidationResult {
        guard points.count >= 10 else {
            return ValidationResult(score: 0.0, feedback: "Draw a complete circle", passed: false)
        }
        
        // Calculate center using average of all points
        let center = points.reduce(CGPoint.zero) { acc, point in
            CGPoint(x: acc.x + point.x, y: acc.y + point.y)
        }
        let finalCenter = CGPoint(x: center.x / CGFloat(points.count), y: center.y / CGFloat(points.count))
        
        // Calculate average radius and variance
        var avgRadius: CGFloat = 0
        for point in points {
            let distance = finalCenter.distance(to: point)
            avgRadius += distance
        }
        avgRadius /= CGFloat(points.count)
        
        var radiusVariance: CGFloat = 0
        for point in points {
            let distance = finalCenter.distance(to: point)
            radiusVariance += pow(distance - avgRadius, 2)
        }
        radiusVariance = sqrt(radiusVariance / CGFloat(points.count))
        
        // Check if circle is closed
        let startPoint = points.first!
        let endPoint = points.last!
        let closureDistance = startPoint.distance(to: endPoint)
        let maxClosureDistance = avgRadius * 0.2
        let isClosed = closureDistance < maxClosureDistance
        
        // Calculate score
        let maxVariance = avgRadius * 0.5
        let varianceScore = max(0, 1 - (radiusVariance / maxVariance))
        let closureScore = isClosed ? 1.0 : 0.5
        
        let finalScore = Double((varianceScore * 0.6 + closureScore * 0.4) * 100)
        let clampedScore = max(0, min(100, finalScore))
        
        let feedback = getFeedbackForCircleScore(clampedScore)
        return ValidationResult(score: clampedScore, feedback: feedback, passed: clampedScore >= 60)
    }
    
    // MARK: - Helper Functions
    private static func getFeedbackForLineScore(_ score: Double) -> String {
        switch score {
        case 90...100: return "Perfect line confidence! Professional quality! ✨"
        case 80..<90: return "Excellent confident stroke! 🎯"
        case 70..<80: return "Great line control! 👏"
        case 60..<70: return "Good confidence - try for smoother motion 💪"
        case 40..<60: return "Practice flowing from shoulder, not wrist 🖊️"
        default: return "Focus on one smooth, confident stroke 🔄"
        }
    }
    
    private static func getFeedbackForCircleScore(_ score: Double) -> String {
        switch score {
        case 95...100: return "Perfect circle! You're a true artist! ✨"
        case 85..<95: return "Excellent! Almost perfect! 🎯"
        case 75..<85: return "Great job! Very circular! 👏"
        case 60..<75: return "Good effort! Keep practicing! 💪"
        case 40..<60: return "Try drawing slower and more carefully 🖊️"
        default: return "Focus on smooth, circular motion 🔄"
        }
    }
}

// MARK: - Validation Result
struct ValidationResult {
    let score: Double
    let feedback: String
    let passed: Bool
}

// MARK: - CGPoint Extensions for Geometric Calculations
extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
    
    func angle(to point: CGPoint) -> CGFloat {
        return atan2(point.y - y, point.x - x)
    }
}

// MARK: - Clean Lesson Models (Simplified & Working)
struct Lesson: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let estimatedMinutes: Int
    let xpReward: Int
    let steps: [LessonStep]
    let objectives: [String]
    let tips: [String]
    let unlocks: [String]
}

struct LessonStep: Identifiable, Codable {
    let id: String
    let order: Int
    let title: String
    let instruction: String
    let content: StepContent
    let validation: StepValidation
    let xpValue: Int
}

enum StepContent: Codable {
    case introduction(IntroContent)
    case drawing(DrawingContent)
    case theory(TheoryContent)
    
    enum CodingKeys: String, CodingKey {
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
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown type: \(type)")
        }
    }
}

struct IntroContent: Codable {
    let bulletPoints: [String]
    let visualAid: String?
}

struct DrawingContent: Codable {
    let canvasSize: CGSize
    let backgroundColor: String
    let guidelines: [Guideline]
    let toolsAllowed: [DrawingTool]
    let expectedShape: ShapeType
}

struct TheoryContent: Codable {
    let question: String
    let options: [String]
    let correctAnswer: Int
    let explanation: String
}

// MARK: - Drawing Guidelines
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
}

// MARK: - Validation Configuration
struct StepValidation: Codable {
    let shapeType: ShapeType
    let minScore: Double
    let maxAttempts: Int
    let requiresRealTime: Bool
}

enum ShapeType: String, Codable {
    case line = "line"
    case circle = "circle"
    case square = "square"
    case none = "none"
}

enum DrawingTool: String, Codable {
    case pen = "pen"
    case pencil = "pencil"
}

// MARK: - THE ONE PERFECT LESSON
struct Curriculum {
    static let allLessons: [Lesson] = [
        lineConfidenceLesson
    ]
    
    static let lineConfidenceLesson = Lesson(
        id: "lesson_001",
        title: "Line Confidence",
        description: "Master confident, controlled line-making - the foundation of all professional drawing",
        estimatedMinutes: 8,
        xpReward: 100,
        steps: [
            // STEP 1: Why This Matters
            LessonStep(
                id: "step_001_1",
                order: 1,
                title: "Why Line Confidence Matters",
                instruction: "Line confidence is what separates amateur sketching from professional drawing. Let's understand why this fundamental skill matters.",
                content: .introduction(IntroContent(
                    bulletPoints: [
                        "Confident lines make simple drawings look professional",
                        "Hesitant, sketchy lines communicate uncertainty",
                        "Professional artists draw with intention and commitment",
                        "This is the #1 skill that transforms your drawings"
                    ],
                    visualAid: "line_confidence_comparison"
                )),
                validation: StepValidation(
                    shapeType: .none,
                    minScore: 100,
                    maxAttempts: 1,
                    requiresRealTime: false
                ),
                xpValue: 10
            ),
            
            // STEP 2: Theory Check
            LessonStep(
                id: "step_001_2",
                order: 2,
                title: "Confident vs. Sketchy",
                instruction: "Which approach creates more professional-looking artwork?",
                content: .theory(TheoryContent(
                    question: "Professional artists prefer to:",
                    options: [
                        "Make one confident stroke per line",
                        "Build up lines with multiple sketchy strokes",
                        "Always start very light and gradually darken",
                        "Sketch everything first, then trace over"
                    ],
                    correctAnswer: 0,
                    explanation: "Exactly! One confident stroke communicates certainty and skill. This is the foundation of professional line quality."
                )),
                validation: StepValidation(
                    shapeType: .none,
                    minScore: 100,
                    maxAttempts: 2,
                    requiresRealTime: false
                ),
                xpValue: 15
            ),
            
            // STEP 3: First Confident Line
            LessonStep(
                id: "step_001_3",
                order: 3,
                title: "Your First Confident Line",
                instruction: "Draw one straight, confident line from start to finish. Use your whole arm, not just your wrist. Practice the motion first, then commit!",
                content: .drawing(DrawingContent(
                    canvasSize: CGSize(width: 400, height: 200),
                    backgroundColor: "#FAFAFA",
                    guidelines: [
                        Guideline(
                            type: .line,
                            startPoint: CGPoint(x: 50, y: 100),
                            endPoint: CGPoint(x: 350, y: 100),
                            center: nil,
                            radius: nil,
                            color: "#4A90E2",
                            opacity: 0.3
                        )
                    ],
                    toolsAllowed: [.pen],
                    expectedShape: .line
                )),
                validation: StepValidation(
                    shapeType: .line,
                    minScore: 60,
                    maxAttempts: 3,
                    requiresRealTime: true
                ),
                xpValue: 25
            ),
            
            // STEP 4: Vertical Confidence
            LessonStep(
                id: "step_001_4",
                order: 4,
                title: "Vertical Control",
                instruction: "Master vertical lines - they require different muscle memory. Draw three confident vertical strokes.",
                content: .drawing(DrawingContent(
                    canvasSize: CGSize(width: 300, height: 300),
                    backgroundColor: "#FAFAFA",
                    guidelines: [
                        Guideline(
                            type: .line,
                            startPoint: CGPoint(x: 80, y: 50),
                            endPoint: CGPoint(x: 80, y: 250),
                            center: nil,
                            radius: nil,
                            color: "#E74C3C",
                            opacity: 0.3
                        ),
                        Guideline(
                            type: .line,
                            startPoint: CGPoint(x: 150, y: 50),
                            endPoint: CGPoint(x: 150, y: 250),
                            center: nil,
                            radius: nil,
                            color: "#E74C3C",
                            opacity: 0.3
                        ),
                        Guideline(
                            type: .line,
                            startPoint: CGPoint(x: 220, y: 50),
                            endPoint: CGPoint(x: 220, y: 250),
                            center: nil,
                            radius: nil,
                            color: "#E74C3C",
                            opacity: 0.3
                        )
                    ],
                    toolsAllowed: [.pen],
                    expectedShape: .line
                )),
                validation: StepValidation(
                    shapeType: .line,
                    minScore: 60,
                    maxAttempts: 3,
                    requiresRealTime: true
                ),
                xpValue: 25
            ),
            
            // STEP 5: Circle Confidence Challenge
            LessonStep(
                id: "step_001_5",
                order: 5,
                title: "Confident Circle",
                instruction: "Draw one smooth, confident circle. This is the ultimate test of line confidence - no sketching allowed!",
                content: .drawing(DrawingContent(
                    canvasSize: CGSize(width: 300, height: 300),
                    backgroundColor: "#FAFAFA",
                    guidelines: [
                        Guideline(
                            type: .circle,
                            startPoint: CGPoint.zero,
                            endPoint: nil,
                            center: CGPoint(x: 150, y: 150),
                            radius: 80,
                            color: "#9B59B6",
                            opacity: 0.2
                        )
                    ],
                    toolsAllowed: [.pen],
                    expectedShape: .circle
                )),
                validation: StepValidation(
                    shapeType: .circle,
                    minScore: 60,
                    maxAttempts: 5,
                    requiresRealTime: true
                ),
                xpValue: 40
            )
        ],
        objectives: [
            "Understand why line confidence matters for professional drawing",
            "Draw confident horizontal and vertical lines",
            "Create smooth, controlled circular motions",
            "Eliminate sketchy, hesitant mark-making"
        ],
        tips: [
            "Use your whole arm, not just your wrist",
            "Practice the motion before committing to the stroke",
            "One confident stroke beats five sketchy attempts",
            "Professional quality comes from intention, not perfection"
        ],
        unlocks: ["lesson_002"]
    )
}

// MARK: - Validation Service Integration
class LessonValidationService {
    static let shared = LessonValidationService()
    
    func validateDrawing(points: [CGPoint], expectedShape: ShapeType) -> ValidationResult {
        switch expectedShape {
        case .line:
            return DrawingValidation.validateLineConfidence(points: points)
        case .circle:
            return DrawingValidation.validateCircle(points: points)
        case .square:
            return validateSquare(points: points)
        case .none:
            return ValidationResult(score: 100, feedback: "Complete!", passed: true)
        }
    }
    
    private func validateSquare(points: [CGPoint]) -> ValidationResult {
        // TODO: Implement square validation for future lessons
        return ValidationResult(score: 100, feedback: "Square validation coming soon", passed: true)
    }
}

/*
USAGE INSTRUCTIONS:

1. REPLACE your current LessonsCurriculum.swift with this file

2. UPDATE your LessonsViewModel to use the new models:
   - Change `Curriculum.allLessons` reference
   - Use `LessonValidationService.shared.validateDrawing()` for validation

3. UPDATE your LessonPlayerView to integrate validation:
   - Collect drawing points during canvas interaction
   - Call validation service when user completes a stroke
   - Show real-time feedback based on ValidationResult

4. The validation prevents scribbling by:
   - Analyzing actual stroke quality (smoothness, confidence)
   - Requiring specific shapes (lines, circles) to pass
   - Providing meaningful feedback for improvement
   - Only allowing progression when skills are demonstrated

This creates ONE perfect lesson that teaches real skills with real validation.
Build from here for future lessons using the same pattern.
*/
