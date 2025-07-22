// MARK: - Clean Lessons Curriculum (NO HINTS - Top-Tier Quality)
// File: ArtOfTheFuture/Features/Lessons/Data/LessonsCurriculum.swift

import Foundation
import SwiftUI

struct Curriculum {
    
    // MARK: - All Lessons
    static let allLessons: [Lesson] = [
        // Beginner Lessons - Clear, Simple, Progressive
        beginnerLesson001,
        beginnerLesson002,
        beginnerLesson003,
        beginnerLesson004,
        beginnerLesson005,
        beginnerLesson006  // ✅ NEW: Complete Unit 1
    ]
    
    // MARK: - All Badges
    static let allBadges: [Badge] = [
        Badge(
            id: "first_lesson",
            name: "First Steps",
            description: "Complete your first drawing lesson",
            icon: "star.fill",
            requirement: .completeLesson(lessonId: "lesson_001"),
            xpReward: 50
        ),
        Badge(
            id: "shape_master",
            name: "Shape Master",
            description: "Complete 3 drawing lessons",
            icon: "square.circle",
            requirement: .completeLessonsCount(count: 3),
            xpReward: 100
        ),
        Badge(
            id: "unit_one_complete",
            name: "Foundation Master",
            description: "Complete all 6 lessons in Unit 1",
            icon: "trophy.fill",
            requirement: .completeLessonsCount(count: 6),
            xpReward: 200
        ),
        Badge(
            id: "daily_artist",
            name: "Daily Artist",
            description: "Practice for 3 days in a row",
            icon: "flame.fill",
            requirement: .achieveStreak(days: 3),
            xpReward: 75
        )
    ]
}

// MARK: - Lesson Definitions (Clean & Focused)
extension Curriculum {
    
    // LESSON 1: Welcome & Introduction (Clean, No Hints)
    // MARK: - Enhanced Lesson 1: Perfect 6-Step Art Education Experience
    // File: ArtOfTheFuture/Features/Lessons/Data/LessonsCurriculum.swift (Replace beginnerLesson001)

    static let beginnerLesson001 = Lesson(
        id: "lesson_001",
        title: "Welcome to Drawing!",
        description: "Your first steps into the world of art - learn tool basics and make your first confident marks",
        type: .drawingPractice,
        category: .basics,
        difficulty: .beginner,
        estimatedMinutes: 8,
        xpReward: 100,
        steps: [
            // STEP 1: Warm Welcome & Mindset (Introduction)
            LessonStep(
                id: "step_001_1",
                order: 1,
                title: "Welcome, Future Artist!",
                instruction: "Every great artist started exactly where you are now. Let's begin your artistic journey together with confidence and curiosity.",
                content: .introduction(IntroContent(
                    displayImage: nil,
                    animationName: nil,
                    bulletPoints: [
                        "🎨 Art is about expression, not perfection",
                        "✏️ Every stroke teaches you something new",
                        "🌟 Your unique style will develop naturally",
                        "🎯 Focus on learning, not comparing",
                        "💪 Confidence comes from practice, not talent"
                    ]
                )),
                validation: ValidationCriteria(
                    minScore: 1.0,
                    maxAttempts: 1,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: false,
                        encouragementThreshold: 1.0
                    ),
                    requiresAllCorrect: false
                ),
                xpValue: 15
            ),
            
            // STEP 2: Tool Understanding (Theory)
            LessonStep(
                id: "step_001_2",
                order: 2,
                title: "Understanding Your Digital Tools",
                instruction: "Let's learn about the amazing tools you have at your fingertips and how they work.",
                content: .theory(TheoryContent(
                    question: "What makes digital drawing different from traditional drawing?",
                    visualAid: nil,
                    answerType: .singleChoice,
                    options: [
                        TheoryContent.AnswerOption(
                            id: "unlimited_undo",
                            text: "You can undo mistakes and experiment freely",
                            image: nil
                        ),
                        TheoryContent.AnswerOption(
                            id: "exactly_same",
                            text: "It's exactly the same as drawing on paper",
                            image: nil
                        ),
                        TheoryContent.AnswerOption(
                            id: "only_perfect",
                            text: "Only perfect artists can draw digitally",
                            image: nil
                        ),
                        TheoryContent.AnswerOption(
                            id: "no_creativity",
                            text: "Digital drawing isn't as creative",
                            image: nil
                        )
                    ],
                    correctAnswers: ["unlimited_undo"],
                    explanation: "Exactly! Digital drawing gives you the freedom to experiment, make mistakes, and learn without fear. You can undo, try different approaches, and build confidence through exploration. This makes it perfect for learning!"
                )),
                validation: ValidationCriteria(
                    minScore: 1.0,
                    maxAttempts: 3,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: false,
                        encouragementThreshold: 1.0
                    ),
                    requiresAllCorrect: true
                ),
                xpValue: 15
            ),
            
