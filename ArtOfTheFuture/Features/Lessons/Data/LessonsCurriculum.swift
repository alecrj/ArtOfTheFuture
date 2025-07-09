// MARK: - Lesson Curriculum
// File: ArtOfTheFuture/Features/Lessons/Data/LessonCurriculum.swift

import Foundation
import SwiftUI

struct LessonCurriculum {
    
    // MARK: - Beginner Lessons (15 total)
    
    // Drawing Practice (5)
    static let beginnerDrawingLessons: [Lesson] = [
        Lesson(
            id: "beginner_draw_01",
            title: "Line Control & Confidence",
            description: "Practice drawing steady lines and curves to build hand control",
            type: .drawingPractice,
            difficulty: .beginner,
            estimatedMinutes: 5,
            xpReward: 50,
            exercises: [
                LessonExercise(
                    id: "bd01_e1",
                    order: 1,
                    type: .traceDrawing,
                    instruction: "Trace these straight lines smoothly",
                    content: .drawing(DrawingExercise(
                        canvas: .init(width: 400, height: 300, backgroundColor: "#FFFFFF", gridEnabled: true, gridSize: 20),
                        guidelines: [
                            DrawingGuideline(
                                id: "line1",
                                type: .line,
                                path: [CGPoint(x: 50, y: 150), CGPoint(x: 350, y: 150)],
                                style: .init(color: "#3B82F6", width: 2, opacity: 0.5, dashPattern: [5, 5], animated: true, animationDuration: 2),
                                showTiming: .always
                            )
                        ],
                        referenceImage: nil,
                        animationDemo: "line_trace_demo",
                        timeLimit: nil,
                        toolsAllowed: [.pen]
                    )),
                    validation: ValidationCriteria(
                        minScore: 0.7,
                        maxAttempts: 3,
                        rules: [],
                        feedback: .init(showRealtime: true, showHints: true, encouragementThreshold: 0.5)
                    ),
                    hints: ["Keep your hand steady", "Don't rush - smooth is better than fast"],
                    xpValue: 10
                ),
                LessonExercise(
                    id: "bd01_e2",
                    order: 2,
                    type: .guidedDrawing,
                    instruction: "Now draw curves following the guides",
                    content: .drawing(DrawingExercise(
                        canvas: .init(width: 400, height: 300, backgroundColor: "#FFFFFF", gridEnabled: false, gridSize: nil),
                        guidelines: [
                            DrawingGuideline(
                                id: "curve1",
                                type: .curve,
                                path: generateSmoothCurve(),
                                style: .init(color: "#10B981", width: 2, opacity: 0.4, dashPattern: nil, animated: true, animationDuration: 3),
                                showTiming: .initial
                            )
                        ],
                        referenceImage: nil,
                        animationDemo: nil,
                        timeLimit: nil,
                        toolsAllowed: [.pen, .pencil]
                    )),
                    validation: ValidationCriteria(
                        minScore: 0.6,
                        maxAttempts: 5,
                        rules: [],
                        feedback: .init(showRealtime: true, showHints: true, encouragementThreshold: 0.4)
                    ),
                    hints: ["Use your whole arm, not just your wrist", "Practice the motion in the air first"],
                    xpValue: 15
                ),
                LessonExercise(
                    id: "bd01_e3",
                    order: 3,
                    type: .freehandDrawing,
                    instruction: "Connect the dots with smooth lines",
                    content: .drawing(DrawingExercise(
                        canvas: .init(width: 400, height: 300, backgroundColor: "#FFFFFF", gridEnabled: false, gridSize: nil),
                        guidelines: createDotPattern(),
                        referenceImage: nil,
                        animationDemo: nil,
                        timeLimit: 60,
                        toolsAllowed: [.pen]
                    )),
                    validation: ValidationCriteria(
                        minScore: 0.5,
                        maxAttempts: 3,
                        rules: [],
                        feedback: .init(showRealtime: false, showHints: true, encouragementThreshold: 0.3)
                    ),
                    hints: ["Try to make it in one smooth motion"],
                    xpValue: 25
                )
            ],
            objectives: [
                "Draw steady, confident lines",
                "Control line weight and smoothness",
                "Build hand-eye coordination"
            ],
            skills: [
                DrawingSkill(
                    id: "line_control",
                    name: "Line Control",
                    description: "Ability to draw smooth, controlled lines",
                    icon: "pencil.line",
                    category: .lineControl
                )
            ],
            tips: [
                "Relax your grip on the pencil",
                "Use your shoulder and elbow, not just your wrist",
                "Practice makes permanent - focus on quality over speed"
            ],
            prerequisites: [],
            unlocks: ["beginner_draw_02"]
        ),
        
        Lesson(
            id: "beginner_draw_02",
            title: "Basic Shapes Sketching",
            description: "Master circles, squares, and triangles - the building blocks of all drawings",
            type: .drawingPractice,
            difficulty: .beginner,
            estimatedMinutes: 5,
            xpReward: 50,
            exercises: createBasicShapesExercises(),
            objectives: [
                "Draw basic geometric shapes confidently",
                "Understand shape construction",
                "See complex objects as combinations of simple shapes"
            ],
            skills: [
                DrawingSkill(
                    id: "basic_shapes",
                    name: "Basic Shapes",
                    description: "Ability to draw fundamental geometric shapes",
                    icon: "square.circle",
                    category: .basicShapes
                )
            ],
            tips: [
                "Practice 'ghosting' the shape in the air first",
                "Circles: move from the shoulder, not the wrist",
                "Squares: focus on parallel lines and right angles"
            ],
            prerequisites: ["beginner_draw_01"],
            unlocks: ["beginner_draw_03", "beginner_theory_01"]
        ),
        
        Lesson(
            id: "beginner_draw_03",
            title: "Intro to 3D Forms",
            description: "Transform flat shapes into 3D forms with one-point perspective",
            type: .drawingPractice,
            difficulty: .beginner,
            estimatedMinutes: 7,
            xpReward: 75,
            exercises: createBeginnerPerspectiveExercises(),
            objectives: [
                "Understand one-point perspective",
                "Draw basic 3D forms",
                "Create depth in your drawings"
            ],
            skills: [
                DrawingSkill(
                    id: "perspective_basics",
                    name: "Basic Perspective",
                    description: "Understanding of one-point perspective",
                    icon: "cube",
                    category: .perspective
                )
            ],
            tips: [
                "All lines going into the distance meet at the vanishing point",
                "Keep your horizon line consistent",
                "Start with simple boxes before complex objects"
            ],
            prerequisites: ["beginner_draw_02"],
            unlocks: ["beginner_draw_04", "intermediate_draw_02"]
        ),
        
        Lesson(
            id: "beginner_draw_04",
            title: "Shade a Simple Object",
            description: "Learn basic shading to make flat drawings look three-dimensional",
            type: .drawingPractice,
            difficulty: .beginner,
            estimatedMinutes: 6,
            xpReward: 60,
            exercises: createBeginnerShadingExercises(),
            objectives: [
                "Identify light source direction",
                "Apply basic shading techniques",
                "Create form through value"
            ],
            skills: [
                DrawingSkill(
                    id: "basic_shading",
                    name: "Basic Shading",
                    description: "Understanding light and shadow",
                    icon: "circle.lefthalf.filled",
                    category: .shading
                )
            ],
            tips: [
                "Start light and build up gradually",
                "The darkest shadow is usually where the object touches the surface",
                "Don't forget reflected light!"
            ],
            prerequisites: ["beginner_draw_03"],
            unlocks: ["beginner_draw_05", "intermediate_draw_04"]
        ),
        
        Lesson(
            id: "beginner_draw_05",
            title: "Contour Drawing Exercise",
            description: "Train your eye-hand coordination with observational drawing",
            type: .drawingPractice,
            difficulty: .beginner,
            estimatedMinutes: 5,
            xpReward: 50,
            exercises: createContourDrawingExercises(),
            objectives: [
                "Improve observational skills",
                "Draw what you see, not what you think",
                "Build confidence in freehand drawing"
            ],
            skills: [
                DrawingSkill(
                    id: "observation",
                    name: "Observational Drawing",
                    description: "Ability to accurately observe and draw",
                    icon: "eye",
                    category: .observation
                )
            ],
            tips: [
                "Look at the subject more than your paper",
                "Draw slowly and deliberately",
                "Focus on edges and boundaries"
            ],
            prerequisites: ["beginner_draw_04"],
            unlocks: ["intermediate_draw_01"]
        )
    ]
    
