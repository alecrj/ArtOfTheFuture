// MARK: - Clean Lessons Curriculum (NO HINTS - Duolingo Style)
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
        beginnerLesson005
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
    
    // LESSON 1: Welcome & Introduction (Cleaner without hints)
    static let beginnerLesson001 = Lesson(
        id: "lesson_001",
        title: "Welcome to Drawing!",
        description: "Learn the basics of digital drawing and get started with your first strokes",
        type: .drawingPractice,
        category: .basics,
        difficulty: .beginner,
        estimatedMinutes: 3,
        xpReward: 50,
        steps: [
            LessonStep(
                id: "step_001_1",
                order: 1,
                title: "Welcome, Artist!",
                instruction: "Ready to start your artistic journey? Let's begin with the fundamentals of digital drawing!",
                content: .introduction(IntroContent(
                    displayImage: nil,
                    animationName: nil,
                    bulletPoints: [
                        "Hold your Apple Pencil naturally and comfortably",
                        "Start with simple shapes and practice basic strokes",
                        "Focus on smooth, confident movements",
                        "Don't worry about perfection—practice makes progress!"
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
                    requiresAllCorrect: true
                ),
                xpValue: 25
            ),
            LessonStep(
                id: "step_001_2",
                order: 2,
                title: "Your First Drawing",
                instruction: "Try making some marks on the white canvas below. Draw anything you like—there's no wrong way to start!",
                content: .drawing(DrawingContent(
                    canvasSize: CGSize(width: 350, height: 250),
                    backgroundColor: "#FFFFFF",
                    guidelines: nil,
                    referenceImage: nil,
                    toolsAllowed: [.pen, .pencil]
                )),
                validation: ValidationCriteria(
                    minScore: 0.5,
                    maxAttempts: 1,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: false,
                        encouragementThreshold: 0.3
                    ),
                    requiresAllCorrect: false
                ),
                xpValue: 25
            )
        ],
        exercises: [],
        objectives: [
            "Get comfortable with digital drawing tools",
            "Make your first marks on the canvas",
            "Build confidence with the drawing interface"
        ],
        tips: [
            "Relax and have fun with your first drawing",
            "Every artist started with a single line",
            "Regular practice is the key to improvement"
        ],
        prerequisites: [],
        unlocks: ["lesson_002"]
    )
    
    // LESSON 2: Drawing Straight Lines (Clear instruction focus)
    static let beginnerLesson002 = Lesson(
        id: "lesson_002",
        title: "Drawing Straight Lines",
        description: "Master the fundamental skill of drawing confident, straight lines",
        type: .drawingPractice,
        category: .basics,
        difficulty: .beginner,
        estimatedMinutes: 5,
        xpReward: 75,
        steps: [
            LessonStep(
                id: "step_002_1",
                order: 1,
                title: "Line Drawing Technique",
                instruction: "What's the secret to drawing straight lines?",
                content: .theory(TheoryContent(
                    question: "Which technique helps you draw straighter lines?",
                    visualAid: nil,
                    answerType: .singleChoice,
                    options: [
                        TheoryContent.AnswerOption(
                            id: "opt1",
                            text: "Drawing very slowly and carefully",
                            image: nil
                        ),
                        TheoryContent.AnswerOption(
                            id: "opt2",
                            text: "Using your whole arm, not just your wrist",
                            image: nil
                        ),
                        TheoryContent.AnswerOption(
                            id: "opt3",
                            text: "Pressing harder on the pencil",
                            image: nil
                        )
                    ],
                    correctAnswers: ["opt2"],
                    explanation: "Using your whole arm creates smoother, more controlled lines than just using your wrist!"
                )),
                validation: ValidationCriteria(
                    minScore: 1.0,
                    maxAttempts: 2,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: true,
                        encouragementThreshold: 1.0
                    ),
                    requiresAllCorrect: true
                ),
                xpValue: 25
            ),
            LessonStep(
                id: "step_002_2",
                order: 2,
                title: "Practice Horizontal Lines",
                instruction: "Now let's practice! Draw 3 horizontal lines across the canvas using the blue guidelines. Use your shoulder and arm for smooth motion.",
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
                xpValue: 50
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
                title: "Circle Technique",
                instruction: "What's the best way to draw a circle?",
                content: .theory(TheoryContent(
                    question: "Which approach works best for drawing smooth circles?",
                    visualAid: nil,
                    answerType: .singleChoice,
                    options: [
                        TheoryContent.AnswerOption(
                            id: "opt1",
                            text: "Draw very slowly and carefully",
                            image: nil
                        ),
                        TheoryContent.AnswerOption(
                            id: "opt2",
                            text: "Draw quickly in one smooth motion",
                            image: nil
                        ),
                        TheoryContent.AnswerOption(
                            id: "opt3",
                            text: "Draw in small segments",
                            image: nil
                        )
                    ],
                    correctAnswers: ["opt2"],
                    explanation: "Quick, confident circular motions create smoother circles than slow, careful drawing!"
                )),
                validation: ValidationCriteria(
                    minScore: 1.0,
                    maxAttempts: 2,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: true,
                        encouragementThreshold: 1.0
                    ),
                    requiresAllCorrect: true
                ),
                xpValue: 30
            ),
            LessonStep(
                id: "step_003_2",
                order: 2,
                title: "Practice Circles",
                instruction: "Draw 2 circles using the circular guidelines. Remember: quick, confident motion from your shoulder!",
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
                xpValue: 70
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
                    explanation: "Excellent! You've mastered lines, circles, and squares. Triangles are coming in future lessons!"
                )),
                validation: ValidationCriteria(
                    minScore: 1.0,
                    maxAttempts: 2,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: true,
                        encouragementThreshold: 1.0
                    ),
                    requiresAllCorrect: true
                ),
                xpValue: 50
            ),
            LessonStep(
                id: "step_005_2",
                order: 2,
                title: "Create Your Masterpiece",
                instruction: "Now it's time to create! Use lines, circles, and squares to draw anything you want. Maybe a house, a face, or something completely abstract. Let your creativity flow!",
                content: .challenge(ChallengeContent(
                    challengeType: .freestyle,
                    prompt: "Combine lines, circles, and squares to create your first masterpiece!",
                    resources: [],
                    constraints: nil
                )),
                validation: ValidationCriteria(
                    minScore: 0.5,
                    maxAttempts: 1,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: false,
                        encouragementThreshold: 0.3
                    ),
                    requiresAllCorrect: false
                ),
                xpValue: 100
            )
        ],
        exercises: [],
        objectives: [
            "Apply all learned techniques in one drawing",
            "Practice creative thinking and composition",
            "Build confidence in your artistic abilities"
        ],
        tips: [
            "Use what you've learned in creative combinations",
            "There's no wrong answer in creative challenges",
            "Creativity is more important than perfection"
        ],
        prerequisites: ["lesson_004"],
        unlocks: []
    )
}
