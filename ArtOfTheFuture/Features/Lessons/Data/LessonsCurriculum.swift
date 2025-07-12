// MARK: - Curriculum (Duolingo-Style Learning Path)
// File: ArtOfTheFuture/Features/Lessons/Data/LessonCurriculum.swift

import Foundation
import SwiftUI

struct Curriculum {
    
    // MARK: - Complete Learning Path (3 Sections)
    static let allSections: [Section] = [
        beginnerSection,
        intermediateSection,
        advancedSection
    ]
    
    // MARK: - Section 1: Beginner - "Foundations of Drawing"
    static let beginnerSection = Section(
        id: "section_beginner",
        title: "Foundations of Drawing",
        description: "Master the fundamentals of digital art and drawing. Perfect for complete beginners.",
        order: 1,
        difficulty: .beginner,
        estimatedHours: 8,
        xpReward: 500,
        iconName: "pencil.circle.fill",
        colorTheme: "blue",
        backgroundGradient: ["#4A90E2", "#7BB3F0"],
        units: [
            // Unit 1: Getting Started
            Unit(
                id: "unit_beginner_1",
                title: "Getting Started",
                description: "Learn the basics of digital drawing tools and make your first strokes",
                order: 1,
                sectionId: "section_beginner",
                estimatedMinutes: 45,
                xpReward: 75,
                iconName: "hand.point.up.fill",
                colorHex: "#4A90E2",
                lessonIds: ["lesson_001"], // Using existing lesson
                prerequisites: [],
                unlocks: ["unit_beginner_2"],
                objectives: [
                    "Master basic digital drawing tools",
                    "Learn proper Apple Pencil technique",
                    "Create confident line strokes"
                ],
                skills: [
                    UnitSkill(id: "skill_tools", name: "Digital Tools", description: "Using drawing interface", iconName: "ipad.and.apple.pencil", category: .basics),
                    UnitSkill(id: "skill_lines", name: "Line Control", description: "Drawing clean lines", iconName: "scribble", category: .basics)
                ],
                challengeType: UnitChallengeType.drawing,
                finalChallenge: UnitChallenge(
                    id: "challenge_basic_lines",
                    title: "Line Mastery Challenge",
                    description: "Draw a simple line art composition using only straight and curved lines",
                    type: UnitChallengeType.drawing,
                    instructions: [
                        "Create a simple house using only lines",
                        "Include at least 5 straight lines",
                        "Add 3 curved elements (like a sun or clouds)",
                        "Focus on line confidence and control"
                    ],
                    timeLimit: 10,
                    xpReward: 100,
                    requirements: [
                        ChallengeRequirement(id: "req1", description: "Use confident strokes", isRequired: true, points: 25),
                        ChallengeRequirement(id: "req2", description: "Include straight and curved lines", isRequired: true, points: 50),
                        ChallengeRequirement(id: "req3", description: "Complete within time limit", isRequired: false, points: 25)
                    ]
                )
            ),
            
            // Unit 2: Basic Shapes
            Unit(
                id: "unit_beginner_2",
                title: "Basic Shapes & Forms",
                description: "Master circles, squares, triangles and turn them into 3D forms",
                order: 2,
                sectionId: "section_beginner",
                estimatedMinutes: 60,
                xpReward: 100,
                iconName: "square.circle",
                colorHex: "#5BA0F2",
                lessonIds: ["lesson_002", "lesson_003"], // Using existing lessons
                prerequisites: ["unit_beginner_1"],
                unlocks: ["unit_beginner_3"],
                objectives: [
                    "Draw perfect circles and squares",
                    "Understand shape proportions",
                    "Create 3D forms from 2D shapes"
                ],
                skills: [
                    UnitSkill(id: "skill_circles", name: "Circle Drawing", description: "Perfect round shapes", iconName: "circle", category: .basics),
                    UnitSkill(id: "skill_squares", name: "Square Drawing", description: "Clean geometric forms", iconName: "square", category: .basics),
                    UnitSkill(id: "skill_3d_forms", name: "3D Forms", description: "Volume and dimension", iconName: "cube", category: .perspective)
                ],
                challengeType: UnitChallengeType.creative,
                finalChallenge: UnitChallenge(
                    id: "challenge_shape_creature",
                    title: "Shape Creature Challenge",
                    description: "Create a character or creature using only basic geometric shapes",
                    type: UnitChallengeType.creative,
                    instructions: [
                        "Design a simple character using circles, squares, and triangles",
                        "Use at least 3 different shapes",
                        "Make some shapes overlap for depth",
                        "Add personality through shape arrangement"
                    ],
                    timeLimit: 15,
                    xpReward: 125,
                    requirements: [
                        ChallengeRequirement(id: "req1", description: "Use 3+ different shapes", isRequired: true, points: 40),
                        ChallengeRequirement(id: "req2", description: "Create recognizable character", isRequired: true, points: 40),
                        ChallengeRequirement(id: "req3", description: "Show creativity in design", isRequired: false, points: 20)
                    ]
                )
            ),
            
            // Unit 3: Perspective Basics
            Unit(
                id: "unit_beginner_3",
                title: "Perspective Basics",
                description: "Learn one-point perspective and give your drawings depth",
                order: 3,
                sectionId: "section_beginner",
                estimatedMinutes: 75,
                xpReward: 125,
                iconName: "view.3d",
                colorHex: "#6BB0F4",
                lessonIds: ["lesson_004"], // Using existing lesson
                prerequisites: ["unit_beginner_2"],
                unlocks: ["unit_beginner_4"],
                objectives: [
                    "Understand one-point perspective",
                    "Create depth in drawings",
                    "Draw 3D cubes and cylinders"
                ],
                skills: [
                    UnitSkill(id: "skill_perspective", name: "One-Point Perspective", description: "Basic 3D drawing", iconName: "arrow.forward.to.line", category: .perspective),
                    UnitSkill(id: "skill_depth", name: "Depth Creation", description: "Making drawings 3D", iconName: "square.stack.3d.down.right", category: .perspective)
                ],
                challengeType: UnitChallengeType.technical,
                finalChallenge: UnitChallenge(
                    id: "challenge_perspective_room",
                    title: "3D Room Challenge",
                    description: "Draw a simple room interior using one-point perspective",
                    type: UnitChallengeType.technical,
                    instructions: [
                        "Set up a horizon line and vanishing point",
                        "Draw a room with back wall, floor, and ceiling",
                        "Add at least 2 objects (cube, cylinder) in the room",
                        "Show proper perspective recession"
                    ],
                    timeLimit: 20,
                    xpReward: 150,
                    requirements: [
                        ChallengeRequirement(id: "req1", description: "Correct vanishing point", isRequired: true, points: 50),
                        ChallengeRequirement(id: "req2", description: "Add 3D objects", isRequired: true, points: 30),
                        ChallengeRequirement(id: "req3", description: "Clean perspective lines", isRequired: false, points: 20)
                    ]
                )
            ),
            
            // Unit 4: Light & Shadow
            Unit(
                id: "unit_beginner_4",
                title: "Light & Shadow Fundamentals",
                description: "Add dimension with shading and understand how light works",
                order: 4,
                sectionId: "section_beginner",
                estimatedMinutes: 90,
                xpReward: 150,
                iconName: "sun.max.fill",
                colorHex: "#7BC0F6",
                lessonIds: [], // Will need new lessons
                prerequisites: ["unit_beginner_3"],
                unlocks: ["unit_beginner_5"],
                objectives: [
                    "Understand light direction",
                    "Create realistic shadows",
                    "Shade basic 3D forms"
                ],
                skills: [
                    UnitSkill(id: "skill_shading", name: "Basic Shading", description: "Light and shadow", iconName: "circle.lefthalf.filled", category: .shading),
                    UnitSkill(id: "skill_lighting", name: "Light Direction", description: "Understanding light sources", iconName: "lightbulb.fill", category: .shading)
                ],
                challengeType: UnitChallengeType.drawing,
                finalChallenge: nil // Will be added when lessons are created
            ),
            
            // Unit 5: Proportions & Composition
            Unit(
                id: "unit_beginner_5",
                title: "Proportions & Composition",
                description: "Learn to size objects correctly and arrange pleasing compositions",
                order: 5,
                sectionId: "section_beginner",
                estimatedMinutes: 75,
                xpReward: 125,
                iconName: "rectangle.3.group",
                colorHex: "#8BD0F8",
                lessonIds: [], // Will need new lessons
                prerequisites: ["unit_beginner_4"],
                unlocks: ["unit_beginner_6"],
                objectives: [
                    "Master object proportions",
                    "Create balanced compositions",
                    "Use rule of thirds"
                ],
                skills: [
                    UnitSkill(id: "skill_proportions", name: "Proportions", description: "Sizing objects correctly", iconName: "ruler", category: .drawing),
                    UnitSkill(id: "skill_composition", name: "Composition", description: "Arranging elements", iconName: "square.grid.3x3", category: .theory)
                ],
                challengeType: UnitChallengeType.creative,
                finalChallenge: nil
            ),
            
            // Unit 6: Drawing from Observation
            Unit(
                id: "unit_beginner_6",
                title: "Drawing from Observation",
                description: "Learn to see and draw real objects and references",
                order: 6,
                sectionId: "section_beginner",
                estimatedMinutes: 90,
                xpReward: 150,
                iconName: "eye.fill",
                colorHex: "#9BE0FA",
                lessonIds: [], // Will need new lessons
                prerequisites: ["unit_beginner_5"],
                unlocks: ["unit_beginner_7"],
                objectives: [
                    "Observe shapes in objects",
                    "Draw from photo references",
                    "Simplify complex forms"
                ],
                skills: [
                    UnitSkill(id: "skill_observation", name: "Observation", description: "Seeing like an artist", iconName: "eye", category: .theory),
                    UnitSkill(id: "skill_reference", name: "Reference Drawing", description: "Drawing from photos", iconName: "photo", category: .drawing)
                ],
                challengeType: UnitChallengeType.drawing,
                finalChallenge: nil
            ),
            
            // Unit 7: Beginner Portfolio Project
            Unit(
                id: "unit_beginner_7",
                title: "Your First Masterpiece",
                description: "Create a complete artwork using all beginner skills",
                order: 7,
                sectionId: "section_beginner",
                estimatedMinutes: 120,
                xpReward: 200,
                iconName: "star.circle.fill",
                colorHex: "#ABF0FC",
                lessonIds: ["lesson_005"], // Using existing creative challenge
                prerequisites: ["unit_beginner_6"],
                unlocks: [], // Unlocks intermediate section
                objectives: [
                    "Combine all learned skills",
                    "Create a complete scene",
                    "Show artistic growth"
                ],
                skills: [
                    UnitSkill(id: "skill_integration", name: "Skill Integration", description: "Combining techniques", iconName: "link", category: .advanced),
                    UnitSkill(id: "skill_creativity", name: "Creative Expression", description: "Personal artistic voice", iconName: "paintbrush.pointed", category: .advanced)
                ],
                challengeType: UnitChallengeType.portfolio,
                finalChallenge: UnitChallenge(
                    id: "challenge_first_masterpiece",
                    title: "Section 1 Final Masterpiece",
                    description: "Create your first complete artwork showcasing all beginner skills",
                    type: UnitChallengeType.portfolio,
                    instructions: [
                        "Plan a simple scene (indoor or outdoor)",
                        "Use perspective to show depth",
                        "Include basic shapes and forms",
                        "Add shading and lighting",
                        "Show proper proportions"
                    ],
                    timeLimit: 45,
                    xpReward: 300,
                    requirements: [
                        ChallengeRequirement(id: "req1", description: "Use perspective", isRequired: true, points: 30),
                        ChallengeRequirement(id: "req2", description: "Include shading", isRequired: true, points: 30),
                        ChallengeRequirement(id: "req3", description: "Show creativity", isRequired: true, points: 20),
                        ChallengeRequirement(id: "req4", description: "Complete composition", isRequired: false, points: 20)
                    ]
                )
            )
        ],
        prerequisites: [],
        unlocks: ["section_intermediate"],
        objectives: [
            "Master digital drawing fundamentals",
            "Understand basic perspective and 3D forms",
            "Learn essential shading techniques",
            "Create your first complete artwork"
        ],
        skills: [
            "Digital tool mastery",
            "Line confidence",
            "Basic shapes and forms",
            "One-point perspective",
            "Fundamental shading",
            "Basic composition"
        ],
        finalProject: "Create a complete scene demonstrating all fundamental drawing skills"
    )
    
