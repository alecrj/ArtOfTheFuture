// File: ArtOfTheFuture/Features/Lessons/Extensions/LearningDebugExtensions.swift

import Foundation

extension LessonsViewModel {
    func setupDebugLogging() {
        Task { @MainActor in
            await DebugService.shared.debug("LessonsViewModel initialized", category: .learning)
        }
    }
    
    func debugLoadLessons() async {
        let tracker = await DebugService.shared.startPerformanceTracking(
            operation: "Load Lessons",
            category: .learning
        )
        defer { tracker.finish() }
        
        await DebugService.shared.debug("Starting to load lessons", category: .learning)
        
        do {
            await loadLessons()
            await DebugService.shared.info(
                "Successfully loaded \(lessons.count) lessons",
                category: .learning
            )
        } catch {
            error.logError(
                message: "Failed to load lessons",
                category: .learning
            )
        }
    }
}

extension LearningTreeViewModel {
    func setupDebugLogging() {
        Task { @MainActor in
            await DebugService.shared.debug("LearningTreeViewModel initialized", category: .learning)
        }
    }
    
    func debugLoadTree() async {
        let tracker = await DebugService.shared.startPerformanceTracking(
            operation: "Load Learning Tree",
            category: .learning
        )
        defer { tracker.finish() }
        
        await DebugService.shared.debug("Loading learning tree", category: .learning)
        await loadTree()
        await DebugService.shared.info(
            "Learning tree loaded with \(learningTree.sections.count) sections",
            category: .learning
        )
    }
}

extension ProgressService {
    /// Logs and then completes a lesson, without passing extra parameters to `completeLesson`.
    func debugCompleteLesson(_ lessonId: String, xp: Int) async {
        // Log the intent
        await DebugService.shared.logLessonEvent(
            .completed,
            lessonId: lessonId,
            details: ["xp": xp]
        )
        
        do {
            // <-- Call the real completeLesson with only the lessonId:
            try await completeLesson(lessonId)
            
            // Then log the XP gain
            await DebugService.shared.logProgressEvent(
                .xpGained,
                details: ["amount": xp, "lesson": lessonId]
            )
        } catch {
            error.logError(
                message: "Failed to complete lesson \(lessonId)",
                category: .progress
            )
        }
    }
}