    // Theory Fundamentals (5)
    static let beginnerTheoryLessons: [Lesson] = [
        Lesson(
            id: "beginner_theory_01",
            title: "Drawing Basics 101",
            description: "Learn the core elements that make up every drawing",
            type: .theoryFundamentals,
            difficulty: .beginner,
            estimatedMinutes: 3,
            xpReward: 30,
            exercises: [
                LessonExercise(
                    id: "bt01_e1",
                    order: 1,
                    type: .multipleChoice,
                    instruction: "What are the five basic elements of art?",
                    content: .theory(TheoryExercise(
                        question: "Select all five basic elements of art",
                        visualAid: "elements_of_art_diagram",
                        interactionType: .multipleChoice,
                        options: [
                            TheoryExercise.TheoryOption(id: "1", content: .text("Line"), feedback: "Correct! Lines are the foundation"),
                            TheoryExercise.TheoryOption(id: "2", content: .text("Shape"), feedback: "Yes! 2D forms"),
                            TheoryExercise.TheoryOption(id: "3", content: .text("Form"), feedback: "Right! 3D shapes"),
                            TheoryExercise.TheoryOption(id: "4", content: .text("Value"), feedback: "Exactly! Light and dark"),
                            TheoryExercise.TheoryOption(id: "5", content: .text("Space"), feedback: "Perfect! Positive and negative"),
                            TheoryExercise.TheoryOption(id: "6", content: .text("Style"), feedback: "Not quite - style comes later"),
                            TheoryExercise.TheoryOption(id: "7", content: .text("Speed"), feedback: "No, speed isn't an element")
                        ],
                        correctAnswer: .multiple(["1", "2", "3", "4", "5"]),
                        explanation: "These five elements are the building blocks of all visual art"
                    )),
                    validation: ValidationCriteria(
                        minScore: 1.0,
                        maxAttempts: 2,
                        rules: [],
                        feedback: .init(showRealtime: true, showHints: false, encouragementThreshold: 0.5)
                    ),
                    hints: ["Think about the most basic components"],
                    xpValue: 10
                ),
                LessonExercise(
                    id: "bt01_e2",
                    order: 2,
                    type: .tapToIdentify,
                    instruction: "Tap the example that shows 'Form' not just 'Shape'",
                    content: .theory(TheoryExercise(
                        question: "Which drawing shows FORM (3D) rather than just SHAPE (2D)?",
                        visualAid: "shape_vs_form_examples",
                        interactionType: .tapAreas,
                        options: [
                            TheoryExercise.TheoryOption(id: "1", content: .image("flat_circle"), feedback: "This is a 2D shape"),
                            TheoryExercise.TheoryOption(id: "2", content: .image("shaded_sphere"), feedback: "Correct! Shading creates form"),
                            TheoryExercise.TheoryOption(id: "3", content: .image("square_outline"), feedback: "This is just a shape"),
                            TheoryExercise.TheoryOption(id: "4", content: .image("cube_drawing"), feedback: "Yes! This shows 3D form")
                        ],
                        correctAnswer: .multiple(["2", "4"]),
                        explanation: "Form has dimension and volume, created through shading and perspective"
                    )),
                    validation: ValidationCriteria(
                        minScore: 0.5,
                        maxAttempts: 2,
                        rules: [],
                        feedback: .init(showRealtime: true, showHints: true, encouragementThreshold: 0.5)
                    ),
                    hints: ["Look for depth and dimension"],
                    xpValue: 20
                )
            ],
            objectives: [
                "Understand the 5 elements of art",
                "Distinguish between shape and form",
                "Build artistic vocabulary"
            ],
            skills: [
                DrawingSkill(
                    id: "art_theory",
                    name: "Art Theory Basics",
                    description: "Understanding fundamental art concepts",
                    icon: "book",
                    category: .theory
                )
            ],
            tips: [
                "Every drawing uses these elements",
                "Master these before moving to advanced concepts",
                "Look for these elements in artwork around you"
            ],
            prerequisites: ["beginner_draw_02"],
            unlocks: ["beginner_theory_02"]
        ),
        
        Lesson(
            id: "beginner_theory_02",
            title: "Perspective & Space",
            description: "Understand how perspective creates the illusion of depth",
            type: .theoryFundamentals,
            difficulty: .beginner,
            estimatedMinutes: 4,
            xpReward: 40,
            exercises: createBeginnerPerspectiveTheory(),
            objectives: [
                "Understand horizon line and vanishing points",
                "Identify perspective in images",
                "Know when to use one-point perspective"
            ],
            skills: [
                DrawingSkill(
                    id: "perspective_theory",
                    name: "Perspective Theory",
                    description: "Understanding of perspective principles",
                    icon: "square.3.layers.3d.down.right",
                    category: .perspective
                )
            ],
            tips: [
                "The horizon line is always at eye level",
                "Objects get smaller as they recede",
                "Parallel lines converge at vanishing points"
            ],
            prerequisites: ["beginner_theory_01"],
            unlocks: ["beginner_theory_03", "beginner_challenge_03"]
        ),
        
        Lesson(
            id: "beginner_theory_03",
            title: "Light and Shadow Basics",
            description: "Learn how light creates form and depth in drawings",
            type: .theoryFundamentals,
            difficulty: .beginner,
            estimatedMinutes: 4,
            xpReward: 40,
            exercises: createLightTheoryExercises(),
            objectives: [
                "Identify light source direction",
                "Understand core shadow vs cast shadow",
                "Know basic shadow terminology"
            ],
            skills: [
                DrawingSkill(
                    id: "light_theory",
                    name: "Light & Shadow Theory",
                    description: "Understanding how light works",
                    icon: "sun.max",
                    category: .shading
                )
            ],
            tips: [
                "One light source is easier than multiple",
                "Shadows anchor objects to surfaces",
                "Reflected light prevents pure black shadows"
            ],
            prerequisites: ["beginner_theory_02"],
            unlocks: ["beginner_theory_04"]
        ),
        
        Lesson(
            id: "beginner_theory_04",
            title: "Proportions & Measuring",
            description: "Learn to measure and compare to draw accurate proportions",
            type: .theoryFundamentals,
            difficulty: .beginner,
            estimatedMinutes: 3,
            xpReward: 30,
            exercises: createProportionTheoryExercises(),
            objectives: [
                "Use comparative measuring",
                "Understand basic human proportions",
                "Apply the rule of thirds"
            ],
            skills: [
                DrawingSkill(
                    id: "proportion_theory",
                    name: "Proportion Theory",
                    description: "Understanding measurement and proportion",
                    icon: "ruler",
                    category: .proportion
                )
            ],
            tips: [
                "Use your pencil as a measuring tool",
                "Compare sizes to find relationships",
                "The human body is about 8 heads tall"
            ],
            prerequisites: ["beginner_theory_03"],
            unlocks: ["beginner_theory_05"]
        ),
        
        Lesson(
            id: "beginner_theory_05",
            title: "Composition Basics",
            description: "Learn to arrange elements for visually pleasing drawings",
            type: .theoryFundamentals,
            difficulty: .beginner,
            estimatedMinutes: 3,
            xpReward: 30,
            exercises: createCompositionTheoryExercises(),
            objectives: [
                "Apply the rule of thirds",
                "Create visual balance",
                "Guide the viewer's eye"
            ],
            skills: [
                DrawingSkill(
                    id: "composition_basics",
                    name: "Basic Composition",
                    description: "Arranging elements effectively",
                    icon: "rectangle.split.3x3",
                    category: .composition
                )
            ],
            tips: [
                "Avoid centering everything",
                "Odd numbers are more dynamic",
                "Create a clear focal point"
            ],
            prerequisites: ["beginner_theory_04"],
            unlocks: ["intermediate_theory_01"]
        )
    ]
    
