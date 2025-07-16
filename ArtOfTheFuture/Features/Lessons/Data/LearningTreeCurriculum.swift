// MARK: - Learning Tree Curriculum - Professional 3×8×6 Structure
// File: ArtOfTheFuture/Features/Lessons/Data/LearningTreeCurriculum.swift
// FAANG-Quality Learning Architecture

import Foundation
import SwiftUI

struct LearningTreeCurriculum {
    
    // MARK: - Generate Complete Learning Tree (3 Sections × 8 Units × 6 Lessons = 144 Total)
    static func generateLearningTree() -> LearningTree {
        return LearningTree(sections: [
            createBeginnerSection(),
            createIntermediateSection(),
            createAdvancedSection()
        ])
    }
    
    // MARK: - BEGINNER SECTION (8 Units × 6 Lessons = 48 Lessons)
    private static func createBeginnerSection() -> LearningSection {
        let units = [
            // Unit 1: Foundation Skills (YOUR 5 WORKING LESSONS + 1 placeholder)
            LearningUnit(
                id: "unit_beginner_01",
                sectionId: "section_beginner",
                order: 0,
                title: "First Steps",
                description: "Master the fundamental drawing basics",
                iconName: "pencil.circle.fill",
                lessons: [
                    "lesson_001",  // Welcome to Drawing! (WORKING)
                    "lesson_002",  // Drawing Straight Lines (WORKING)
                    "lesson_003",  // Drawing Circles (WORKING)
                    "lesson_004",  // Drawing Squares (WORKING)
                    "lesson_005",  // Creative Challenge (WORKING)
                    "lesson_006"   // PLACEHOLDER: Basic Shapes Practice
                ]
            ),
            
            // Unit 2: Shape Mastery (ALL PLACEHOLDERS)
            LearningUnit(
                id: "unit_beginner_02",
                sectionId: "section_beginner",
                order: 1,
                title: "Shape Mastery",
                description: "Perfect your geometric shape drawing",
                iconName: "square.circle",
                lessons: [
                    "lesson_007",  // PLACEHOLDER: Triangle Fundamentals
                    "lesson_008",  // PLACEHOLDER: Oval Construction
                    "lesson_009",  // PLACEHOLDER: Rectangle Variations
                    "lesson_010",  // PLACEHOLDER: Diamond Shapes
                    "lesson_011",  // PLACEHOLDER: Star Construction
                    "lesson_012"   // PLACEHOLDER: Shape Combinations
                ]
            ),
            
            // Unit 3: Line Control (ALL PLACEHOLDERS)
            LearningUnit(
                id: "unit_beginner_03",
                sectionId: "section_beginner",
                order: 2,
                title: "Line Control",
                description: "Develop precise line drawing skills",
                iconName: "scribble",
                lessons: [
                    "lesson_013",  // PLACEHOLDER: Curved Lines
                    "lesson_014",  // PLACEHOLDER: Parallel Lines
                    "lesson_015",  // PLACEHOLDER: Perpendicular Lines
                    "lesson_016",  // PLACEHOLDER: Diagonal Lines
                    "lesson_017",  // PLACEHOLDER: Wavy Lines
                    "lesson_018"   // PLACEHOLDER: Line Weight Control
                ]
            ),
            
            // Unit 4: Basic Forms (ALL PLACEHOLDERS)
            LearningUnit(
                id: "unit_beginner_04",
                sectionId: "section_beginner",
                order: 3,
                title: "Basic Forms",
                description: "Transform shapes into 3D forms",
                iconName: "cube",
                lessons: [
                    "lesson_019",  // PLACEHOLDER: Cubes and Boxes
                    "lesson_020",  // PLACEHOLDER: Cylinders
                    "lesson_021",  // PLACEHOLDER: Spheres
                    "lesson_022",  // PLACEHOLDER: Cones
                    "lesson_023",  // PLACEHOLDER: Pyramids
                    "lesson_024"   // PLACEHOLDER: Form Combinations
                ]
            ),
            
            // Unit 5: Simple Objects (ALL PLACEHOLDERS)
            LearningUnit(
                id: "unit_beginner_05",
                sectionId: "section_beginner",
                order: 4,
                title: "Simple Objects",
                description: "Draw everyday objects with confidence",
                iconName: "house",
                lessons: [
                    "lesson_025",  // PLACEHOLDER: Basic House
                    "lesson_026",  // PLACEHOLDER: Simple Car
                    "lesson_027",  // PLACEHOLDER: Tree Basics
                    "lesson_028",  // PLACEHOLDER: Sun and Clouds
                    "lesson_029",  // PLACEHOLDER: Simple Flowers
                    "lesson_030"   // PLACEHOLDER: Basic Animals
                ]
            ),
            
            // Unit 6: Proportions (ALL PLACEHOLDERS)
            LearningUnit(
                id: "unit_beginner_06",
                sectionId: "section_beginner",
                order: 5,
                title: "Proportions",
                description: "Learn proper proportional relationships",
                iconName: "ruler",
                lessons: [
                    "lesson_031",  // PLACEHOLDER: Basic Measuring
                    "lesson_032",  // PLACEHOLDER: Head Proportions
                    "lesson_033",  // PLACEHOLDER: Body Proportions
                    "lesson_034",  // PLACEHOLDER: Object Scale
                    "lesson_035",  // PLACEHOLDER: Comparative Sizing
                    "lesson_036"   // PLACEHOLDER: Proportion Practice
                ]
            ),
            
            // Unit 7: Basic Shading (ALL PLACEHOLDERS)
            LearningUnit(
                id: "unit_beginner_07",
                sectionId: "section_beginner",
                order: 6,
                title: "Basic Shading",
                description: "Add depth with light and shadow",
                iconName: "circle.lefthalf.filled",
                lessons: [
                    "lesson_037",  // PLACEHOLDER: Light Source Basics
                    "lesson_038",  // PLACEHOLDER: Cast Shadows
                    "lesson_039",  // PLACEHOLDER: Form Shadows
                    "lesson_040",  // PLACEHOLDER: Gradients
                    "lesson_041",  // PLACEHOLDER: Highlights
                    "lesson_042"   // PLACEHOLDER: Shading Practice
                ]
            ),
            
            // Unit 8: First Projects (ALL PLACEHOLDERS)
            LearningUnit(
                id: "unit_beginner_08",
                sectionId: "section_beginner",
                order: 7,
                title: "First Projects",
                description: "Apply everything you've learned",
                iconName: "star.fill",
                lessons: [
                    "lesson_043",  // PLACEHOLDER: Still Life Setup
                    "lesson_044",  // PLACEHOLDER: Simple Portrait
                    "lesson_045",  // PLACEHOLDER: Landscape Basics
                    "lesson_046",  // PLACEHOLDER: Character Design
                    "lesson_047",  // PLACEHOLDER: Creative Project
                    "lesson_048"   // PLACEHOLDER: Portfolio Review
                ]
            )
        ]
        
        return LearningSection(
            id: "section_beginner",
            title: "Beginner",
            level: .beginner,
            order: 0,
            description: "Essential drawing fundamentals for new artists",
            iconName: "star.fill",
            units: units
        )
    }
    
