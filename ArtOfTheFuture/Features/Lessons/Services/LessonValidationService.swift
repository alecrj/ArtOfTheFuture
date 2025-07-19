// MARK: - LessonValidationService.swift - CLEAN VERSION
// File Path: ArtOfTheFuture/Features/Lessons/Services/LessonValidationService.swift
// REPLACE ENTIRE FILE WITH THIS

import Foundation
import SwiftUI

// MARK: - Validation Result (UNIQUE NAME)
struct LessonValidationResult {
    let score: Double
    let feedback: String
    let passed: Bool
}

// MARK: - Drawing Validation Logic (UNIQUE NAME)
struct LessonDrawingValidation {
    
    // MARK: - Line Quality Assessment
    static func validateLineConfidence(points: [CGPoint]) -> LessonValidationResult {
        guard points.count >= 2 else {
            return LessonValidationResult(score: 0.0, feedback: "Draw a complete line", passed: false)
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
        return LessonValidationResult(score: finalScore, feedback: feedback, passed: finalScore >= 60)
    }
    
    // MARK: - Circle Quality Assessment
    static func validateCircle(points: [CGPoint]) -> LessonValidationResult {
        guard points.count >= 10 else {
            return LessonValidationResult(score: 0.0, feedback: "Draw a complete circle", passed: false)
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
        return LessonValidationResult(score: clampedScore, feedback: feedback, passed: clampedScore >= 60)
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

// MARK: - CGPoint Extensions for Geometric Calculations (UNIQUE NAMES)
extension CGPoint {
    func distanceToPoint(_ point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
    
    func angleToPoint(_ point: CGPoint) -> CGFloat {
        return atan2(point.y - y, point.x - x)
    }
    
    // Use existing distance and angle methods if they exist, otherwise use these
    func distance(to point: CGPoint) -> CGFloat {
        return distanceToPoint(point)
    }
    
    func angle(to point: CGPoint) -> CGFloat {
        return angleToPoint(point)
    }
}

// MARK: - Main Validation Service (UNIQUE NAME)
class ArtLessonValidationService {
    static let shared = ArtLessonValidationService()
    
    private init() {}
    
    func validateDrawing(points: [CGPoint], expectedShape: ShapeType) -> LessonValidationResult {
        switch expectedShape {
        case .line:
            return LessonDrawingValidation.validateLineConfidence(points: points)
        case .circle:
            return LessonDrawingValidation.validateCircle(points: points)
        case .square:
            return validateSquare(points: points)
        case .none:
            return LessonValidationResult(score: 100, feedback: "Complete!", passed: true)
        }
    }
    
    private func validateSquare(points: [CGPoint]) -> LessonValidationResult {
        // TODO: Implement square validation for future lessons
        return LessonValidationResult(score: 100, feedback: "Square validation coming soon", passed: true)
    }
}

// MARK: - Compatibility Alias
typealias LessonValidationService = ArtLessonValidationService
typealias ValidationResult = LessonValidationResult
