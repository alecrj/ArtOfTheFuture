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
                category: .basics,
                difficulty: .beginner,
                estimatedMinutes: 10,
                xpReward: 50,
                isLocked: false
            ),
            Lesson(
                id: "2",
                title: "Line Control",
                description: "Master straight lines, curves, and smooth strokes",
                category: .basics,
                difficulty: .beginner,
                estimatedMinutes: 15,
                xpReward: 75,
                isLocked: false
            ),
            Lesson(
                id: "3",
                title: "Basic Shading",
                description: "Introduction to light, shadow, and gradients",
                category: .shading,
                difficulty: .beginner,
                estimatedMinutes: 20,
                xpReward: 100,
                isLocked: true
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
