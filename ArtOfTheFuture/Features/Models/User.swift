import Foundation

struct User: Identifiable, Codable {
    let id: String
    var displayName: String
    var email: String?
    var profileImageURL: String?
    var totalXP: Int = 0
    var currentLevel: Int = 1
    var currentStreak: Int = 0
    var joinedDate: Date = Date()
    
    var levelProgress: Double {
        // XP needed per level increases by 100 each level
        let xpForCurrentLevel = (currentLevel - 1) * 100
        let xpForNextLevel = currentLevel * 100
        let currentLevelXP = totalXP - xpForCurrentLevel
        return Double(currentLevelXP) / Double(xpForNextLevel - xpForCurrentLevel)
    }
}
