// MARK: - Migration & Integration Utilities
// File: ArtOfTheFuture/Features/Lessons/Services/MigrationService.swift

import Foundation


protocol MigrationServiceProtocol {
    func migrateExistingProgress() async throws
    func validateMigration() async throws -> MigrationValidationResult
    func rollbackMigration() async throws
    func getSystemStatus() async -> SystemStatus
}

// MARK: - Migration Service Implementation
final class MigrationService: MigrationServiceProtocol {
    static let shared = MigrationService()
    
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private let migrationVersionKey = "migration_version"
    private let migrationBackupKey = "migration_backup"
    private let currentMigrationVersion = "1.0.0"
    
    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Migration Methods
    func migrateExistingProgress() async throws {
        print("🔄 Starting migration to enhanced learning system...")
        
        // Check if migration is needed
        let currentVersion = userDefaults.string(forKey: migrationVersionKey)
        if currentVersion == currentMigrationVersion {
            print("✅ Migration already completed")
            return
        }
        
        // Create backup of existing data
        try await createMigrationBackup()
        
        // Perform migration steps
        try await migrateUserProfile()
        try await migrateLessonProgress()
        try await initializeNewSystems()
        try await validateAndFinalizeMigration()
        
        // Mark migration as complete
        userDefaults.set(currentMigrationVersion, forKey: migrationVersionKey)
        
        print("✅ Migration completed successfully")
    }
    
    func validateMigration() async throws -> MigrationValidationResult {
        print("🔍 Validating migration...")
        
        var issues: [MigrationIssue] = []
        var warnings: [String] = []
        
        // Check user profile integrity
        do {
            let userProfile = try await UserProgressService.shared.getCurrentUser()
            if userProfile.completedLessons.isEmpty && hasExistingLessonData() {
                issues.append(.lostLessonProgress)
            }
        } catch {
            issues.append(.userProfileCorrupt)
        }
        
        // Check section/unit structure
        let sections = EnhancedCurriculum.allSections
        if sections.isEmpty {
            issues.append(.missingSections)
        }
        
        // Check gamification system
        do {
            _ = try await GamificationService.shared.getDailyQuests()
        } catch {
            warnings.append("Daily quests system needs initialization")
        }
        
        // Check lesson mapping
        let orphanedLessons = findOrphanedLessons()
        if !orphanedLessons.isEmpty {
            warnings.append("Found \(orphanedLessons.count) lessons not mapped to units")
        }
        
        return MigrationValidationResult(
            isValid: issues.isEmpty,
            issues: issues,
            warnings: warnings,
            validatedAt: Date()
        )
    }
    
    func rollbackMigration() async throws {
        print("⏪ Rolling back migration...")
        
        guard let backupData = userDefaults.data(forKey: migrationBackupKey),
              let backup = try? decoder.decode(MigrationBackup.self, from: backupData) else {
            throw MigrationError.noBackupAvailable
        }
        
        // Restore backed up data
        for (key, value) in backup.userDefaultsBackup {
            userDefaults.set(value, forKey: key)
        }
        
        // Clear migration version
        userDefaults.removeObject(forKey: migrationVersionKey)
        
        print("✅ Migration rollback completed")
    }
    
    func getSystemStatus() async -> SystemStatus {
        let migrationVersion = userDefaults.string(forKey: migrationVersionKey)
        let isLegacySystem = migrationVersion == nil
        let isEnhancedSystem = migrationVersion == currentMigrationVersion
        
        let userProfileExists = (try? await UserProgressService.shared.getCurrentUser()) != nil
        let sectionsAvailable = !EnhancedCurriculum.allSections.isEmpty
        let gamificationActive = (try? await GamificationService.shared.getCurrentHearts()) != nil
        
        return SystemStatus(
            migrationVersion: migrationVersion,
            isLegacySystem: isLegacySystem,
            isEnhancedSystem: isEnhancedSystem,
            userProfileExists: userProfileExists,
            sectionsAvailable: sectionsAvailable,
            gamificationActive: gamificationActive,
            lastChecked: Date()
        )
    }
    
    // MARK: - Private Migration Steps
    private func createMigrationBackup() async throws {
        print("💾 Creating migration backup...")
        
        let keysToBackup = [
            "currentUserProfile",
            "completedLessons",
            "totalXP",
            "userStreak",
            "lesson_progress_lesson_001",
            "lesson_progress_lesson_002",
            "lesson_progress_lesson_003",
            "lesson_progress_lesson_004",
            "lesson_progress_lesson_005"
        ]
        
        var backup: [String: Any] = [:]
        for key in keysToBackup {
            if let value = userDefaults.object(forKey: key) {
                backup[key] = value
            }
        }
        
        let migrationBackup = MigrationBackup(
            version: "pre_migration",
            timestamp: Date(),
            userDefaultsBackup: backup
        )
        
        let data = try encoder.encode(migrationBackup)
        userDefaults.set(data, forKey: migrationBackupKey)
        
        print("✅ Migration backup created")
    }
    