    // MARK: - INTERMEDIATE SECTION (8 Units × 6 Lessons = 48 Lessons)
    private static func createIntermediateSection() -> LearningSection {
        let units = [
            // Unit 1: Advanced Shapes (ALL PLACEHOLDERS)
            LearningUnit(
                id: "unit_intermediate_01",
                sectionId: "section_intermediate",
                order: 0,
                title: "Advanced Shapes",
                description: "Complex geometric constructions",
                iconName: "hexagon",
                lessons: [
                    "lesson_049",  // PLACEHOLDER: Pentagon Construction
                    "lesson_050",  // PLACEHOLDER: Hexagon Drawing
                    "lesson_051",  // PLACEHOLDER: Octagon Techniques
                    "lesson_052",  // PLACEHOLDER: Ellipse Mastery
                    "lesson_053",  // PLACEHOLDER: Complex Curves
                    "lesson_054"   // PLACEHOLDER: Shape Intersections
                ]
            ),
            
            // Unit 2: Perspective Basics (ALL PLACEHOLDERS)
            LearningUnit(
                id: "unit_intermediate_02",
                sectionId: "section_intermediate",
                order: 1,
                title: "Perspective Basics",
                description: "Create depth with perspective drawing",
                iconName: "triangle",
                lessons: [
                    "lesson_055",  // PLACEHOLDER: One-Point Perspective
                    "lesson_056",  // PLACEHOLDER: Two-Point Perspective
                    "lesson_057",  // PLACEHOLDER: Horizon Line
                    "lesson_058",  // PLACEHOLDER: Vanishing Points
                    "lesson_059",  // PLACEHOLDER: Perspective Grid
                    "lesson_060"   // PLACEHOLDER: Object Placement
                ]
            ),
            
            // Unit 3: Advanced Shading (ALL PLACEHOLDERS)
            LearningUnit(
                id: "unit_intermediate_03",
                sectionId: "section_intermediate",
                order: 2,
                title: "Advanced Shading",
                description: "Master light, shadow, and texture",
                iconName: "sun.max",
                lessons: [
                    "lesson_061",  // PLACEHOLDER: Multiple Light Sources
                    "lesson_062",  // PLACEHOLDER: Reflected Light
                    "lesson_063",  // PLACEHOLDER: Ambient Occlusion
                    "lesson_064",  // PLACEHOLDER: Texture Rendering
                    "lesson_065",  // PLACEHOLDER: Material Studies
                    "lesson_066"   // PLACEHOLDER: Atmospheric Perspective
                ]
            ),
            
            // Unit 4: Human Figure (ALL PLACEHOLDERS)
            LearningUnit(
                id: "unit_intermediate_04",
                sectionId: "section_intermediate",
                order: 3,
                title: "Human Figure",
                description: "Draw the human form with accuracy",
                iconName: "figure.stand",
                lessons: [
                    "lesson_067",  // PLACEHOLDER: Basic Anatomy
                    "lesson_068",  // PLACEHOLDER: Gesture Drawing
                    "lesson_069",  // PLACEHOLDER: Head Construction
                    "lesson_070",  // PLACEHOLDER: Facial Features
                    "lesson_071",  // PLACEHOLDER: Hand Studies
                    "lesson_072"   // PLACEHOLDER: Foot Studies
                ]
            ),
            
            // Unit 5: Animals (ALL PLACEHOLDERS)
            LearningUnit(
                id: "unit_intermediate_05",
                sectionId: "section_intermediate",
                order: 4,
                title: "Animals",
                description: "Capture animal forms and movement",
                iconName: "pawprint",
                lessons: [
                    "lesson_073",  // PLACEHOLDER: Animal Anatomy
                    "lesson_074",  // PLACEHOLDER: Quadruped Structure
                    "lesson_075",  // PLACEHOLDER: Birds in Flight
                    "lesson_076",  // PLACEHOLDER: Fish and Marine Life
                    "lesson_077",  // PLACEHOLDER: Animal Textures
                    "lesson_078"   // PLACEHOLDER: Animal Expressions
                ]
            ),
            
            // Unit 6: Environments (ALL PLACEHOLDERS)
            LearningUnit(
                id: "unit_intermediate_06",
                sectionId: "section_intermediate",
                order: 5,
                title: "Environments",
                description: "Create believable spaces and scenes",
                iconName: "mountain.2",
                lessons: [
                    "lesson_079",  // PLACEHOLDER: Interior Spaces
                    "lesson_080",  // PLACEHOLDER: Exterior Architecture
                    "lesson_081",  // PLACEHOLDER: Natural Landscapes
                    "lesson_082",  // PLACEHOLDER: Urban Scenes
                    "lesson_083",  // PLACEHOLDER: Weather Effects
                    "lesson_084"   // PLACEHOLDER: Time of Day
                ]
            ),
            
            // Unit 7: Color Theory (ALL PLACEHOLDERS)
            LearningUnit(
                id: "unit_intermediate_07",
                sectionId: "section_intermediate",
                order: 6,
                title: "Color Theory",
                description: "Understand color relationships",
                iconName: "paintpalette",
                lessons: [
                    "lesson_085",  // PLACEHOLDER: Color Wheel
                    "lesson_086",  // PLACEHOLDER: Primary Colors
                    "lesson_087",  // PLACEHOLDER: Complementary Colors
                    "lesson_088",  // PLACEHOLDER: Color Temperature
                    "lesson_089",  // PLACEHOLDER: Color Harmony
                    "lesson_090"   // PLACEHOLDER: Color Mixing
                ]
            ),
            
            // Unit 8: Composition (ALL PLACEHOLDERS)
            LearningUnit(
                id: "unit_intermediate_08",
                sectionId: "section_intermediate",
                order: 7,
                title: "Composition",
                description: "Arrange elements for visual impact",
                iconName: "rectangle.3.group",
                lessons: [
                    "lesson_091",  // PLACEHOLDER: Rule of Thirds
                    "lesson_092",  // PLACEHOLDER: Leading Lines
                    "lesson_093",  // PLACEHOLDER: Focal Points
                    "lesson_094",  // PLACEHOLDER: Balance and Symmetry
                    "lesson_095",  // PLACEHOLDER: Negative Space
                    "lesson_096"   // PLACEHOLDER: Visual Flow
                ]
            )
        ]
        
        return LearningSection(
            id: "section_intermediate",
            title: "Intermediate",
            level: .intermediate,
            order: 1,
            description: "Build upon fundamentals with advanced techniques",
            iconName: "mountain.2.fill",
            units: units
        )
    }
    
