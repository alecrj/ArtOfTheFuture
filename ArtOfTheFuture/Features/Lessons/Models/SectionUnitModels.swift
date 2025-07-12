// MARK: - Fixed Section and Unit Models (Working with Existing Structure)
// File: ArtOfTheFuture/Features/Lessons/Models/SectionUnitModels.swift
// REPLACE your existing SectionUnitModels.swift with this fixed version

import Foundation
import SwiftUI



// MARK: - Section Model (Top Level - 3 Sections) - Now Hashable
struct Section: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let order: Int
    let difficulty: DifficultyLevel
    let estimatedHours: Int
    let xpReward: Int
    
    // Visual Design
    let iconName: String
    let colorTheme: String
    let backgroundGradient: [String]
    
    // Content Organization
    let units: [Unit]
    let prerequisites: [String] // Section IDs
    let unlocks: [String] // Section IDs
    
    // Learning Objectives
    let objectives: [String]
    let skills: [String]
    let finalProject: String?
    
    // Computed Properties
    var totalUnits: Int { units.count }
    var totalLessons: Int { units.reduce(0) { $0 + $1.totalLessons } }
    var totalXP: Int { units.reduce(0) { $0 + $1.totalXP } + xpReward }
    var color: Color {
        switch colorTheme {
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "orange": return .orange
        case "red": return .red
        case "indigo": return .indigo
        default: return .blue
        }
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Section, rhs: Section) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Unit Model (Mid Level - 6-8 Units per Section) - Now Hashable
struct Unit: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let order: Int
    let sectionId: String
    let estimatedMinutes: Int
    let xpReward: Int
    
    // Visual Design
    let iconName: String
    let colorHex: String
    
    // Content Organization
    let lessonIds: [String] // References to existing Lesson.id
    let prerequisites: [String] // Unit IDs
    let unlocks: [String] // Unit IDs
    
    // Learning Structure
    let objectives: [String]
    let skills: [UnitSkill]
    let challengeType: UnitChallengeType
    let finalChallenge: UnitChallenge?
    
    // Computed Properties
    var totalLessons: Int { lessonIds.count }
    var totalXP: Int {
        // Will calculate from lessons when they exist
        return xpReward
    }
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Unit, rhs: Unit) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Unit Skills & Challenges
struct UnitSkill: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let iconName: String
    let category: LessonCategory
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum UnitChallengeType: String, Codable, CaseIterable {
    case drawing = "Drawing Challenge"
    case creative = "Creative Challenge"
    case technical = "Technical Challenge"
    case portfolio = "Portfolio Piece"
    
    var iconName: String {
        switch self {
        case .drawing: return "pencil.and.outline"
        case .creative: return "sparkles"
        case .technical: return "gearshape.fill"
        case .portfolio: return "folder.badge.plus"
        }
    }
}

struct UnitChallenge: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let type: UnitChallengeType
    let instructions: [String]
    let timeLimit: Int? // in minutes
    let xpReward: Int
    let requirements: [ChallengeRequirement]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ChallengeRequirement: Codable, Hashable {
    let id: String
    let description: String
    let isRequired: Bool
    let points: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Progress Models for Sections & Units
struct SectionProgress: Identifiable, Codable {
    let id: String
    let sectionId: String
    var isStarted: Bool = false
    var isCompleted: Bool = false
    var completionDate: Date?
    var unitsCompleted: Set<String> = []
    var totalTimeSpent: TimeInterval = 0
    var bestScore: Double = 0
    var attempts: Int = 0
    var lastActivityDate: Date?
    
    // Computed Properties
    var completionPercentage: Double {
        guard let section = LearningPath.shared.getSection(id: sectionId) else { return 0 }
        return Double(unitsCompleted.count) / Double(section.totalUnits)
    }
    
    var isUnlocked: Bool {
        // Logic will be implemented in service
        return true
    }
}

struct UnitProgress: Identifiable, Codable {
    let id: String
    let unitId: String
    var isStarted: Bool = false
    var isCompleted: Bool = false
    var completionDate: Date?
    var lessonsCompleted: Set<String> = []
    var totalTimeSpent: TimeInterval = 0
    var bestScore: Double = 0
    var attempts: Int = 0
    var lastActivityDate: Date?
    var challengeCompleted: Bool = false
    var challengeScore: Double = 0
    
    // Computed Properties
    var completionPercentage: Double {
        guard let unit = LearningPath.shared.getUnit(id: unitId) else { return 0 }
        return Double(lessonsCompleted.count) / Double(unit.totalLessons)
    }
    
    var isUnlocked: Bool {
        // Logic will be implemented in service
        return true
    }
}

// MARK: - Learning Path Structure
class LearningPath: ObservableObject {
    static let shared = LearningPath()
    
    @Published var sections: [Section] = []
    @Published var allUnits: [Unit] = []
    
    private init() {
        loadLearningPath()
    }
    
    private func loadLearningPath() {
        self.sections = Curriculum.allSections
        self.allUnits = sections.flatMap { $0.units }
    }
    
    // MARK: - Lookup Methods
    func getSection(id: String) -> Section? {
        return sections.first { $0.id == id }
    }
    
    func getUnit(id: String) -> Unit? {
        return allUnits.first { $0.id == id }
    }
    
    func getUnitsForSection(sectionId: String) -> [Unit] {
        return allUnits.filter { $0.sectionId == sectionId }
    }
    
    func getLessonsForUnit(unitId: String) -> [Lesson] {
        guard let unit = getUnit(id: unitId) else { return [] }
        return unit.lessonIds.compactMap { lessonId in
            Curriculum.allLessons.first { $0.id == lessonId }
        }
    }
    
    // MARK: - Navigation Helpers
    func getNextSection(after sectionId: String) -> Section? {
        guard let currentIndex = sections.firstIndex(where: { $0.id == sectionId }),
              currentIndex + 1 < sections.count else { return nil }
        return sections[currentIndex + 1]
    }
    
    func getNextUnit(after unitId: String) -> Unit? {
        guard let unit = getUnit(id: unitId),
              let section = getSection(id: unit.sectionId),
              let currentIndex = section.units.firstIndex(where: { $0.id == unitId }),
              currentIndex + 1 < section.units.count else { return nil }
        return section.units[currentIndex + 1]
    }
    
    func getPreviousUnit(before unitId: String) -> Unit? {
        guard let unit = getUnit(id: unitId),
              let section = getSection(id: unit.sectionId),
              let currentIndex = section.units.firstIndex(where: { $0.id == unitId }),
              currentIndex > 0 else { return nil }
        return section.units[currentIndex - 1]
    }
}

// MARK: - Color Extension for Hex Support
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
