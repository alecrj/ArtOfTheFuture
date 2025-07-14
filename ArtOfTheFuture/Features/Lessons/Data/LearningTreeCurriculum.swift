// MARK: - Learning Tree Curriculum
// File: ArtOfTheFuture/Features/Lessons/Data/LearningTreeCurriculum.swift

import Foundation
import SwiftUI

struct LearningTreeCurriculum {
    
    // MARK: - Generate Complete Learning Tree
    static func generateLearningTree() -> LearningTree {
        var sections: [LearningSection] = []
        
        // Create Beginner Section
        let beginnerUnits = createBeginnerUnits()
        let beginnerSection = LearningSection(
            id: "section_beginner",
            title: "Beginner Journey",
            level: .beginner,
            order: 0,
            description: "Master the fundamentals of digital art",
            iconName: "sparkles",
            units: beginnerUnits
        )
        sections.append(beginnerSection)
        
        // Create Intermediate Section
        let intermediateUnits = createIntermediateUnits()
        let intermediateSection = LearningSection(
            id: "section_intermediate",
            title: "Intermediate Skills",
            level: .intermediate,
            order: 1,
            description: "Build your artistic confidence",
            iconName: "star.fill",
            units: intermediateUnits
        )
        sections.append(intermediateSection)
        
        // Create Advanced Section
        let advancedUnits = createAdvancedUnits()
        let advancedSection = LearningSection(
            id: "section_advanced",
            title: "Advanced Mastery",
            level: .advanced,
            order: 2,
            description: "Perfect your craft",
            iconName: "crown.fill",
            units: advancedUnits
        )
        sections.append(advancedSection)
        
        return LearningTree(sections: sections)
    }
    
    // MARK: - Beginner Units
    private static func createBeginnerUnits() -> [LearningUnit] {
        return [
            // Use your 5 existing lessons in the first unit:
            LearningUnit(
                id: "unit_b1",
                sectionId: "section_beginner",
                order: 0,
                title: "Getting Started",
                description: "Your first steps in digital art",
                iconName: "hand.draw",
                lessons: Curriculum.allLessons.map { $0.id },  // ← existing 5 lessons
                isUnlocked: true
            ),
            LearningUnit(
                id: "unit_b2",
                sectionId: "section_beginner",
                order: 1,
                title: "Basic Shapes",
                description: "Master fundamental shapes",
                iconName: "square.circle",
                lessons: ["lesson_b2_1", "lesson_b2_2", "lesson_b2_3", "lesson_b2_4", "lesson_b2_5", "lesson_b2_6"]
            ),
            LearningUnit(
                id: "unit_b3",
                sectionId: "section_beginner",
                order: 2,
                title: "Lines & Curves",
                description: "Perfect your line work",
                iconName: "scribble",
                lessons: ["lesson_b3_1", "lesson_b3_2", "lesson_b3_3", "lesson_b3_4", "lesson_b3_5", "lesson_b3_6"]
            ),
            LearningUnit(
                id: "unit_b4",
                sectionId: "section_beginner",
                order: 3,
                title: "Basic Shading",
                description: "Add depth to your drawings",
                iconName: "circle.lefthalf.filled",
                lessons: ["lesson_b4_1", "lesson_b4_2", "lesson_b4_3", "lesson_b4_4", "lesson_b4_5", "lesson_b4_6"]
            ),
            LearningUnit(
                id: "unit_b5",
                sectionId: "section_beginner",
                order: 4,
                title: "Color Basics",
                description: "Introduction to color theory",
                iconName: "paintpalette",
                lessons: ["lesson_b5_1", "lesson_b5_2", "lesson_b5_3", "lesson_b5_4", "lesson_b5_5", "lesson_b5_6"]
            ),
            LearningUnit(
                id: "unit_b6",
                sectionId: "section_beginner",
                order: 5,
                title: "Composition",
                description: "Arrange elements effectively",
                iconName: "rectangle.split.3x3",
                lessons: ["lesson_b6_1", "lesson_b6_2", "lesson_b6_3", "lesson_b6_4", "lesson_b6_5", "lesson_b6_6"]
            ),
            LearningUnit(
                id: "unit_b7",
                sectionId: "section_beginner",
                order: 6,
                title: "First Projects",
                description: "Complete your first artworks",
                iconName: "photo",
                lessons: ["lesson_b7_1", "lesson_b7_2", "lesson_b7_3", "lesson_b7_4", "lesson_b7_5", "lesson_b7_6"]
            )
        ]
    }
    