            // STEP 3: First Gentle Marks (Drawing)
            LessonStep(
                id: "step_001_3",
                order: 3,
                title: "Your Very First Marks",
                instruction: "Let's make some gentle marks on the canvas. Don't worry about what you're drawing - just feel the tool responding to your movements. Scribble, doodle, or draw simple lines.",
                content: .drawing(DrawingContent(
                    canvasSize: CGSize(width: 300, height: 200),
                    backgroundColor: "#FFFFFF",
                    guidelines: nil,  // No guidelines for free exploration
                    referenceImage: nil,
                    toolsAllowed: [.pencil, .pen]
                )),
                validation: ValidationCriteria(
                    minScore: 0.1,  // Very low threshold - just need to draw something
                    maxAttempts: 1,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: true,
                        encouragementThreshold: 0.1
                    ),
                    requiresAllCorrect: false
                ),
                xpValue: 20
            ),
            
            // STEP 4: Pressure and Control (Drawing)
            LessonStep(
                id: "step_001_4",
                order: 4,
                title: "Discovering Pressure Control",
                instruction: "Now let's explore how pressure affects your strokes. Try drawing some lines: press lightly for thin lines, press harder for thick lines. Notice how the tool responds to your touch.",
                content: .drawing(DrawingContent(
                    canvasSize: CGSize(width: 300, height: 200),
                    backgroundColor: "#FFFFFF",
                    guidelines: nil,
                    referenceImage: nil,
                    toolsAllowed: [.pencil, .pen]
                )),
                validation: ValidationCriteria(
                    minScore: 0.3,
                    maxAttempts: 2,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: true,
                        encouragementThreshold: 0.2
                    ),
                    requiresAllCorrect: false
                ),
                xpValue: 20
            ),
            
            // STEP 5: First Simple Shape (Challenge)
            LessonStep(
                id: "step_001_5",
                order: 5,
                title: "Your First Circle Challenge",
                instruction: "Ready for your first small challenge? Try to draw a circle. It doesn't need to be perfect - just do your best! This is about building confidence, not perfection.",
                content: .challenge(ChallengeContent(
                    challengeType: .freestyle,
                    prompt: "Draw a circle anywhere on the canvas. Take your time and don't worry if it's not perfectly round!",
                    resources: [
                        "Remember: light, confident strokes",
                        "You can start over if you want to",
                        "Every artist's circles look different - that's what makes art personal"
                    ],
                    constraints: [
                        "encouragement": "true",
                        "focus": "confidence"
                    ]
                )),
                validation: ValidationCriteria(
                    minScore: 0.5,
                    maxAttempts: 3,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: false,
                        encouragementThreshold: 0.3
                    ),
                    requiresAllCorrect: false
                ),
                xpValue: 25
            ),
            
            // STEP 6: Reflection and Next Steps (Theory)
            LessonStep(
                id: "step_001_6",
                order: 6,
                title: "Celebrating Your First Steps",
                instruction: "Look at what you've accomplished! You've taken your first steps into the world of digital art. Every great artist started exactly like this.",
                content: .theory(TheoryContent(
                    question: "What's the most important thing you learned in this lesson?",
                    visualAid: nil,
                    answerType: .singleChoice,
                    options: [
                        TheoryContent.AnswerOption(
                            id: "need_perfect",
                            text: "I need to draw perfectly from the start",
                            image: nil
                        ),
                        TheoryContent.AnswerOption(
                            id: "explore_confidence",
                            text: "It's okay to explore and build confidence gradually",
                            image: nil
                        ),
                        TheoryContent.AnswerOption(
                            id: "too_hard",
                            text: "Digital drawing is too hard for me",
                            image: nil
                        ),
                        TheoryContent.AnswerOption(
                            id: "only_talent",
                            text: "Only naturally talented people can draw",
                            image: nil
                        )
                    ],
                    correctAnswers: ["explore_confidence"],
                    explanation: "Perfect! Art is a journey of exploration and gradual improvement. Every mark you make teaches you something new. You're building the foundation for amazing art skills - be proud of taking these first brave steps!"
                )),
                validation: ValidationCriteria(
                    minScore: 1.0,
                    maxAttempts: 2,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: false,
                        encouragementThreshold: 1.0
                    ),
                    requiresAllCorrect: true
                ),
                xpValue: 15
            )
        ],
        exercises: [],
        objectives: [
            "🎯 Understand the mindset of a learning artist",
            "🛠️ Learn how digital drawing tools work",
            "✏️ Make your first confident marks on digital canvas",
            "🎨 Explore pressure control and line variation",
            "⭐ Complete your first drawing challenge",
            "🚀 Build confidence for your artistic journey ahead"
        ],
        tips: [
            "Hold your Apple Pencil like you would hold a regular pencil - naturally and comfortably",
            "Light, confident strokes usually look better than heavy, uncertain ones",
            "The undo button is your friend - use it to experiment freely",
            "Focus on the motion, not just the result",
            "Every professional artist was once a beginner taking their first lesson"
        ],
        prerequisites: [],
        unlocks: ["lesson_002"]
    )
    
    // LESSON 2: Drawing Straight Lines (Clear instruction)
    static let beginnerLesson002 = Lesson(
        id: "lesson_002",
        title: "Drawing Straight Lines",
        description: "Master the fundamental skill of drawing clean, straight lines",
        type: .drawingPractice,
        category: .basics,
        difficulty: .beginner,
        estimatedMinutes: 4,
        xpReward: 75,
        steps: [
            LessonStep(
                id: "step_002_1",
                order: 1,
                title: "Line Drawing Technique",
                instruction: "Draw 3 horizontal lines across the canvas using the blue guidelines. Use your shoulder and arm for smooth motion.",
                content: .drawing(DrawingContent(
                    canvasSize: CGSize(width: 350, height: 250),
                    backgroundColor: "#FFFFFF",
                    guidelines: [
                        DrawingContent.Guideline(
                            type: .line,
                            path: [CGPoint(x: 50, y: 80), CGPoint(x: 300, y: 80)],
                            color: "#3B82F6",
                            width: 2,
                            dashed: true
                        ),
                        DrawingContent.Guideline(
                            type: .line,
                            path: [CGPoint(x: 50, y: 125), CGPoint(x: 300, y: 125)],
                            color: "#3B82F6",
                            width: 2,
                            dashed: true
                        ),
                        DrawingContent.Guideline(
                            type: .line,
                            path: [CGPoint(x: 50, y: 170), CGPoint(x: 300, y: 170)],
                            color: "#3B82F6",
                            width: 2,
                            dashed: true
                        )
                    ],
                    referenceImage: nil,
                    toolsAllowed: [.pen]
                )),
                validation: ValidationCriteria(
                    minScore: 0.7,
                    maxAttempts: 3,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: true,
                        encouragementThreshold: 0.5
                    ),
                    requiresAllCorrect: false
                ),
                xpValue: 75
            )
        ],
        exercises: [],
        objectives: [
            "Understand proper arm movement for line drawing",
            "Draw straight horizontal lines using guidelines",
            "Practice smooth, confident strokes"
        ],
        tips: [
            "Practice the motion in the air before touching the canvas",
            "Speed can help with smoothness—don't go too slow",
            "Focus on the end point, not the pencil tip"
        ],
        prerequisites: ["lesson_001"],
        unlocks: ["lesson_003"]
    )
    
    // LESSON 3: Drawing Circles (Clean instruction)
    static let beginnerLesson003 = Lesson(
        id: "lesson_003",
        title: "Drawing Circles",
        description: "Learn to draw smooth, confident circles",
        type: .drawingPractice,
        category: .basics,
        difficulty: .beginner,
        estimatedMinutes: 6,
        xpReward: 100,
        steps: [
            LessonStep(
                id: "step_003_1",
                order: 1,
                title: "Circle Practice",
                instruction: "Draw 2 circles using the green guides. Remember: quick, confident motion from your shoulder!",
                content: .drawing(DrawingContent(
                    canvasSize: CGSize(width: 350, height: 250),
                    backgroundColor: "#FFFFFF",
                    guidelines: [
                        DrawingContent.Guideline(
                            type: .circle,
                            path: [CGPoint(x: 120, y: 125), CGPoint(x: 170, y: 125)],
                            color: "#10B981",
                            width: 2,
                            dashed: true
                        ),
                        DrawingContent.Guideline(
                            type: .circle,
                            path: [CGPoint(x: 230, y: 125), CGPoint(x: 280, y: 125)],
                            color: "#10B981",
                            width: 2,
                            dashed: true
                        )
                    ],
                    referenceImage: nil,
                    toolsAllowed: [.pen, .pencil]
                )),
                validation: ValidationCriteria(
                    minScore: 0.6,
                    maxAttempts: 3,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: true,
                        encouragementThreshold: 0.4
                    ),
                    requiresAllCorrect: false
                ),
                xpValue: 100
            )
        ],
        exercises: [],
        objectives: [
            "Understand circle drawing technique",
            "Draw smooth circular motions",
            "Practice confident, quick strokes"
        ],
        tips: [
            "Ghost the motion before touching the canvas",
            "Speed helps with smoothness—trust your arm",
            "Practice circles of different sizes to build muscle memory"
        ],
        prerequisites: ["lesson_002"],
        unlocks: ["lesson_004"]
    )
    
    // LESSON 4: Basic Shapes - Squares (Clear focus)
    static let beginnerLesson004 = Lesson(
        id: "lesson_004",
        title: "Drawing Squares",
        description: "Master drawing squares and rectangles with clean edges",
        type: .drawingPractice,
        category: .basics,
        difficulty: .beginner,
        estimatedMinutes: 5,
        xpReward: 85,
        steps: [
            LessonStep(
                id: "step_004_1",
                order: 1,
                title: "Square Construction",
                instruction: "Practice drawing a square using the rectangular guidelines. Focus on making parallel lines and clean corners.",
                content: .drawing(DrawingContent(
                    canvasSize: CGSize(width: 350, height: 250),
                    backgroundColor: "#FFFFFF",
                    guidelines: [
                        DrawingContent.Guideline(
                            type: .rectangle,
                            path: [CGPoint(x: 125, y: 75), CGPoint(x: 225, y: 175)],
                            color: "#8B5CF6",
                            width: 2,
                            dashed: true
                        )
                    ],
                    referenceImage: nil,
                    toolsAllowed: [.pen]
                )),
                validation: ValidationCriteria(
                    minScore: 0.7,
                    maxAttempts: 3,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: true,
                        encouragementThreshold: 0.5
                    ),
                    requiresAllCorrect: false
                ),
                xpValue: 85
            )
        ],
        exercises: [],
        objectives: [
            "Draw squares with equal sides",
            "Understand parallel lines and right angles",
            "Practice corner construction"
        ],
        tips: [
            "Each side should be the same length",
            "Keep opposite lines parallel",
            "Clean lines matter more than perfect angles"
        ],
        prerequisites: ["lesson_003"],
        unlocks: ["lesson_005"]
    )
    
    // LESSON 5: Creative Challenge (Motivating conclusion)
    static let beginnerLesson005 = Lesson(
        id: "lesson_005",
        title: "Creative Challenge",
        description: "Use everything you've learned to create something amazing!",
        type: .creativeChallenge,
        category: .basics,
        difficulty: .beginner,
        estimatedMinutes: 7,
        xpReward: 150,
        steps: [
            LessonStep(
                id: "step_005_1",
                order: 1,
                title: "Knowledge Check",
                instruction: "Let's review what you've mastered!",
                content: .theory(TheoryContent(
                    question: "Which shapes have you learned to draw?",
                    visualAid: nil,
                    answerType: .multipleChoice,
                    options: [
                        TheoryContent.AnswerOption(id: "1", text: "Straight lines", image: nil),
                        TheoryContent.AnswerOption(id: "2", text: "Circles", image: nil),
                        TheoryContent.AnswerOption(id: "3", text: "Squares", image: nil),
                        TheoryContent.AnswerOption(id: "4", text: "Triangles", image: nil)
                    ],
                    correctAnswers: ["1", "2", "3"],
                    explanation: "Excellent! You've mastered lines, circles, and squares. Triangles are coming next!"
                )),
                validation: ValidationCriteria(
                    minScore: 1.0,
                    maxAttempts: 2,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: false,
                        encouragementThreshold: 1.0
                    ),
                    requiresAllCorrect: true
                ),
                xpValue: 50
            ),
            LessonStep(
                id: "step_005_2",
                order: 2,
                title: "Creative Expression",
                instruction: "Create a simple drawing using only lines, circles, and squares. Let your imagination guide you!",
                content: .challenge(ChallengeContent(
                    challengeType: .freestyle,
                    prompt: "Create something unique using the shapes you've learned",
                    resources: ["Lines", "Circles", "Squares"],
                    constraints: [
                        "time_limit": "300", // 5 minutes
                        "min_shapes": "3"
                    ]
                )),
                validation: ValidationCriteria(
                    minScore: 0.6,
                    maxAttempts: 2,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: false,
                        encouragementThreshold: 0.4
                    ),
                    requiresAllCorrect: false
                ),
                xpValue: 100
            )
        ],
        exercises: [],
        objectives: [
            "Review fundamental shapes learned",
            "Apply knowledge creatively",
            "Build confidence in creative expression"
        ],
        tips: [
            "Combine shapes to create objects like houses, cars, or robots",
            "There's no wrong answer—express yourself freely",
            "Simple can be beautiful—don't overcomplicate"
        ],
        prerequisites: ["lesson_004"],
        unlocks: ["lesson_006"]
    )
    
    // ✅ LESSON 6: Basic Shapes Practice (NEW - Complete Unit 1)
    static let beginnerLesson006 = Lesson(
        id: "lesson_006",
        title: "Basic Shapes Practice",
        description: "Master triangles, ovals, and practice combining all your shapes",
        type: .drawingPractice,
        category: .basics,
        difficulty: .beginner,
        estimatedMinutes: 8,
        xpReward: 120,
        steps: [
            // Step 1: Shape review session (Theory)
            LessonStep(
                id: "step_006_1",
                order: 1,
                title: "Shape Review Session",
                instruction: "Time to review your shape mastery! Which shapes can you confidently draw now?",
                content: .theory(TheoryContent(
                    question: "What makes a good basic shape?",
                    visualAid: nil,
                    answerType: .multipleChoice,
                    options: [
                        TheoryContent.AnswerOption(id: "1", text: "Clean, confident lines", image: nil),
                        TheoryContent.AnswerOption(id: "2", text: "Proper proportions", image: nil),
                        TheoryContent.AnswerOption(id: "3", text: "Consistent stroke weight", image: nil),
                        TheoryContent.AnswerOption(id: "4", text: "Perfect mathematical precision", image: nil)
                    ],
                    correctAnswers: ["1", "2", "3"],
                    explanation: "Great shapes come from confident execution and good proportions, not mathematical perfection!"
                )),
                validation: ValidationCriteria(
                    minScore: 1.0,
                    maxAttempts: 2,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: false,
                        encouragementThreshold: 1.0
                    ),
                    requiresAllCorrect: true
                ),
                xpValue: 20
            ),
            
            // Step 2: Triangle construction (Drawing)
            LessonStep(
                id: "step_006_2",
                order: 2,
                title: "Triangle Construction",
                instruction: "Draw 2 triangles using the orange guides. Connect three points with confident straight lines.",
                content: .drawing(DrawingContent(
                    canvasSize: CGSize(width: 350, height: 250),
                    backgroundColor: "#FFFFFF",
                    guidelines: [
                        // First triangle points
                        DrawingContent.Guideline(
                            type: .line,
                            path: [CGPoint(x: 100, y: 180), CGPoint(x: 140, y: 100)],
                            color: "#F97316",
                            width: 2,
                            dashed: true
                        ),
                        DrawingContent.Guideline(
                            type: .line,
                            path: [CGPoint(x: 140, y: 100), CGPoint(x: 180, y: 180)],
                            color: "#F97316",
                            width: 2,
                            dashed: true
                        ),
                        DrawingContent.Guideline(
                            type: .line,
                            path: [CGPoint(x: 180, y: 180), CGPoint(x: 100, y: 180)],
                            color: "#F97316",
                            width: 2,
                            dashed: true
                        ),
                        // Second triangle points
                        DrawingContent.Guideline(
                            type: .line,
                            path: [CGPoint(x: 220, y: 180), CGPoint(x: 260, y: 100)],
                            color: "#F97316",
                            width: 2,
                            dashed: true
                        ),
                        DrawingContent.Guideline(
                            type: .line,
                            path: [CGPoint(x: 260, y: 100), CGPoint(x: 300, y: 180)],
                            color: "#F97316",
                            width: 2,
                            dashed: true
                        ),
                        DrawingContent.Guideline(
                            type: .line,
                            path: [CGPoint(x: 300, y: 180), CGPoint(x: 220, y: 180)],
                            color: "#F97316",
                            width: 2,
                            dashed: true
                        )
                    ],
                    referenceImage: nil,
                    toolsAllowed: [.pen]
                )),
                validation: ValidationCriteria(
                    minScore: 0.7,
                    maxAttempts: 3,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: true,
                        encouragementThreshold: 0.5
                    ),
                    requiresAllCorrect: false
                ),
                xpValue: 25
            ),
            
            // Step 3: Oval creation (Drawing)
            LessonStep(
                id: "step_006_3",
                order: 3,
                title: "Oval Creation",
                instruction: "Draw 2 ovals using the pink guides. Think of them as stretched circles—keep the motion flowing!",
                content: .drawing(DrawingContent(
                    canvasSize: CGSize(width: 350, height: 250),
                    backgroundColor: "#FFFFFF",
                    guidelines: [
                        // Oval guidelines (represented as rectangles that contain the ovals)
                        DrawingContent.Guideline(
                            type: .rectangle,
                            path: [CGPoint(x: 80, y: 100), CGPoint(x: 150, y: 180)],
                            color: "#EC4899",
                            width: 2,
                            dashed: true
                        ),
                        DrawingContent.Guideline(
                            type: .rectangle,
                            path: [CGPoint(x: 200, y: 100), CGPoint(x: 270, y: 180)],
                            color: "#EC4899",
                            width: 2,
                            dashed: true
                        )
                    ],
                    referenceImage: nil,
                    toolsAllowed: [.pen, .pencil]
                )),
                validation: ValidationCriteria(
                    minScore: 0.6,
                    maxAttempts: 3,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: true,
                        encouragementThreshold: 0.4
                    ),
                    requiresAllCorrect: false
                ),
                xpValue: 25
            ),
            
            // Step 4: Shape accuracy test (Challenge)
            LessonStep(
                id: "step_006_4",
                order: 4,
                title: "Shape Accuracy Test",
                instruction: "Time for a quick test! Draw one perfect example of each shape you've learned—no guides this time!",
                content: .challenge(ChallengeContent(
                    challengeType: .precision,
                    prompt: "Draw: 1 line, 1 circle, 1 square, 1 triangle, and 1 oval",
                    resources: ["Memory", "Confidence", "Practice"],
                    constraints: [
                        "time_limit": "120", // 2 minutes
                        "required_shapes": "5"
                    ]
                )),
                validation: ValidationCriteria(
                    minScore: 0.75,
                    maxAttempts: 2,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: false,
                        encouragementThreshold: 0.6
                    ),
                    requiresAllCorrect: false
                ),
                xpValue: 30
            ),
            
            // Step 5: Shape combination exercise (Drawing)
            LessonStep(
                id: "step_006_5",
                order: 5,
                title: "Shape Combination Exercise",
                instruction: "Create a simple house using all your shapes: squares, triangles, circles, lines, and ovals. Be creative!",
                content: .drawing(DrawingContent(
                    canvasSize: CGSize(width: 350, height: 300),
                    backgroundColor: "#FFFFFF",
                    guidelines: [],
                    referenceImage: nil,
                    toolsAllowed: [.pen, .pencil]
                )),
                validation: ValidationCriteria(
                    minScore: 0.5,
                    maxAttempts: 3,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: false,
                        encouragementThreshold: 0.3
                    ),
                    requiresAllCorrect: false
                ),
                xpValue: 30
            ),
            
            // Step 6: Progress reflection (Theory)
            LessonStep(
                id: "step_006_6",
                order: 6,
                title: "Progress Reflection",
                instruction: "Congratulations! You've completed Unit 1. What's your biggest achievement so far?",
                content: .theory(TheoryContent(
                    question: "You've now mastered the fundamental building blocks of drawing. What's next?",
                    visualAid: nil,
                    answerType: .singleChoice,
                    options: [
                        TheoryContent.AnswerOption(id: "1", text: "Practice combining shapes into objects", image: nil),
                        TheoryContent.AnswerOption(id: "2", text: "Learn more complex geometric shapes", image: nil),
                        TheoryContent.AnswerOption(id: "3", text: "Start over with the basics", image: nil),
                        TheoryContent.AnswerOption(id: "4", text: "Move to advanced techniques immediately", image: nil)
                    ],
                    correctAnswers: ["1"],
                    explanation: "Perfect! Unit 2 will focus on mastering more shapes and combining them effectively. You're building a strong foundation!"
                )),
                validation: ValidationCriteria(
                    minScore: 1.0,
                    maxAttempts: 1,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: false,
                        encouragementThreshold: 1.0
                    ),
                    requiresAllCorrect: true
                ),
                xpValue: 10
            )
        ],
        exercises: [],
        objectives: [
            "Master triangle and oval construction",
            "Combine all learned shapes effectively",
            "Complete Unit 1 with confidence",
            "Prepare for more advanced shape work"
        ],
        tips: [
            "Triangles: Connect three points with confident straight lines",
            "Ovals: Like circles, but stretched—keep the motion flowing",
            "Combining shapes: Think about how objects break down into basic shapes",
            "You've built an excellent foundation—be proud of your progress!"
        ],
        prerequisites: ["lesson_005"],
        unlocks: ["lesson_007"] // This will unlock Unit 2
    )
}
