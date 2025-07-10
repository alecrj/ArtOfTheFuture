import Foundation

class MockDataService {
    static let shared = MockDataService()
    
    private init() {}
    
    func getMockLessons() -> [Lesson] {
        [
            Lesson(
                id: "1",
                title: "Drawing Basic Shapes",
                description: "Learn to draw circles, squares, and triangles with confidence",
                type: .drawingPractice, // FIXED: was .practice
                category: .basics,
                difficulty: .beginner,
                estimatedMinutes: 10,
                xpReward: 50,
                steps: [],
                exercises: [], // FIXED: Added missing exercises parameter
                objectives: [],
                tips: [],
                prerequisites: [],
                unlocks: []
            ),
            Lesson(
                id: "2",
                title: "Line Control",
                description: "Master straight lines, curves, and smooth strokes",
                type: .drawingPractice, // FIXED: was .practice
                category: .basics,
                difficulty: .beginner,
                estimatedMinutes: 15,
                xpReward: 75,
                steps: [],
                exercises: [], // FIXED: Added missing exercises parameter
                objectives: [],
                tips: [],
                prerequisites: [],
                unlocks: []
            ),
            Lesson(
                id: "3",
                title: "Basic Shading",
                description: "Introduction to light, shadow, and gradients",
                type: .drawingPractice, // FIXED: was .practice
                category: .shading,
                difficulty: .beginner,
                estimatedMinutes: 20,
                xpReward: 100,
                steps: [],
                exercises: [], // FIXED: Added missing exercises parameter
                objectives: [],
                tips: [],
                prerequisites: [],
                unlocks: []
            )
        ]
    }
    
    func getMockUser() -> User {
        User(
            id: "mock-user-1",
            displayName: "Art Learner",
            email: "learner@artofthefuture.app",
            totalXP: 125,
            currentLevel: 2,
            currentStreak: 3
        )
    }
}