    // MARK: - Section 2: Intermediate - "Expanding Artistic Skills"
    static let intermediateSection = Section(
        id: "section_intermediate",
        title: "Expanding Artistic Skills",
        description: "Build on fundamentals with advanced techniques, color, and complex subjects",
        order: 2,
        difficulty: .intermediate,
        estimatedHours: 15,
        xpReward: 1000,
        iconName: "paintpalette.fill",
        colorTheme: "green",
        backgroundGradient: ["#50C878", "#7FD99A"],
        units: [], // Will be populated with intermediate units
        prerequisites: ["section_beginner"],
        unlocks: ["section_advanced"],
        objectives: [
            "Master complex perspective techniques",
            "Learn color theory and application",
            "Draw human figures and faces",
            "Create sophisticated compositions"
        ],
        skills: [
            "Two-point perspective",
            "Color theory mastery",
            "Human anatomy basics",
            "Advanced shading",
            "Complex composition",
            "Digital painting techniques"
        ],
        finalProject: "Create a character illustration with detailed background"
    )
    
    // MARK: - Section 3: Advanced - "Mastery and Creative Expression"
    static let advancedSection = Section(
        id: "section_advanced",
        title: "Mastery and Creative Expression",
        description: "Develop your unique artistic style and create professional-level artwork",
        order: 3,
        difficulty: .advanced,
        estimatedHours: 25,
        xpReward: 2000,
        iconName: "crown.fill",
        colorTheme: "purple",
        backgroundGradient: ["#9B59B6", "#BB7BD6"],
        units: [], // Will be populated with advanced units
        prerequisites: ["section_intermediate"],
        unlocks: [],
        objectives: [
            "Develop personal artistic style",
            "Master advanced rendering techniques",
            "Create portfolio-quality artwork",
            "Understand professional workflows"
        ],
        skills: [
            "Style development",
            "Advanced lighting",
            "Complex perspective",
            "Professional workflows",
            "Digital painting mastery",
            "Artistic storytelling"
        ],
        finalProject: "Create a professional portfolio piece showcasing your unique artistic voice"
    )
}

// MARK: - Curriculum Utilities
extension Curriculum {
    
    // Get all units from all sections
    static var allUnits: [Unit] {
        return allSections.flatMap { $0.units }
    }
    
    // Get total learning path statistics
    static var pathStatistics: (sections: Int, units: Int, lessons: Int, estimatedHours: Int) {
        let totalSections = allSections.count
        let totalUnits = allUnits.count
        let totalLessons = allSections.reduce(0) { $0 + $1.totalLessons }
        let totalHours = allSections.reduce(0) { $0 + $1.estimatedHours }
        
        return (totalSections, totalUnits, totalLessons, totalHours)
    }
    
    // Get learning path for specific difficulty
    static func getPathForDifficulty(_ difficulty: DifficultyLevel) -> [Section] {
        return allSections.filter { $0.difficulty == difficulty }
    }
    
    // Find section containing unit
    static func getSectionForUnit(_ unitId: String) -> Section? {
        return allSections.first { section in
            section.units.contains { $0.id == unitId }
        }
    }
}
// MARK: - Curriculum Extension for LessonsCurriculum.swift
// ADD this to the END of your existing LessonsCurriculum.swift file