    // Creative Challenges (5)
    static let beginnerCreativeLessons: [Lesson] = [
        Lesson(
            id: "beginner_challenge_01",
            title: "Finish the Drawing",
            description: "Complete symmetrical drawings to train your observation",
            type: .creativeChallenge,
            difficulty: .beginner,
            estimatedMinutes: 4,
            xpReward: 40,
            exercises: [
                LessonExercise(
                    id: "bc01_e1",
                    order: 1,
                    type: .completeDrawing,
                    instruction: "Complete the other half of this vase",
                    content: .challenge(ChallengeExercise(
                        challengeType: .completeHalfDrawing,
                        prompt: "This vase is only half drawn. Complete the symmetrical other half",
                        resources: ["half_vase_template"],
                        constraints: ChallengeExercise.ChallengeConstraints(
                            timeLimit: 120,
                            strokeLimit: nil,
                            toolRestrictions: nil,
                            colorPalette: ["#000000"]
                        ),
                        judgingCriteria: [
                            JudgingCriterion(
                                id: "symmetry",
                                name: "Symmetry",
                                weight: 0.7,
                                evaluationType: .automatic
                            ),
                            JudgingCriterion(
                                id: "line_quality",
                                name: "Line Quality",
                                weight: 0.3,
                                evaluationType: .automatic
                            )
                        ]
                    )),
                    validation: ValidationCriteria(
                        minScore: 0.6,
                        maxAttempts: 2,
                        rules: [],
                        feedback: .init(showRealtime: false, showHints: true, encouragementThreshold: 0.5)
                    ),
                    hints: ["Mirror the curves exactly", "Use guidelines if needed"],
                    xpValue: 20
                ),
                LessonExercise(
                    id: "bc01_e2",
                    order: 2,
                    type: .completeDrawing,
                    instruction: "Complete this face",
                    content: .challenge(ChallengeExercise(
                        challengeType: .completeHalfDrawing,
                        prompt: "Draw the missing half of this simple cartoon face",
                        resources: ["half_face_simple"],
                        constraints: ChallengeExercise.ChallengeConstraints(
                            timeLimit: 180,
                            strokeLimit: nil,
                            toolRestrictions: nil,
                            colorPalette: ["#000000"]
                        ),
                        judgingCriteria: [
                            JudgingCriterion(
                                id: "symmetry",
                                name: "Facial Symmetry",
                                weight: 0.6,
                                evaluationType: .automatic
                            ),
                            JudgingCriterion(
                                id: "proportion",
                                name: "Feature Proportion",
                                weight: 0.4,
                                evaluationType: .automatic
                            )
                        ]
                    )),
                    validation: ValidationCriteria(
                        minScore: 0.5,
                        maxAttempts: 2,
                        rules: [],
                        feedback: .init(showRealtime: false, showHints: true, encouragementThreshold: 0.4)
                    ),
                    hints: ["Eyes should be the same size", "Keep features aligned"],
                    xpValue: 20
                )
            ],
            objectives: [
                "Develop symmetrical drawing skills",
                "Improve observation accuracy",
                "Build confidence through play"
            ],
            skills: [
                DrawingSkill(
                    id: "symmetry",
                    name: "Symmetrical Drawing",
                    description: "Ability to create balanced, symmetrical drawings",
                    icon: "arrow.left.and.right",
                    category: .observation
                )
            ],
            tips: [
                "Use light guidelines to match proportions",
                "Check your work by looking at it upside down",
                "Perfect symmetry isn't always necessary in art"
            ],
            prerequisites: ["beginner_draw_02"],
            unlocks: ["beginner_challenge_02"]
        ),
        
        Lesson(
            id: "beginner_challenge_02",
            title: "Shape Transformation Game",
            description: "Turn random shapes into creative drawings",
            type: .creativeChallenge,
            difficulty: .beginner,
            estimatedMinutes: 5,
            xpReward: 50,
            exercises: createShapeTransformationExercises(),
            objectives: [
                "Boost creative thinking",
                "See possibilities in simple shapes",
                "Practice quick ideation"
            ],
            skills: [
                DrawingSkill(
                    id: "creative_thinking",
                    name: "Creative Thinking",
                    description: "Transforming basic elements creatively",
                    icon: "lightbulb",
                    category: .creativity
                )
            ],
            tips: [
                "There's no wrong answer!",
                "Think outside the box",
                "Simple additions can transform shapes"
            ],
            prerequisites: ["beginner_challenge_01"],
            unlocks: ["beginner_challenge_03"]
        ),
        
        Lesson(
            id: "beginner_challenge_03",
            title: "Spot the Difference",
            description: "Train your artistic eye by finding drawing mistakes",
            type: .creativeChallenge,
            difficulty: .beginner,
            estimatedMinutes: 3,
            xpReward: 30,
            exercises: createSpotDifferenceExercises(),
            objectives: [
                "Develop critical observation",
                "Identify common drawing errors",
                "Train your artistic judgment"
            ],
            skills: [
                DrawingSkill(
                    id: "critical_eye",
                    name: "Critical Eye",
                    description: "Ability to spot artistic errors",
                    icon: "eye.circle",
                    category: .observation
                )
            ],
            tips: [
                "Look for perspective errors first",
                "Check proportions carefully",
                "Trust your instincts"
            ],
            prerequisites: ["beginner_challenge_02", "beginner_theory_02"],
            unlocks: ["beginner_challenge_04"]
        ),
        
        Lesson(
            id: "beginner_challenge_04",
            title: "Memory Sketch",
            description: "Draw from memory to improve visual retention",
            type: .creativeChallenge,
            difficulty: .beginner,
            estimatedMinutes: 4,
            xpReward: 40,
            exercises: createMemorySketchExercises(),
            objectives: [
                "Improve visual memory",
                "Focus on key shapes and forms",
                "Build drawing confidence"
            ],
            skills: [
                DrawingSkill(
                    id: "visual_memory",
                    name: "Visual Memory",
                    description: "Remembering and recreating visual information",
                    icon: "brain",
                    category: .observation
                )
            ],
            tips: [
                "Focus on overall shapes first",
                "Don't worry about perfect details",
                "Practice improves memory"
            ],
            prerequisites: ["beginner_challenge_03"],
            unlocks: ["beginner_challenge_05"]
        ),
        
        Lesson(
            id: "beginner_challenge_05",
            title: "Quick Draw Challenge",
            description: "Speed sketching to overcome perfectionism",
            type: .creativeChallenge,
            difficulty: .beginner,
            estimatedMinutes: 5,
            xpReward: 50,
            exercises: createQuickDrawExercises(),
            objectives: [
                "Draw without overthinking",
                "Capture essence quickly",
                "Build drawing confidence"
            ],
            skills: [
                DrawingSkill(
                    id: "speed_sketching",
                    name: "Speed Sketching",
                    description: "Quick, confident mark-making",
                    icon: "timer",
                    category: .sketching
                )
            ],
            tips: [
                "Perfection is not the goal",
                "Capture the main idea",
                "Keep your hand moving"
            ],
            prerequisites: ["beginner_challenge_04"],
            unlocks: ["intermediate_challenge_01"]
        )
    ]
    