    private func migrateUserProfile() async throws {
        print("👤 Migrating user profile...")
        
        // Get or create user profile
        var userProfile = try await UserProgressService.shared.getCurrentUser()
        
        // Migrate existing progress data
        if let completedLessonsArray = userDefaults.array(forKey: "completedLessons") as? [String] {
            userProfile.completedLessons = Set(completedLessonsArray)
        }
        
        if userProfile.totalXP == 0 {
            userProfile.totalXP = userDefaults.integer(forKey: "totalXP")
        }
        
        if userProfile.currentStreak == 0 {
            userProfile.currentStreak = userDefaults.integer(forKey: "userStreak")
        }
        
        // Initialize new fields
        if userProfile.unlockedLessons.isEmpty {
            userProfile.unlockedLessons = ["lesson_001"]
        }
        
        // Save migrated profile
        try await UserProgressService.shared.saveUserProfile(userProfile)
        
        print("✅ User profile migration completed")
    }
    
    private func migrateLessonProgress() async throws {
        print("📚 Migrating lesson progress...")
        
        let existingLessons = ["lesson_001", "lesson_002", "lesson_003", "lesson_004", "lesson_005"]
        
        for lessonId in existingLessons {
            let progressKey = "lesson_progress_\(lessonId)"
            
            if let data = userDefaults.data(forKey: progressKey),
               let existingProgress = try? decoder.decode(LessonProgress.self, from: data) {
                
                // Progress already in new format, validate and keep
                print("  ✓ \(lessonId): Already in new format")
                continue
            } else {
                // Create new progress entry if lesson was completed
                let userProfile = try await UserProgressService.shared.getCurrentUser()
                if userProfile.completedLessons.contains(lessonId) {
                    let newProgress = LessonProgress(
                        lessonId: lessonId,
                        isStarted: true,
                        isCompleted: true,
                        completionDate: Date(),
                        stepProgress: [:],
                        totalTimeSpent: 0,
                        bestScore: 1.0,
                        attempts: 1,
                        lastAttemptDate: Date()
                    )
                    
                    try await ProgressService.shared.saveProgress(newProgress)
                    print("  ✓ \(lessonId): Created new progress entry")
                }
            }
        }
        
        print("✅ Lesson progress migration completed")
    }
    
    private func initializeNewSystems() async throws {
        print("🎮 Initializing new systems...")
        
        // Initialize gamification system
        do {
            _ = try await GamificationService.shared.getDailyQuests()
            await GamificationService.shared.refillHearts()
            print("  ✓ Gamification system initialized")
        } catch {
            print("  ⚠️ Gamification system initialization failed: \(error)")
        }
        
        // Initialize learning path
        let learningPath = LearningPath.shared
        if learningPath.sections.isEmpty {
            print("  ⚠️ Learning path is empty")
        } else {
            print("  ✓ Learning path initialized with \(learningPath.sections.count) sections")
        }
        
        // Initialize section/unit progress for completed lessons
        try await initializeSectionUnitProgress()
        
        print("✅ New systems initialization completed")
    }
    
    private func initializeSectionUnitProgress() async throws {
        let userProfile = try await UserProgressService.shared.getCurrentUser()
        
        // Map completed lessons to units and sections
        for lessonId in userProfile.completedLessons {
            // Find which unit contains this lesson
            for section in EnhancedCurriculum.allSections {
                for unit in section.units {
                    if unit.lessonIds.contains(lessonId) {
                        // Update unit progress
                        var unitProgress = try await EnhancedLearningService.shared.getUnitProgress(unitId: unit.id) ??
                            UnitProgress(id: UUID().uuidString, unitId: unit.id)
                        
                        unitProgress.isStarted = true
                        unitProgress.lessonsCompleted.insert(lessonId)
                        
                        // Check if unit is now complete
                        if unitProgress.lessonsCompleted.count == unit.lessonIds.count {
                            unitProgress.isCompleted = true
                            unitProgress.completionDate = Date()
                        }
                        
                        try await EnhancedLearningService.shared.updateUnitProgress(unitId: unit.id, progress: unitProgress)
                        
                        // Update section progress
                        var sectionProgress = try await EnhancedLearningService.shared.getSectionProgress(sectionId: section.id) ??
                            SectionProgress(id: UUID().uuidString, sectionId: section.id)
                        
                        sectionProgress.isStarted = true
                        if unitProgress.isCompleted {
                            sectionProgress.unitsCompleted.insert(unit.id)
                        }
                        
                        // Check if section is now complete
                        if sectionProgress.unitsCompleted.count == section.totalUnits {
                            sectionProgress.isCompleted = true
                            sectionProgress.completionDate = Date()
                        }
                        
                        try await EnhancedLearningService.shared.updateSectionProgress(sectionId: section.id, progress: sectionProgress)
                        
                        break
                    }
                }
            }
        }
    }
    
