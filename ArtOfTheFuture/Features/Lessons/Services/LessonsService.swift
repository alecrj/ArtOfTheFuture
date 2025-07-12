// MARK: - Enhanced Lessons Service (REPLACE your existing LessonsService.swift)
// File: ArtOfTheFuture/Features/Lessons/Services/LessonsService.swift

import Foundation
import Combine


// MARK: - Lesson Service Protocol (FIXED)
protocol LessonServiceProtocol {
    func getAllLessons() async throws -> [Lesson]
    func getLesson(id: String) async throws -> Lesson?
    func getLessonsForUser() async throws -> [Lesson]
    func getUnlockedLessons(for profile: UserProfile) -> Set<String>
    func checkPrerequisites(for lessonId: String, profile: UserProfile) -> Bool
    
    // Section & Unit Methods
    func getAllSections() async throws -> [Section]
    func getSection(id: String) async throws -> Section?
    func getSectionProgress(sectionId: String) async throws -> SectionProgress?
    func getUnlockedSections(for profile: UserProfile) -> Set<String>
    
    func getUnitsForSection(sectionId: String) async throws -> [Unit]
    func getUnit(id: String) async throws -> Unit?
    func getUnitProgress(unitId: String) async throws -> UnitProgress?
    func getUnlockedUnits(for profile: UserProfile) -> Set<String>
    
    func getLessonsForUnit(unitId: String) async throws -> [Lesson]
    func getUnitForLesson(lessonId: String) -> Unit?
}

// MARK: - Enhanced Lesson Service Implementation
final class LessonService: LessonServiceProtocol, ObservableObject {
    static let shared = LessonService()
    
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // Progress tracking keys
    private let sectionProgressPrefix = "section_progress_"
    private let unitProgressPrefix = "unit_progress_"
    
    @Published var currentSection: Section?
    @Published var currentUnit: Unit?
    
    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Original Lesson Methods
    func getAllLessons() async throws -> [Lesson] {
        return Curriculum.allLessons
    }
    
    func getLesson(id: String) async throws -> Lesson? {
        return Curriculum.allLessons.first { $0.id == id }
    }
    
    func getLessonsForUser() async throws -> [Lesson] {
        return try await getAllLessons()
    }
    
    func getUnlockedLessons(for profile: UserProfile) -> Set<String> {
        var unlocked = profile.unlockedLessons
        
        for lesson in Curriculum.allLessons {
            if checkPrerequisites(for: lesson.id, profile: profile) {
                unlocked.insert(lesson.id)
            }
        }
        
        return unlocked
    }
    
    func checkPrerequisites(for lessonId: String, profile: UserProfile) -> Bool {
        guard let lesson = Curriculum.allLessons.first(where: { $0.id == lessonId }) else {
            return false
        }
        
        if lesson.prerequisites.isEmpty {
            return true
        }
        
        return lesson.prerequisites.allSatisfy { prerequisiteId in
            profile.completedLessons.contains(prerequisiteId)
        }
    }
    
    // MARK: - Section Management
    func getAllSections() async throws -> [Section] {
        return Curriculum.allSections
    }
    
    func getSection(id: String) async throws -> Section? {
        return Curriculum.allSections.first { $0.id == id }
    }
    
    func getSectionProgress(sectionId: String) async throws -> SectionProgress? {
        let key = sectionProgressPrefix + sectionId
        
        guard let data = userDefaults.data(forKey: key) else {
            return SectionProgress(id: UUID().uuidString, sectionId: sectionId)
        }
        
        return try decoder.decode(SectionProgress.self, from: data)
    }
    
    func getUnlockedSections(for profile: UserProfile) -> Set<String> {
        var unlockedSections = Set<String>()
        
        // First section is always unlocked
        if let firstSection = Curriculum.allSections.first {
            unlockedSections.insert(firstSection.id)
        }
        
        // Check each section's prerequisites
        for section in Curriculum.allSections {
            if section.prerequisites.isEmpty {
                unlockedSections.insert(section.id)
            } else {
                let prerequisitesMet = section.prerequisites.allSatisfy { prerequisiteId in
                    // Check if prerequisite section is completed
                    Task {
                        if let sectionProgress = try? await getSectionProgress(sectionId: prerequisiteId) {
                            return sectionProgress.isCompleted
                        }
                        return false
                    }
                    return false // Simplified for now
                }
                
                if prerequisitesMet {
                    unlockedSections.insert(section.id)
                }
            }
        }
        
        return unlockedSections
    }
    