    // MARK: - Intermediate Lessons (15 total) - Stub for now
    static let intermediateLessons: [Lesson] = [
        Lesson(
            id: "intermediate_draw_01",
            title: "Gesture Drawing Sprint",
            description: "Capture movement and energy with quick figure sketches",
            type: .drawingPractice,
            difficulty: .intermediate,
            estimatedMinutes: 7,
            xpReward: 100,
            exercises: createGestureDrawingExercises(),
            objectives: [
                "Capture the 'line of action'",
                "Draw figures quickly and confidently",
                "Focus on movement over detail"
            ],
            skills: [
                DrawingSkill(
                    id: "gesture_drawing",
                    name: "Gesture Drawing",
                    description: "Capturing movement and energy",
                    icon: "figure.run",
                    category: .figure
                )
            ],
            tips: [
                "Start with the line of action",
                "Work from general to specific",
                "Don't focus on details"
            ],
            prerequisites: ["beginner_draw_05"],
            unlocks: ["intermediate_draw_02", "intermediate_draw_05"]
        )
    ]
    
    // MARK: - Advanced Lessons (15 total) - Stub for now
    static let advancedLessons: [Lesson] = [
        Lesson(
            id: "advanced_draw_01",
            title: "3-Point Perspective Mastery",
            description: "Draw dynamic scenes from dramatic angles",
            type: .drawingPractice,
            difficulty: .advanced,
            estimatedMinutes: 10,
            xpReward: 150,
            exercises: createAdvancedPerspectiveExercises(),
            objectives: [
                "Master three-point perspective",
                "Create dramatic viewpoints",
                "Draw complex architectural forms"
            ],
            skills: [
                DrawingSkill(
                    id: "advanced_perspective",
                    name: "Advanced Perspective",
                    description: "Complex perspective techniques",
                    icon: "cube.transparent",
                    category: .perspective
                )
            ],
            tips: [
                "Keep all vanishing points consistent",
                "Use guidelines extensively",
                "Check your work from different angles"
            ],
            prerequisites: ["intermediate_draw_02"],
            unlocks: ["advanced_draw_02", "advanced_theory_01"]
        )
    ]
    
