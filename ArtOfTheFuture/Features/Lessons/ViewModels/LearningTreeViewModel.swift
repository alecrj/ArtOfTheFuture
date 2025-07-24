// MARK: - Enhanced Learning Tree View Model - FAANG Quality
// File: ArtOfTheFuture/Features/Lessons/ViewModels/LearningTreeViewModel.swift

import SwiftUI
import Combine

@MainActor
final class LearningTreeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var learningTree: LearningTree
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    // Progress tracking
    @Published var completedLessons: Set<String> = []
    @Published var currentLevel = 1
    @Published var totalXP = 0
    @Published var dailyStreak = 0
    @Published var weeklyProgress: Double = 0
    
    // UI State
    @Published var selectedSection = 0
    @Published var expandedUnits: Set<String> = []
    
    // MARK: - Services
    private let progressService: ProgressServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(progressService: ProgressServiceProtocol? = nil) {
        self.progressService = progressService ?? ProgressService.shared
        // Initialize with empty tree - will be populated on load
        self.learningTree = LearningTree(sections: [])
        
        // Load initial tree structure immediately
        Task {
            await loadInitialTree()
        }
    }
    
    // MARK: - Initial Load
    private func loadInitialTree() async {
        // Generate tree structure immediately for UI
        await MainActor.run {
            self.learningTree = LearningTreeCurriculum.generateLearningTree()
        }
    }
    
    // MARK: - Data Loading
    func loadTree() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            showError = false
        }
        
        do {
            // Generate the base tree structure
            var tree = LearningTreeCurriculum.generateLearningTree()
            
            // Load user progress - with proper error handling
            do {
                completedLessons = try await progressService.getCompletedLessons()
            } catch {
                print("⚠️ Failed to load completed lessons, using empty set: \(error)")
                completedLessons = []
            }
            
            // Load XP and level - without casting issues
            await loadUserStats()
            
            // Update tree with user progress
            tree = updateTreeWithProgress(tree)
            
            // Update the published tree
            await MainActor.run {
                self.learningTree = tree
                self.isLoading = false
            }
            
            // Log successful load
            print("✅ Learning tree loaded successfully with \(tree.sections.count) sections")
            
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.showError = true
                self.isLoading = false
            }
            print("❌ Failed to load learning tree: \(error)")
        }
    }
    
    // MARK: - Load User Stats
    private func loadUserStats() async {
        // Use protocol methods that don't require casting
        if let progress = try? await progressService.getOverallProgress() {
            await MainActor.run {
                self.totalXP = progress.totalXPEarned
                self.currentLevel = (progress.totalXPEarned / 100) + 1
                self.dailyStreak = progress.currentStreak
                self.weeklyProgress = min(progress.completionPercentage * 100, 100)
            }
        } else {
            // Fallback to default values if loading fails
            await MainActor.run {
                self.totalXP = 0
                self.currentLevel = 1
                self.dailyStreak = 0
                self.weeklyProgress = 0
            }
        }
    }
    
    // MARK: - Progress Updates
    private func updateTreeWithProgress(_ tree: LearningTree) -> LearningTree {
        var updatedSections: [LearningSection] = []
        
        for (sectionIndex, section) in tree.sections.enumerated() {
            var updatedUnits: [LearningUnit] = []
            
            for (unitIndex, unit) in section.units.enumerated() {
                var updatedUnit = unit
                
                // Update completed lessons
                updatedUnit.completedLessonIds = Set(unit.lessons.filter { completedLessons.contains($0) })
                
                // Update unlock status with improved logic
                updatedUnit.isUnlocked = calculateUnitUnlocked(
                    sectionIndex: sectionIndex,
                    unitIndex: unitIndex,
                    tree: tree
                )
                
                updatedUnits.append(updatedUnit)
            }
            
            // Create updated section
            let updatedSection = LearningSection(
                id: section.id,
                title: section.title,
                level: section.level,
                order: section.order,
                description: section.description,
                iconName: section.iconName,
                units: updatedUnits
            )
            
            updatedSections.append(updatedSection)
        }
        
        return LearningTree(sections: updatedSections)
    }
    
    // MARK: - Unlock Logic
    private func calculateUnitUnlocked(sectionIndex: Int, unitIndex: Int, tree: LearningTree) -> Bool {
        // First unit of beginner section is always unlocked
        if sectionIndex == 0 && unitIndex == 0 {
            return true
        }
        
        // Check if previous unit in same section is completed
        if unitIndex > 0 {
            let previousUnit = tree.sections[sectionIndex].units[unitIndex - 1]
            let requiredCompletionRate: Double = 0.7 // 70% of lessons must be complete
            let completedCount = previousUnit.lessons.filter { completedLessons.contains($0) }.count
            let completionRate = Double(completedCount) / Double(previousUnit.lessons.count)
            return completionRate >= requiredCompletionRate
        }
        
        // First unit of a new section
        if unitIndex == 0 && sectionIndex > 0 {
            let previousSection = tree.sections[sectionIndex - 1]
            let totalLessonsInPrevSection = previousSection.units.reduce(0) { $0 + $1.lessons.count }
            let completedInPrevSection = previousSection.units.reduce(0) { total, unit in
                total + unit.lessons.filter { completedLessons.contains($0) }.count
            }
            
            // Require 80% completion of previous section
            let completionRate = Double(completedInPrevSection) / Double(totalLessonsInPrevSection)
            return completionRate >= 0.8
        }
        
        return false
    }
    
    // MARK: - Actions
    func refreshTree() {
        Task {
            await loadTree()
        }
    }
    
    // MARK: - Complete Lesson
    func completeLesson(_ lessonId: String) async {
        do {
            // Mark lesson as completed
            try await progressService.completeLesson(lessonId)
            
            // Add to local completed set immediately for UI responsiveness
            await MainActor.run {
                completedLessons.insert(lessonId)
            }
            
            // Notify gamification engine
            let accuracy = 0.95 // You can pass actual accuracy here
            await MainActor.run {
                GamificationEngine.shared.lessonCompleted(accuracy: accuracy)
            }
            
            // Reload the tree to update progress
            await loadTree()
            
            print("✅ Lesson \(lessonId) completed successfully")
            
        } catch {
            print("❌ Failed to complete lesson: \(error)")
            await MainActor.run {
                self.errorMessage = "Failed to save progress. Please try again."
                self.showError = true
            }
        }
    }
    
    // MARK: - Helper Methods
    func getLessonProgress(for lessonId: String) -> Double {
        return completedLessons.contains(lessonId) ? 1.0 : 0.0
    }
    
    func getNextAvailableLesson() -> String? {
        for section in learningTree.sections {
            for unit in section.units where unit.isUnlocked {
                for lessonId in unit.lessons {
                    if !completedLessons.contains(lessonId) {
                        return lessonId
                    }
                }
            }
        }
        return nil
    }
    
    func toggleUnitExpansion(_ unitId: String) {
        if expandedUnits.contains(unitId) {
            expandedUnits.remove(unitId)
        } else {
            expandedUnits.insert(unitId)
        }
    }
    
    // MARK: - Analytics
    func trackSectionView(_ sectionId: String) {
        Task {
            await DebugService.shared.logLearningEvent(
                .sectionViewed,
                details: ["section": sectionId]
            )
        }
    }
    
    func trackUnitTap(_ unitId: String) {
        Task {
            await DebugService.shared.logLearningEvent(
                .unitOpened,
                details: ["unit": unitId]
            )
        }
    }
}

// MARK: - View Model Extensions
extension LearningTreeViewModel {
    var hasUnlockedContent: Bool {
        learningTree.sections.contains { section in
            section.units.contains { $0.isUnlocked }
        }
    }
    
    var nextMilestone: Int {
        let milestoneLevels = [5, 10, 25, 50, 100]
        return milestoneLevels.first { $0 > completedLessons.count } ?? 150
    }
    
    var progressToNextMilestone: Double {
        let current = Double(completedLessons.count)
        let next = Double(nextMilestone)
        return current / next
    }
}