    // MARK: - Intermediate Units
    private static func createIntermediateUnits() -> [LearningUnit] {
        return [
            LearningUnit(
                id: "unit_i1",
                sectionId: "section_intermediate",
                order: 0,
                title: "Perspective Basics",
                description: "Create depth in your art",
                iconName: "cube",
                lessons: ["lesson_i1_1", "lesson_i1_2", "lesson_i1_3", "lesson_i1_4", "lesson_i1_5", "lesson_i1_6"]
            ),
            LearningUnit(
                id: "unit_i2",
                sectionId: "section_intermediate",
                order: 1,
                title: "Advanced Shading",
                description: "Master light and shadow",
                iconName: "sun.max",
                lessons: ["lesson_i2_1", "lesson_i2_2", "lesson_i2_3", "lesson_i2_4", "lesson_i2_5", "lesson_i2_6"]
            ),
            LearningUnit(
                id: "unit_i3",
                sectionId: "section_intermediate",
                order: 2,
                title: "Anatomy Basics",
                description: "Draw the human form",
                iconName: "figure.stand",
                lessons: ["lesson_i3_1", "lesson_i3_2", "lesson_i3_3", "lesson_i3_4", "lesson_i3_5", "lesson_i3_6"]
            ),
            LearningUnit(
                id: "unit_i4",
                sectionId: "section_intermediate",
                order: 3,
                title: "Texture Techniques",
                description: "Add realistic textures",
                iconName: "square.texture",
                lessons: ["lesson_i4_1", "lesson_i4_2", "lesson_i4_3", "lesson_i4_4", "lesson_i4_5", "lesson_i4_6"]
            ),
            LearningUnit(
                id: "unit_i5",
                sectionId: "section_intermediate",
                order: 4,
                title: "Color Harmony",
                description: "Advanced color techniques",
                iconName: "paintbrush",
                lessons: ["lesson_i5_1", "lesson_i5_2", "lesson_i5_3", "lesson_i5_4", "lesson_i5_5", "lesson_i5_6"]
            ),
            LearningUnit(
                id: "unit_i6",
                sectionId: "section_intermediate",
                order: 5,
                title: "Digital Techniques",
                description: "Master digital tools",
                iconName: "wand.and.rays",
                lessons: ["lesson_i6_1", "lesson_i6_2", "lesson_i6_3", "lesson_i6_4", "lesson_i6_5", "lesson_i6_6"]
            ),
            LearningUnit(
                id: "unit_i7",
                sectionId: "section_intermediate",
                order: 6,
                title: "Style Development",
                description: "Find your artistic voice",
                iconName: "paintbrush.pointed",
                lessons: ["lesson_i7_1", "lesson_i7_2", "lesson_i7_3", "lesson_i7_4", "lesson_i7_5", "lesson_i7_6"]
            )
        ]
    }
    
    // MARK: - Advanced Units
    private static func createAdvancedUnits() -> [LearningUnit] {
        return [
            LearningUnit(
                id: "unit_a1",
                sectionId: "section_advanced",
                order: 0,
                title: "Complex Perspective",
                description: "Master advanced perspective",
                iconName: "perspective",
                lessons: ["lesson_a1_1", "lesson_a1_2", "lesson_a1_3", "lesson_a1_4", "lesson_a1_5", "lesson_a1_6"]
            ),
            LearningUnit(
                id: "unit_a2",
                sectionId: "section_advanced",
                order: 1,
                title: "Advanced Anatomy",
                description: "Dynamic figure drawing",
                iconName: "figure.run",
                lessons: ["lesson_a2_1", "lesson_a2_2", "lesson_a2_3", "lesson_a2_4", "lesson_a2_5", "lesson_a2_6"]
            ),
            LearningUnit(
                id: "unit_a3",
                sectionId: "section_advanced",
                order: 2,
                title: "Masterful Lighting",
                description: "Create dramatic lighting",
                iconName: "bolt.fill",
                lessons: ["lesson_a3_1", "lesson_a3_2", "lesson_a3_3", "lesson_a3_4", "lesson_a3_5", "lesson_a3_6"]
            ),
            LearningUnit(
                id: "unit_a4",
                sectionId: "section_advanced",
                order: 3,
                title: "Professional Rendering",
                description: "Industry-level techniques",
                iconName: "sparkle",
                lessons: ["lesson_a4_1", "lesson_a4_2", "lesson_a4_3", "lesson_a4_4", "lesson_a4_5", "lesson_a4_6"]
            ),
            LearningUnit(
                id: "unit_a5",
                sectionId: "section_advanced",
                order: 4,
                title: "Concept Art",
                description: "Professional concept creation",
                iconName: "brain",
                lessons: ["lesson_a5_1", "lesson_a5_2", "lesson_a5_3", "lesson_a5_4", "lesson_a5_5", "lesson_a5_6"]
            ),
            LearningUnit(
                id: "unit_a6",
                sectionId: "section_advanced",
                order: 5,
                title: "Portfolio Building",
                description: "Create professional work",
                iconName: "folder.fill",
                lessons: ["lesson_a6_1", "lesson_a6_2", "lesson_a6_3", "lesson_a6_4", "lesson_a6_5", "lesson_a6_6"]
            ),
            LearningUnit(
                id: "unit_a7",
                sectionId: "section_advanced",
                order: 6,
                title: "Artistic Mastery",
                description: "Your signature style",
                iconName: "star.circle.fill",
                lessons: ["lesson_a7_1", "lesson_a7_2", "lesson_a7_3", "lesson_a7_4", "lesson_a7_5", "lesson_a7_6"]
            )
        ]
    }
}
