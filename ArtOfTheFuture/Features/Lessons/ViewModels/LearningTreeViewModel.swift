// MARK: - Learning Tree View Model
// File: ArtOfTheFuture/Features/Lessons/ViewModels/LearningTreeViewModel.swift

import SwiftUI
import Combine

@MainActor
final class LearningTreeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var learningTree: LearningTree
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Progress tracking
    @Published var completedLessons: Set<String> = []
    @Published var currentLevel = 1
    @Published var totalXP = 0
    
    // MARK: - Services
    private let progressService: ProgressServiceProtocol
    
    // MARK: - Initialization
    init(progressService: ProgressServiceProtocol? = nil) {
        self.progressService = progressService ?? ProgressService.shared
        self.learningTree = LearningTreeCurriculum.generateLearningTree()
    }
    
    // MARK: - Data Loading
    func loadTree() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Generate the tree structure
            var tree = LearningTreeCurriculum.generateLearningTree()
            
            // Load user progress
            completedLessons = try await progressService.getCompletedLessons()
            
            // Load XP and level
            let progressService = self.progressService as! ProgressService
            totalXP = progressService.getTotalXP()
            currentLevel = (totalXP / 100) + 1
            
            // Update tree with user progress
            tree = updateTreeWithProgress(tree)
            
            // Update the published tree
            learningTree = tree
            
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to load learning tree: \(error)")
        }
        
        isLoading = false
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
                
                // Update unlock status
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
            let previousUnitCompleted = previousUnit.lessons.allSatisfy { completedLessons.contains($0) }
            return previousUnitCompleted
        }
        
        // First unit of a new section - check if previous section has enough completion
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
    
    func completeLesson(_ lessonId: String) async {
        do {
            // Mark lesson as completed
            try await progressService.markLessonCompleted(lessonId: lessonId)
            
            // Reload the tree to update progress
            await loadTree()
            
        } catch {
            print("❌ Failed to complete lesson: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    func getLessonProgress(for lessonId: String) -> Double {
        return completedLessons.contains(lessonId) ? 1.0 : 0.0
    }
    
    func isLessonUnlocked(_ lessonId: String) -> Bool {
        guard let unit = learningTree.getUnit(for: lessonId) else { return false }
        
        if !unit.isUnlocked {
            return false
        }
        
        // Check if it's the first lesson or previous lesson is completed
        if let lessonIndex = unit.lessons.firstIndex(of: lessonId) {
            if lessonIndex == 0 {
                return true
            }
            
            let previousLessonId = unit.lessons[lessonIndex - 1]
            return completedLessons.contains(previousLessonId)
        }
        
        return false
    }
}
