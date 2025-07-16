// MARK: - SURGICAL FIX: Replace LearningTreeCurriculum.swift completely
// File: ArtOfTheFuture/Features/Lessons/Data/LearningTreeCurriculum.swift
// This version ONLY references real lessons and adds NO duplicate extensions

import Foundation
import SwiftUI

struct LearningTreeCurriculum {
    
    // MARK: - Generate Complete Learning Tree
    static func generateLearningTree() -> LearningTree {
        return LearningTree(sections: [
            createFoundationSection(),
            createComingSoonSection()
        ])
    }
    
    // MARK: - Foundation Section (Using REAL Lessons Only)
    private static func createFoundationSection() -> LearningSection {
        let units = [
            // Unit 1: Your 5 working lessons
            LearningUnit(
                id: "unit_foundation_basics",
                sectionId: "section_foundation",
                order: 0,
                title: "Getting Started",
                description: "Master the fundamental drawing skills",
                iconName: "pencil.circle.fill",
                lessons: [
                    "lesson_001",  // Welcome to Drawing!
                    "lesson_002",  // Drawing Straight Lines
                    "lesson_003",  // Drawing Circles
                    "lesson_004",  // Drawing Squares
                    "lesson_005"   // Free Drawing Practice
                ]
            )
        ]
        
        return LearningSection(
            id: "section_foundation",
            title: "Foundation Skills",
            level: .beginner,
            order: 0,
            description: "Essential drawing skills every artist needs",
            iconName: "star.fill",
            units: units
        )
    }
    
    // MARK: - Coming Soon Section (For Future Content)
    private static func createComingSoonSection() -> LearningSection {
        return LearningSection(
            id: "section_coming_soon",
            title: "More Content Coming Soon",
            level: .intermediate,
            order: 1,
            description: "We're building amazing new lessons for you",
            iconName: "clock.fill",
            units: [] // Empty - shows as locked/coming soon
        )
    }
}
