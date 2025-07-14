// File 3: ArtOfTheFuture/Features/Lessons/Extensions/LearningDebugExtensions.swift

import Foundation

extension LessonsViewModel {
    func setupDebugLogging() {
        DebugService.shared.debug("LessonsViewModel initialized", category: .learning)
    }
    
    func debugLoadLessons() async {
        let tracker = DebugService.shared.startPerformanceTracking(operation: "Load Lessons", category: .learning)
        defer { tracker.finish() }
        
        DebugService.shared.debug("Starting to load lessons", category: .learning)
        
        do {
            await loadLessons()
            DebugService.shared.info("Successfully loaded \(lessons.count) lessons", category: .learning)
        } catch {
            error.logError(message: "Failed to load lessons", category: .learning)
        }
    }
}

extension LearningTreeViewModel {
    func setupDebugLogging() {
        DebugService.shared.debug("LearningTreeViewModel initialized", category: .learning)
    }
    
    func debugLoadTree() async {
        let tracker = DebugService.shared.startPerformanceTracking(operation: "Load Learning Tree", category: .learning)
        defer { tracker.finish() }
        
        DebugService.shared.debug("Loading learning tree", category: .learning)
        
        await loadTree()
        
        DebugService.shared.info("Learning tree loaded with \(learningTree.sections.count) sections", category: .learning)
    }
}

extension ProgressService {
    func debugCompleteLesson(_ lessonId: String, xp: Int) async {
        DebugService.shared.logLessonEvent(.completed, lessonId: lessonId, details: ["xp": xp])
        
        do {
            try await completeLesson(lessonId, xpGained: xp)
            DebugService.shared.logProgressEvent(.xpGained, details: ["amount": xp, "lesson": lessonId])
        } catch {
            error.logError(message: "Failed to complete lesson \(lessonId)", category: .progress)
        }
    }
}
