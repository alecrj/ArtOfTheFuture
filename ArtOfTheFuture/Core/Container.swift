import Foundation

class Container {
    static let shared = Container()
    
    private init() {}
    
    lazy var lessonService: LessonService = LessonService.shared
    lazy var userProgressService: UserProgressService = UserProgressService.shared
    lazy var gamificationService: GamificationService = GamificationService.shared
}