    private func validateAndFinalizeMigration() async throws {
        let validationResult = try await validateMigration()
        
        if !validationResult.isValid {
            print("❌ Migration validation failed:")
            for issue in validationResult.issues {
                print("  - \(issue.description)")
            }
            throw MigrationError.validationFailed(validationResult.issues)
        }
        
        if !validationResult.warnings.isEmpty {
            print("⚠️ Migration warnings:")
            for warning in validationResult.warnings {
                print("  - \(warning)")
            }
        }
        
        print("✅ Migration validation passed")
    }
    
    // MARK: - Helper Methods
    private func hasExistingLessonData() -> Bool {
        let existingKeys = ["completedLessons", "totalXP", "lesson_progress_lesson_001"]
        return existingKeys.contains { userDefaults.object(forKey: $0) != nil }
    }
    
    private func findOrphanedLessons() -> [Lesson] {
        let allLessons = Curriculum.allLessons
        let mappedLessonIds = Set(EnhancedCurriculum.allUnits.flatMap { $0.lessonIds })
        
        return allLessons.filter { !mappedLessonIds.contains($0.id) }
    }
}

// MARK: - Integration Helper Service
final class IntegrationHelper {
    static let shared = IntegrationHelper()
    
    private init() {}
    
    // MARK: - System Setup
    func initializeEnhancedSystem() async throws {
        print("🚀 Initializing enhanced learning system...")
        
        // Check if migration is needed
        let systemStatus = await MigrationService.shared.getSystemStatus()
        
        if systemStatus.isLegacySystem {
            try await MigrationService.shared.migrateExistingProgress()
        } else if !systemStatus.isEnhancedSystem {
            print("⚠️ System in unknown state, performing fresh initialization...")
            try await initializeFreshSystem()
        }
        
        // Ensure all services are ready
        try await validateAllServices()
        
        print("✅ Enhanced learning system ready")
    }
    
    private func initializeFreshSystem() async throws {
        // Create default user profile
        let defaultProfile = UserProfile(
            id: UUID().uuidString,
            displayName: "Artist",
            level: 1,
            totalXP: 0,
            unlockedLessons: ["lesson_001"]
        )
        
        try await UserProgressService.shared.saveUserProfile(defaultProfile)
        
        // Initialize gamification
        try await GamificationService.shared.generateNewDailyQuests()
        try await GamificationService.shared.refillHearts()
        
        print("✅ Fresh system initialized")
    }
    
    private func validateAllServices() async throws {
        // Validate user service
        _ = try await UserProgressService.shared.getCurrentUser()
        
        // Validate lesson service
        _ = try await LessonService.shared.getAllLessons()
        
        // Validate enhanced learning service
        _ = try await EnhancedLearningService.shared.getAllSections()
        
        // Validate gamification service
        _ = try await GamificationService.shared.getCurrentHearts()
        
        print("✅ All services validated")
    }
    
    // MARK: - Compatibility Methods
    func getLessonWithProgress(lessonId: String) async throws -> LessonWithProgress? {
        guard let lesson = try await LessonService.shared.getLesson(id: lessonId) else {
            return nil
        }
        
        let progress = try await ProgressService.shared.getLessonProgress(lessonId: lessonId)
        let userProfile = try await UserProgressService.shared.getCurrentUser()
        
        let isUnlocked = userProfile.unlockedLessons.contains(lessonId) ||
                        LessonService.shared.checkPrerequisites(for: lessonId, profile: userProfile)
        
        return LessonWithProgress(
            lesson: lesson,
            progress: progress,
            isUnlocked: isUnlocked,
            isCompleted: userProfile.completedLessons.contains(lessonId)
        )
    }
    