    // MARK: - Unit Management
    func getUnitsForSection(sectionId: String) async throws -> [Unit] {
        guard let section = try await getSection(id: sectionId) else {
            return []
        }
        return section.units
    }
    
    func getUnit(id: String) async throws -> Unit? {
        return Curriculum.allUnits.first { $0.id == id }
    }
    
    func getUnitProgress(unitId: String) async throws -> UnitProgress? {
        let key = unitProgressPrefix + unitId
        
        guard let data = userDefaults.data(forKey: key) else {
            return UnitProgress(id: UUID().uuidString, unitId: unitId)
        }
        
        return try decoder.decode(UnitProgress.self, from: data)
    }
    
    func getUnlockedUnits(for profile: UserProfile) -> Set<String> {
        var unlockedUnits = Set<String>()
        
        // Get unlocked sections first
        let unlockedSections = getUnlockedSections(for: profile)
        
        for sectionId in unlockedSections {
            guard let section = Curriculum.allSections.first(where: { $0.id == sectionId }) else { continue }
            
            // First unit in each unlocked section is available
            if let firstUnit = section.units.first {
                unlockedUnits.insert(firstUnit.id)
            }
            
            // Check unit prerequisites within section
            for unit in section.units {
                if unit.prerequisites.isEmpty {
                    unlockedUnits.insert(unit.id)
                } else {
                    let prerequisitesMet = unit.prerequisites.allSatisfy { prerequisiteUnitId in
                        Task {
                            if let unitProgress = try? await getUnitProgress(unitId: prerequisiteUnitId) {
                                return unitProgress.isCompleted
                            }
                            return false
                        }
                        return false // Simplified for now
                    }
                    
                    if prerequisitesMet {
                        unlockedUnits.insert(unit.id)
                    }
                }
            }
        }
        
        return unlockedUnits
    }
    
    // MARK: - Lesson-Unit Integration
    func getLessonsForUnit(unitId: String) async throws -> [Lesson] {
        guard let unit = try await getUnit(id: unitId) else { return [] }
        return unit.lessonIds.compactMap { lessonId in
            Curriculum.allLessons.first { $0.id == lessonId }
        }
    }
    
    func getUnitForLesson(lessonId: String) -> Unit? {
        return Curriculum.allUnits.first { unit in
            unit.lessonIds.contains(lessonId)
        }
    }
    
    // MARK: - Progress Management
    func updateSectionProgress(sectionId: String, progress: SectionProgress) async throws {
        let key = sectionProgressPrefix + sectionId
        let data = try encoder.encode(progress)
        userDefaults.set(data, forKey: key)
        
        print("📊 Updated section progress for \(sectionId)")
    }
    
    func updateUnitProgress(unitId: String, progress: UnitProgress) async throws {
        let key = unitProgressPrefix + unitId
        let data = try encoder.encode(progress)
        userDefaults.set(data, forKey: key)
        
        print("📊 Updated unit progress for \(unitId)")
    }
    
    func completeUnit(unitId: String) async throws {
        var unitProgress = try await getUnitProgress(unitId: unitId) ?? UnitProgress(id: UUID().uuidString, unitId: unitId)
        
        unitProgress.isCompleted = true
        unitProgress.completionDate = Date()
        unitProgress.lastActivityDate = Date()
        
        try await updateUnitProgress(unitId: unitId, progress: unitProgress)
        
        // Award XP for unit completion
        if let unit = try await getUnit(id: unitId) {
            try await UserProgressService.shared.awardXP(unit.xpReward)
        }
        
        print("🎉 Unit completed: \(unitId)")
    }
    
    func completeSection(sectionId: String) async throws {
        var sectionProgress = try await getSectionProgress(sectionId: sectionId) ?? SectionProgress(id: UUID().uuidString, sectionId: sectionId)
        
        sectionProgress.isCompleted = true
        sectionProgress.completionDate = Date()
        sectionProgress.lastActivityDate = Date()
        
        try await updateSectionProgress(sectionId: sectionId, progress: sectionProgress)
        
        // Award XP for section completion
        if let section = try await getSection(id: sectionId) {
            try await UserProgressService.shared.awardXP(section.xpReward)
        }
        
        print("🎉 Section completed: \(sectionId)")
    }
}
