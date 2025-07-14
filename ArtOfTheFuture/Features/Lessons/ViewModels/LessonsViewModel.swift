// MARK: - Complete Lessons ViewModel (BUILD ERROR FIXED)
// **REPLACE:** ArtOfTheFuture/Features/Lessons/ViewModels/LessonsViewModel.swift

import SwiftUI
import Combine

@MainActor
final class LessonsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var lessons: [Lesson] = []
    @Published var filteredLessons: [Lesson] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentStreak = 0
    
    // MARK: - Filter Properties
    @Published var selectedCategory: LessonCategory?
    @Published var selectedDifficulties: Set<DifficultyLevel> = []
    @Published var showCompleted = true
    @Published var showLocked = true
    @Published var showInProgress = true
    @Published var sortOption: LessonSortOption = .recommended
    
    // MARK: - Progress Properties
    @Published var completedLessons: Set<String> = []
    @Published var unlockedLessons: Set<String> = ["lesson_001"] // First lesson unlocked
    @Published var currentLevel = 1
    @Published var currentTotalXP = 0
    
    // MARK: - Services
    private let lessonService: LessonServiceProtocol
    private let progressService: ProgressServiceProtocol
    
    // MARK: - Computed Properties
    var completedLessonsCount: Int {
        completedLessons.count
    }
    
    // MARK: - Initialization
    init(
        lessonService: LessonServiceProtocol? = nil,
        progressService: ProgressServiceProtocol? = nil
    ) {
        self.lessonService = lessonService ?? LessonService.shared
        self.progressService = progressService ?? ProgressService.shared
    }
    
    // MARK: - Data Loading
    func loadLessons() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Load lessons
            lessons = try await lessonService.getAllLessons()
            
            // Load progress data
            completedLessons = try await progressService.getCompletedLessons()
            
            // Load XP and level
            let progressService = self.progressService as! ProgressService
            currentTotalXP = progressService.getTotalXP()
            currentLevel = (currentTotalXP / 100) + 1
            currentStreak = progressService.getCurrentStreak()
            
            // Apply filters
            applyFiltersInternal()
            
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to load lessons: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Filtering Logic (FIXED - Single source of truth)
    private func applyFiltersInternal() {
        var filtered = lessons
        
        // Category filter
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Difficulty filter
        if !selectedDifficulties.isEmpty {
            filtered = filtered.filter { selectedDifficulties.contains($0.difficulty) }
        }
        
        // Status filters
        if !showCompleted {
            filtered = filtered.filter { !completedLessons.contains($0.id) }
        }
        
        if !showLocked {
            filtered = filtered.filter { unlockedLessons.contains($0.id) }
        }
        
        if !showInProgress {
            // Filter out lessons that are partially completed
            // (This would need actual progress tracking)
        }
        
        // Sort lessons
        filtered = sortLessons(filtered)
        
        filteredLessons = filtered
    }
    
    private func sortLessons(_ lessons: [Lesson]) -> [Lesson] {
        switch sortOption {
        case .recommended:
            return lessons.sorted { lesson1, lesson2 in
                // Prioritize unlocked, then by order
                let lesson1Unlocked = unlockedLessons.contains(lesson1.id)
                let lesson2Unlocked = unlockedLessons.contains(lesson2.id)
                
                if lesson1Unlocked != lesson2Unlocked {
                    return lesson1Unlocked && !lesson2Unlocked
                }
                
                return lesson1.id < lesson2.id // Maintain curriculum order
            }
        case .newest:
            return lessons.sorted { $0.id > $1.id }
        case .easiest:
            return lessons.sorted { $0.difficulty.requiredLevel < $1.difficulty.requiredLevel }
        case .hardest:
            return lessons.sorted { $0.difficulty.requiredLevel > $1.difficulty.requiredLevel }
        case .shortestFirst:
            return lessons.sorted { $0.estimatedMinutes < $1.estimatedMinutes }
        case .mostXP:
            return lessons.sorted { $0.xpReward > $1.xpReward }
        }
    }
    
    // MARK: - Filter Actions
    func toggleDifficulty(_ difficulty: DifficultyLevel) {
        if selectedDifficulties.contains(difficulty) {
            selectedDifficulties.remove(difficulty)
        } else {
            selectedDifficulties.insert(difficulty)
        }
        applyFiltersInternal()
    }
    
    func clearFilters() {
        selectedCategory = nil
        selectedDifficulties.removeAll()
        showCompleted = true
        showLocked = true
        showInProgress = true
        sortOption = .recommended
        applyFiltersInternal()
    }
    
    // FIXED: Single public method for applying filters
    func applyFilters() {
        applyFiltersInternal()
    }
    
    // MARK: - Lesson Progress
    func getLessonProgress(for lessonId: String) -> Double? {
        if completedLessons.contains(lessonId) {
            return 1.0
        }
        
        // For now, return mock progress for in-progress lessons
        if unlockedLessons.contains(lessonId) {
            return Double.random(in: 0.1...0.8)
        }
        
        return nil
    }
    
    func isLessonLocked(_ lessonId: String) -> Bool {
        return !unlockedLessons.contains(lessonId)
    }
    
    // MARK: - Refresh
    func refreshData() async {
        await loadLessons()
    }
}

// MARK: - Lesson Sort Options
enum LessonSortOption: String, CaseIterable {
    case recommended = "Recommended"
    case newest = "Newest First"
    case easiest = "Easiest First"
    case hardest = "Hardest First"
    case shortestFirst = "Shortest First"
    case mostXP = "Most XP"
}
