// MARK: - Lessons Curriculum
// File: ArtOfTheFuture/Features/Lessons/Data/LessonsCurriculum.swift
// SINGLE SOURCE OF TRUTH for all curriculum content

import Foundation
import SwiftUI

struct Curriculum {
    
    // MARK: - All Lessons
    static let allLessons: [Lesson] = [
        // Beginner Lessons
        beginnerLesson001,
        beginnerLesson002,
        beginnerLesson003,
        
        // Theory Lessons
        theoryLesson001,
        
        // Challenge Lessons
        challengeLesson001
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

// MARK: - Lesson Definitions
extension Curriculum {
    
    static let beginnerLesson001 = Lesson(
        id: "lesson_001",
        title: "Drawing Straight Lines",
        description: "Master the fundamental skill of drawing confident, straight lines",
        type: .practice,
        category: .basics,
        difficulty: .beginner,
        estimatedMinutes: 5,
        xpReward: 50,
        steps: [
            LessonStep(
                id: "step_001_1",
                order: 1,
                title: "Introduction to Line Drawing",
                instruction: "Learn the basics of holding your pencil and drawing straight lines",
                content: .introduction(IntroContent(
                    displayImage: "line_drawing_intro",
                    animationName: nil,
                    bulletPoints: [
                        "Hold your pencil with a relaxed grip",
                        "Use your whole arm, not just your wrist",
                        "Practice smooth, confident strokes"
                    ]
                )),
                validation: ValidationCriteria(
                    minScore: 1.0,
                    maxAttempts: 1,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: false,
                        showHints: false,
                        encouragementThreshold: 1.0
                    ),
                    requiresAllCorrect: true
                ),
                hints: [],
                xpValue: 10
            ),
            LessonStep(
                id: "step_001_2",
                order: 2,
                title: "Practice Horizontal Lines",
                instruction: "Draw 5 horizontal lines across the canvas",
                content: .drawing(DrawingContent(
                    canvasSize: CGSize(width: 400, height: 300),
                    backgroundColor: "#FFFFFF",
                    guidelines: [
                        DrawingContent.Guideline(
                            type: .line,
                            path: [CGPoint(x: 50, y: 100), CGPoint(x: 350, y: 100)],
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
                        showHints: true,
                        encouragementThreshold: 0.5
                    ),
                    requiresAllCorrect: false
                ),
                hints: ["Keep your hand steady", "Draw slowly and deliberately"],
                xpValue: 25
            ),
            LessonStep(
                id: "step_001_3",
                order: 3,
                title: "Practice Vertical Lines",
                instruction: "Draw 5 vertical lines from top to bottom",
                content: .drawing(DrawingContent(
                    canvasSize: CGSize(width: 400, height: 300),
                    backgroundColor: "#FFFFFF",
                    guidelines: [
                        DrawingContent.Guideline(
                            type: .line,
                            path: [CGPoint(x: 200, y: 50), CGPoint(x: 200, y: 250)],
                            color: "#10B981",
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
                        showHints: true,
                        encouragementThreshold: 0.5
                    ),
                    requiresAllCorrect: false
                ),
                hints: ["Use your shoulder, not your wrist", "Practice the motion in the air first"],
                xpValue: 15
            )
        ],
        objectives: [
            "Draw straight horizontal lines",
            "Draw straight vertical lines",
            "Understand proper pencil grip"
        ],
        tips: [
            "Relax your grip on the pencil",
            "Use your shoulder and elbow for longer lines",
            "Practice makes perfect"
        ],
        prerequisites: [],
        unlocks: ["lesson_002"]
    )
    
    static let beginnerLesson002 = Lesson(
        id: "lesson_002",
        title: "Basic Shapes: Circles",
        description: "Learn to draw perfect circles with confidence",
        type: .practice,
        category: .basics,
        difficulty: .beginner,
        estimatedMinutes: 8,
        xpReward: 75,
        steps: [
            LessonStep(
                id: "step_002_1",
                order: 1,
                title: "Circle Theory",
                instruction: "What makes a good circle?",
                content: .theory(TheoryContent(
                    question: "Which technique helps draw smoother circles?",
                    visualAid: "circle_techniques",
                    answerType: .singleChoice,
                    options: [
                        TheoryContent.AnswerOption(
                            id: "opt1",
                            text: "Drawing very slowly",
                            image: nil
                        ),
                        TheoryContent.AnswerOption(
                            id: "opt2",
                            text: "Using shoulder movement",
                            image: nil
                        ),
                        TheoryContent.AnswerOption(
                            id: "opt3",
                            text: "Drawing with fingers only",
                            image: nil
                        )
                    ],
                    correctAnswers: ["opt2"],
                    explanation: "Using your shoulder creates smoother, more controlled circular motions"
                )),
                validation: ValidationCriteria(
                    minScore: 1.0,
                    maxAttempts: 2,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: true,
                        showHints: false,
                        encouragementThreshold: 1.0
                    ),
                    requiresAllCorrect: true
                ),
                hints: ["Think about the motion your arm makes"],
                xpValue: 20
            ),
            LessonStep(
                id: "step_002_2",
                order: 2,
                title: "Practice Circles",
                instruction: "Draw 3 circles using the guidelines",
                content: .drawing(DrawingContent(
                    canvasSize: CGSize(width: 400, height: 300),
                    backgroundColor: "#FFFFFF",
                    guidelines: [
                        DrawingContent.Guideline(
                            type: .circle,
                            path: [CGPoint(x: 150, y: 150), CGPoint(x: 200, y: 150)],
                            color: "#F59E0B",
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
                        showHints: true,
                        encouragementThreshold: 0.4
                    ),
                    requiresAllCorrect: false
                ),
                hints: ["Move from your shoulder", "Don't worry about perfection"],
                xpValue: 30
            )
        ],
        objectives: [
            "Understand circle drawing technique",
            "Draw circles using shoulder movement",
            "Practice consistent circular motions"
        ],
        tips: [
            "Ghost the motion before touching paper",
            "Speed helps with smoothness",
            "Practice circles of different sizes"
        ],
        prerequisites: ["lesson_001"],
        unlocks: ["lesson_003"]
    )
    
    static let beginnerLesson003 = Lesson(
        id: "lesson_003",
        title: "Basic Shapes: Squares",
        description: "Master drawing squares and rectangles with clean edges",
        type: .practice,
        category: .basics,
        difficulty: .beginner,
        estimatedMinutes: 6,
        xpReward: 60,
        steps: [
            LessonStep(
                id: "step_003_1",
                order: 1,
                title: "Square Construction",
                instruction: "Practice drawing squares with equal sides",
                content: .drawing(DrawingContent(
                    canvasSize: CGSize(width: 400, height: 300),
                    backgroundColor: "#FFFFFF",
                    guidelines: [
                        DrawingContent.Guideline(
                            type: .rectangle,
                            path: [CGPoint(x: 150, y: 100), CGPoint(x: 250, y: 200)],
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
                        showHints: true,
                        encouragementThreshold: 0.5
                    ),
                    requiresAllCorrect: false
                ),
                hints: ["Focus on parallel lines", "Check your corners"],
                xpValue: 35
            )
        ],
        objectives: [
            "Draw squares with equal sides",
            "Understand parallel lines",
            "Practice corner construction"
        ],
        tips: [
            "Use construction lines first",
            "Check proportions frequently",
            "Clean lines matter more than perfect angles"
        ],
        prerequisites: ["lesson_002"],
        unlocks: ["theory_001"]
    )
    
    static let theoryLesson001 = Lesson(
        id: "theory_001",
        title: "Drawing Fundamentals",
        description: "Learn the core principles that guide all good drawings",
        type: .theory,
        category: .theory,
        difficulty: .beginner,
        estimatedMinutes: 4,
        xpReward: 40,
        steps: [
            LessonStep(
                id: "step_theory_001_1",
                order: 1,
                title: "Elements of Art",
                instruction: "Identify the basic elements that make up all drawings",
                content: .theory(TheoryContent(
                    question: "Which of these are the fundamental elements of art?",
                    visualAid: "elements_of_art",
                    answerType: .multipleChoice,
                    options: [
                        TheoryContent.AnswerOption(id: "1", text: "Line", image: nil),
                        TheoryContent.AnswerOption(id: "2", text: "Shape", image: nil),
                        TheoryContent.AnswerOption(id: "3", text: "Form", image: nil),
                        TheoryContent.AnswerOption(id: "4", text: "Value", image: nil),
                        TheoryContent.AnswerOption(id: "5", text: "Space", image: nil),
                        TheoryContent.AnswerOption(id: "6", text: "Color", image: nil)
                    ],
                    correctAnswers: ["1", "2", "3", "4", "5"],
                    explanation: "Line, shape, form, value, and space are the fundamental elements of art"
                )),
                validation: ValidationCriteria(
                    minScore: 0.8,
                    maxAttempts: 2,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: true,
                        showHints: true,
                        encouragementThreshold: 0.6
                    ),
                    requiresAllCorrect: false
                ),
                hints: ["Think about the building blocks of visual art"],
                xpValue: 40
            )
        ],
        objectives: [
            "Understand the elements of art",
            "Build artistic vocabulary",
            "Apply theory to practice"
        ],
        tips: [
            "Look for these elements in artwork around you",
            "Every drawing uses these principles",
            "Theory improves your practical skills"
        ],
        prerequisites: ["lesson_003"],
        unlocks: ["challenge_001"]
    )
    
    static let challengeLesson001 = Lesson(
        id: "challenge_001",
        title: "Creative Shape Challenge",
        description: "Transform basic shapes into creative drawings",
        type: .challenge,
        category: .basics,
        difficulty: .beginner,
        estimatedMinutes: 10,
        xpReward: 100,
        steps: [
            LessonStep(
                id: "step_challenge_001_1",
                order: 1,
                title: "Shape Transformation",
                instruction: "Turn this circle into something creative",
                content: .challenge(ChallengeContent(
                    challengeType: .freestyle,
                    prompt: "Use this circle as a starting point to create anything you want!",
                    resources: ["circle_template"],
                    constraints: ["timeLimit": "300"] // 5 minutes
                )),
                validation: ValidationCriteria(
                    minScore: 0.5,
                    maxAttempts: 1,
                    rules: [],
                    feedback: ValidationCriteria.FeedbackConfig(
                        showRealtime: false,
                        showHints: false,
                        encouragementThreshold: 0.3
                    ),
                    requiresAllCorrect: false
                ),
                hints: ["Think outside the box!", "There's no wrong answer"],
                xpValue: 100
            )
        ],
        objectives: [
            "Practice creative thinking",
            "Apply basic shapes creatively",
            "Build drawing confidence"
        ],
        tips: [
            "Don't overthink it",
            "Simple additions can transform shapes",
            "Have fun with it!"
        ],
        prerequisites: ["theory_001"],
        unlocks: []
    )
}