    func getUnitWithProgress(unitId: String) async throws -> UnitWithProgress? {
        guard let unit = try await EnhancedLearningService.shared.getUnit(id: unitId) else {
            return nil
        }
        
        let progress = try await EnhancedLearningService.shared.getUnitProgress(unitId: unitId)
        let userProfile = try await UserProgressService.shared.getCurrentUser()
        
        let unlockedUnits = EnhancedLearningService.shared.getUnlockedUnits(for: userProfile)
        let isUnlocked = unlockedUnits.contains(unitId)
        
        // Get lesson progress for this unit
        var lessonProgresses: [LessonWithProgress] = []
        for lessonId in unit.lessonIds {
            if let lessonWithProgress = try await getLessonWithProgress(lessonId: lessonId) {
                lessonProgresses.append(lessonWithProgress)
            }
        }
        
        return UnitWithProgress(
            unit: unit,
            progress: progress,
            lessons: lessonProgresses,
            isUnlocked: isUnlocked,
            isCompleted: progress?.isCompleted ?? false
        )
    }
    
    func getSectionWithProgress(sectionId: String) async throws -> SectionWithProgress? {
        guard let section = try await EnhancedLearningService.shared.getSection(id: sectionId) else {
            return nil
        }
        
        let progress = try await EnhancedLearningService.shared.getSectionProgress(sectionId: sectionId)
        let userProfile = try await UserProgressService.shared.getCurrentUser()
        
        let unlockedSections = EnhancedLearningService.shared.getUnlockedSections(for: userProfile)
        let isUnlocked = unlockedSections.contains(sectionId)
        
        // Get unit progress for this section
        var unitProgresses: [UnitWithProgress] = []
        for unit in section.units {
            if let unitWithProgress = try await getUnitWithProgress(unitId: unit.id) {
                unitProgresses.append(unitWithProgress)
            }
        }
        
        return SectionWithProgress(
            section: section,
            progress: progress,
            units: unitProgresses,
            isUnlocked: isUnlocked,
            isCompleted: progress?.isCompleted ?? false
        )
    }
}

// MARK: - Supporting Types
struct MigrationBackup: Codable {
    let version: String
    let timestamp: Date
    let userDefaultsBackup: [String: Any]
    
    enum CodingKeys: CodingKey {
        case version, timestamp, userDefaultsBackup
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(timestamp, forKey: .timestamp)
        
        // Encode userDefaultsBackup as Data
        let data = try NSKeyedArchiver.archivedData(withRootObject: userDefaultsBackup, requiringSecureCoding: false)
        try container.encode(data, forKey: .userDefaultsBackup)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(String.self, forKey: .version)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        
        let data = try container.decode(Data.self, forKey: .userDefaultsBackup)
        userDefaultsBackup = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String: Any] ?? [:]
    }
    
    init(version: String, timestamp: Date, userDefaultsBackup: [String: Any]) {
        self.version = version
        self.timestamp = timestamp
        self.userDefaultsBackup = userDefaultsBackup
    }
}

struct MigrationValidationResult {
    let isValid: Bool
    let issues: [MigrationIssue]
    let warnings: [String]
    let validatedAt: Date
}

enum MigrationIssue: CustomStringConvertible {
    case lostLessonProgress
    case userProfileCorrupt
    case missingSections
    case gamificationFailure
    
    var description: String {
        switch self {
        case .lostLessonProgress:
            return "Lesson progress data was lost during migration"
        case .userProfileCorrupt:
            return "User profile data is corrupted"
        case .missingSections:
            return "Section data is missing"
        case .gamificationFailure:
            return "Gamification system failed to initialize"
        }
    }
}

struct SystemStatus {
    let migrationVersion: String?
    let isLegacySystem: Bool
    let isEnhancedSystem: Bool
    let userProfileExists: Bool
    let sectionsAvailable: Bool
    let gamificationActive: Bool
    let lastChecked: Date
}

struct LessonWithProgress {
    let lesson: Lesson
    let progress: LessonProgress?
    let isUnlocked: Bool
    let isCompleted: Bool
}

struct UnitWithProgress {
    let unit: Unit
    let progress: UnitProgress?
    let lessons: [LessonWithProgress]
    let isUnlocked: Bool
    let isCompleted: Bool
}

struct SectionWithProgress {
    let section: Section
    let progress: SectionProgress?
    let units: [UnitWithProgress]
    let isUnlocked: Bool
    let isCompleted: Bool
}

enum MigrationError: LocalizedError {
    case noBackupAvailable
    case validationFailed([MigrationIssue])
    case systemCorrupted
    
    var errorDescription: String? {
        switch self {
        case .noBackupAvailable:
            return "No migration backup available for rollback"
        case .validationFailed(let issues):
            return "Migration validation failed with \(issues.count) issues"
        case .systemCorrupted:
            return "System data is corrupted and cannot be migrated"
        }
    }
}
