import Foundation

struct Lesson: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let category: LessonCategory
    let difficulty: Difficulty
    let estimatedMinutes: Int
    let xpReward: Int
    var isCompleted: Bool = false
    var isLocked: Bool = true
    
    enum LessonCategory: String, Codable, CaseIterable {
        case basics = "Basics"
        case sketching = "Sketching"
        case coloring = "Coloring"
        case shading = "Shading"
        case perspective = "Perspective"
        case portrait = "Portrait"
        case landscape = "Landscape"
    }
    
    enum Difficulty: String, Codable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
    }
}