    // MARK: - ADVANCED SECTION (8 Units × 6 Lessons = 48 Lessons)
    private static func createAdvancedSection() -> LearningSection {
        let units = [
            // Unit 1: Professional Techniques (ALL PLACEHOLDERS)
            LearningUnit(
                id: "unit_advanced_01",
                sectionId: "section_advanced",
                order: 0,
                title: "Professional Techniques",
                description: "Industry-standard drawing methods",
                iconName: "graduationcap",
                lessons: [
                    "lesson_097",  // PLACEHOLDER: Professional Workflow
                    "lesson_098",  // PLACEHOLDER: Reference Usage
                    "lesson_099",  // PLACEHOLDER: Speed Drawing
                    "lesson_100",  // PLACEHOLDER: Accuracy Training
                    "lesson_101",  // PLACEHOLDER: Style Development
                    "lesson_102"   // PLACEHOLDER: Portfolio Building
                ]
            ),
            
            // Unit 2: Advanced Anatomy (ALL PLACEHOLDERS)
            LearningUnit(
                id: "unit_advanced_02",
                sectionId: "section_advanced",
                order: 1,
                title: "Advanced Anatomy",
                description: "Master complex anatomical structures",
                iconName: "figure.2",
                lessons: [
                    "lesson_103",  // PLACEHOLDER: Muscle Structure
                    "lesson_104",  // PLACEHOLDER: Bone Landmarks
                    "lesson_105",  // PLACEHOLDER: Dynamic Poses
                    "lesson_106",  // PLACEHOLDER: Foreshortening
                    "lesson_107",  // PLACEHOLDER: Age Variations
                    "lesson_108"   // PLACEHOLDER: Expression Subtlety
                ]
            ),
            
            // Unit 3: Complex Perspective (ALL PLACEHOLDERS)
            LearningUnit(
                id: "unit_advanced_03",
                sectionId: "section_advanced",
                order: 2,
                title: "Complex Perspective",
                description: "Master three-point and beyond",
                iconName: "cube.transparent",
                lessons: [
                    "lesson_109",  // PLACEHOLDER: Three-Point Perspective
                    "lesson_110",  // PLACEHOLDER: Curvilinear Perspective
                    "lesson_111",  // PLACEHOLDER: Aerial Perspective
                    "lesson_112",  // PLACEHOLDER: Multiple Vanishing Points
                    "lesson_113",  // PLACEHOLDER: Perspective Correction
                    "lesson_114"   // PLACEHOLDER: Advanced Architecture
                ]
            ),
            
            // Unit 4: Master Studies (ALL PLACEHOLDERS)
            LearningUnit(
                id: "unit_advanced_04",
                sectionId: "section_advanced",
                order: 3,
                title: "Master Studies",
                description: "Learn from the great artists",
                iconName: "paintbrush.pointed",
                lessons: [
                    "lesson_115",  // PLACEHOLDER: Classical Techniques
                    "lesson_116",  // PLACEHOLDER: Renaissance Methods
                    "lesson_117",  // PLACEHOLDER: Modern Approaches
                    "lesson_118",  // PLACEHOLDER: Master Reproductions
                    "lesson_119",  // PLACEHOLDER: Style Analysis
                    "lesson_120"   // PLACEHOLDER: Technique Adaptation
                ]
            ),
            
            // Unit 5: Digital Mastery (ALL PLACEHOLDERS)
            LearningUnit(
                id: "unit_advanced_05",
                sectionId: "section_advanced",
                order: 4,
                title: "Digital Mastery",
                description: "Advanced digital art techniques",
                iconName: "ipad.and.apple.pencil",
                lessons: [
                    "lesson_121",  // PLACEHOLDER: Layer Management
                    "lesson_122",  // PLACEHOLDER: Brush Customization
                    "lesson_123",  // PLACEHOLDER: Digital Blending
                    "lesson_124",  // PLACEHOLDER: Texture Creation
                    "lesson_125",  // PLACEHOLDER: Digital Effects
                    "lesson_126"   // PLACEHOLDER: Print Preparation
                ]
            ),
            
            // Unit 6: Creative Projects (ALL PLACEHOLDERS)
            LearningUnit(
                id: "unit_advanced_06",
                sectionId: "section_advanced",
                order: 5,
                title: "Creative Projects",
                description: "Push your artistic boundaries",
                iconName: "sparkles",
                lessons: [
                    "lesson_127",  // PLACEHOLDER: Concept Art
                    "lesson_128",  // PLACEHOLDER: Character Design
                    "lesson_129",  // PLACEHOLDER: Environment Design
                    "lesson_130",  // PLACEHOLDER: Storyboarding
                    "lesson_131",  // PLACEHOLDER: Visual Development
                    "lesson_132"   // PLACEHOLDER: Artistic Vision
                ]
            ),
            
            // Unit 7: Professional Practice (ALL PLACEHOLDERS)
            LearningUnit(
                id: "unit_advanced_07",
                sectionId: "section_advanced",
                order: 6,
                title: "Professional Practice",
                description: "Business skills for artists",
                iconName: "briefcase",
                lessons: [
                    "lesson_133",  // PLACEHOLDER: Client Communication
                    "lesson_134",  // PLACEHOLDER: Project Management
                    "lesson_135",  // PLACEHOLDER: Pricing Your Work
                    "lesson_136",  // PLACEHOLDER: Copyright Basics
                    "lesson_137",  // PLACEHOLDER: Marketing Yourself
                    "lesson_138"   // PLACEHOLDER: Career Paths
                ]
            ),
            
            // Unit 8: Mastery Certification (ALL PLACEHOLDERS)
            LearningUnit(
                id: "unit_advanced_08",
                sectionId: "section_advanced",
                order: 7,
                title: "Mastery Certification",
                description: "Demonstrate your artistic expertise",
                iconName: "rosette",
                lessons: [
                    "lesson_139",  // PLACEHOLDER: Final Portfolio
                    "lesson_140",  // PLACEHOLDER: Technique Demonstration
                    "lesson_141",  // PLACEHOLDER: Creative Challenge
                    "lesson_142",  // PLACEHOLDER: Peer Review
                    "lesson_143",  // PLACEHOLDER: Master's Critique
                    "lesson_144"   // PLACEHOLDER: Certification Complete
                ]
            )
        ]
        
        return LearningSection(
            id: "section_advanced",
            title: "Advanced",
            level: .advanced,
            order: 2,
            description: "Professional-level techniques and mastery",
            iconName: "crown.fill",
            units: units
        )
    }
}
