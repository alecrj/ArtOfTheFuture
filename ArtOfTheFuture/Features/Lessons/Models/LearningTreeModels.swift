// MARK: - Learning Tree Models
// File: ArtOfTheFuture/Features/Lessons/Models/LearningTreeModels.swift

import Foundation
import SwiftUI

// MARK: - Section Model
struct LearningSection: Identifiable, Codable {
    let id: String
    let title: String
    let level: DifficultyLevel
    let order: Int
    let description: String
    let iconName: String
    let units: [LearningUnit]
    
    // Computed properties
    var totalLessons: Int {
        units.reduce(0) { $0 + $1.lessons.count }
    }
    
    var completedLessons: Int {
        units.reduce(0) { $0 + $1.completedLessons }
    }
    
    var progress: Double {
        guard totalLessons > 0 else { return 0 }
        return Double(completedLessons) / Double(totalLessons)
    }
    
    var isUnlocked: Bool {
        order == 0 || units.first?.isUnlocked ?? false
    }
    
    var color: Color {
        switch level {
        case .beginner: return .green
        case .intermediate: return .blue
        case .advanced: return .purple
        }
    }
}

// MARK: - Unit Model
struct LearningUnit: Identifiable, Codable {
    let id: String
    let sectionId: String
    let order: Int
    let title: String
    let description: String
    let iconName: String
    let lessons: [String] // Lesson IDs
    
    // Progress tracking
    var completedLessonIds: Set<String> = []
    var isUnlocked: Bool = false
    
    // Computed properties
    var completedLessons: Int {
        completedLessonIds.count
    }
    
    var progress: Double {
        guard !lessons.isEmpty else { return 0 }
        return Double(completedLessons) / Double(lessons.count)
    }
    
    var isCompleted: Bool {
        completedLessons == lessons.count
    }
}

// MARK: - Learning Tree
struct LearningTree: Codable {
    let sections: [LearningSection]
    
    // Computed properties
    var totalLessons: Int {
        sections.reduce(0) { $0 + $1.totalLessons }
    }
    
    var completedLessons: Int {
        sections.reduce(0) { $0 + $1.completedLessons }
    }
    
    var overallProgress: Double {
        guard totalLessons > 0 else { return 0 }
        return Double(completedLessons) / Double(totalLessons)
    }
    
    // Helper methods
    func getSection(for lessonId: String) -> LearningSection? {
        sections.first { section in
            section.units.contains { unit in
                unit.lessons.contains(lessonId)
            }
        }
    }
    
    func getUnit(for lessonId: String) -> LearningUnit? {
        for section in sections {
            if let unit = section.units.first(where: { $0.lessons.contains(lessonId) }) {
                return unit
            }
        }
        return nil
    }
}

// MARK: - Tree Node (for visualization)
struct TreeNode: Identifiable {
    let id = UUID()
    let type: NodeType
    let title: String
    let subtitle: String?
    let progress: Double
    let isUnlocked: Bool
    let isCompleted: Bool
    let color: Color
    let children: [TreeNode]
    
    enum NodeType {
        case section
        case unit
        case lesson
    }
}