    // MARK: - Complete Curriculum
    static var allLessons: [Lesson] {
        beginnerDrawingLessons + beginnerTheoryLessons + beginnerCreativeLessons +
        intermediateLessons + advancedLessons
    }
    
    // MARK: - Placement Test
    static let placementTest = PlacementTest(
        id: "placement_test_v1",
        exercises: [
            PlacementTest.PlacementExercise(
                id: "pt_theory_1",
                type: .quickTheory,
                difficulty: .beginner,
                skill: .theory,
                content: .theory(TheoryExercise(
                    question: "What is the horizon line in perspective drawing?",
                    visualAid: nil,
                    interactionType: .multipleChoice,
                    options: [
                        TheoryExercise.TheoryOption(id: "1", content: .text("The line where sky meets ground"), feedback: nil),
                        TheoryExercise.TheoryOption(id: "2", content: .text("The edge of the paper"), feedback: nil),
                        TheoryExercise.TheoryOption(id: "3", content: .text("Any horizontal line"), feedback: nil),
                        TheoryExercise.TheoryOption(id: "4", content: .text("The darkest line"), feedback: nil)
                    ],
                    correctAnswer: .single("1"),
                    explanation: "The horizon line represents eye level"
                )),
                weight: 1.0
            ),
            PlacementTest.PlacementExercise(
                id: "pt_draw_1",
                type: .drawBasicShape,
                difficulty: .beginner,
                skill: .basicShapes,
                content: .drawing(DrawingExercise(
                    canvas: .init(width: 300, height: 300, backgroundColor: "#FFFFFF", gridEnabled: false, gridSize: nil),
                    guidelines: nil,
                    referenceImage: nil,
                    animationDemo: nil,
                    timeLimit: 60,
                    toolsAllowed: [.pen]
                )),
                weight: 2.0
            ),
            PlacementTest.PlacementExercise(
                id: "pt_identify_1",
                type: .identifyTechnique,
                difficulty: .intermediate,
                skill: .shading,
                content: .theory(TheoryExercise(
                    question: "Which shading technique is shown here?",
                    visualAid: "crosshatch_example",
                    interactionType: .multipleChoice,
                    options: [
                        TheoryExercise.TheoryOption(id: "1", content: .text("Blending"), feedback: nil),
                        TheoryExercise.TheoryOption(id: "2", content: .text("Cross-hatching"), feedback: nil),
                        TheoryExercise.TheoryOption(id: "3", content: .text("Stippling"), feedback: nil),
                        TheoryExercise.TheoryOption(id: "4", content: .text("Scribbling"), feedback: nil)
                    ],
                    correctAnswer: .single("2"),
                    explanation: "Cross-hatching uses intersecting lines"
                )),
                weight: 1.5
            )
        ]
    )
}

// MARK: - Helper Functions
private func generateSmoothCurve() -> [CGPoint] {
    // Generate a smooth S-curve for practice
    var points: [CGPoint] = []
    for i in 0...20 {
        let x = CGFloat(i) * 20 + 50
        let y = sin(CGFloat(i) * 0.3) * 50 + 150
        points.append(CGPoint(x: x, y: y))
    }
    return points
}

private func createDotPattern() -> [DrawingGuideline] {
    // Create a pattern of dots for connect-the-dots exercise
    let positions: [(CGFloat, CGFloat)] = [
        (100, 100), (200, 80), (300, 100),
        (320, 200), (200, 250), (80, 200)
    ]
    
    return positions.enumerated().map { index, pos in
        DrawingGuideline(
            id: "dot_\(index)",
            type: .circle,
            path: [CGPoint(x: pos.0, y: pos.1), CGPoint(x: pos.0 + 5, y: pos.1)],
            style: .init(color: "#3B82F6", width: 10, opacity: 1.0, dashPattern: nil, animated: false, animationDuration: nil),
            showTiming: .always
        )
    }
}

// MARK: - Exercise Creation Functions (Stubs for compilation)
private func createBasicShapesExercises() -> [LessonExercise] {
    return [
        LessonExercise(
            id: "shapes_ex_1",
            order: 1,
            type: .traceDrawing,
            instruction: "Trace this perfect circle",
            content: .drawing(DrawingExercise(
                canvas: .init(width: 400, height: 400, backgroundColor: "#FFFFFF", gridEnabled: true, gridSize: 25),
                guidelines: [
                    DrawingGuideline(
                        id: "circle1",
                        type: .circle,
                        path: [CGPoint(x: 200, y: 200), CGPoint(x: 300, y: 200)],
                        style: .init(color: "#F59E0B", width: 2, opacity: 0.5, dashPattern: [8, 4], animated: true, animationDuration: 4),
                        showTiming: .always
                    )
                ],
                referenceImage: nil,
                animationDemo: "circle_technique",
                timeLimit: nil,
                toolsAllowed: [.pen]
            )),
            validation: ValidationCriteria(
                minScore: 0.7,
                maxAttempts: 3,
                rules: [],
                feedback: .init(showRealtime: true, showHints: true, encouragementThreshold: 0.5)
            ),
            hints: ["Move from your shoulder", "Try to complete it in one motion"],
            xpValue: 15
        )
    ]
}

private func createBeginnerPerspectiveExercises() -> [LessonExercise] {
    return []
}

private func createBeginnerShadingExercises() -> [LessonExercise] {
    return []
}

private func createContourDrawingExercises() -> [LessonExercise] {
    return []
}

private func createBeginnerPerspectiveTheory() -> [LessonExercise] {
    return []
}

private func createLightTheoryExercises() -> [LessonExercise] {
    return []
}

private func createProportionTheoryExercises() -> [LessonExercise] {
    return []
}

private func createCompositionTheoryExercises() -> [LessonExercise] {
    return []
}

private func createShapeTransformationExercises() -> [LessonExercise] {
    return []
}

private func createSpotDifferenceExercises() -> [LessonExercise] {
    return []
}

private func createMemorySketchExercises() -> [LessonExercise] {
    return []
}

private func createQuickDrawExercises() -> [LessonExercise] {
    return []
}

private func createGestureDrawingExercises() -> [LessonExercise] {
    return []
}

private func createAdvancedPerspectiveExercises() -> [LessonExercise] {
    return []
}
