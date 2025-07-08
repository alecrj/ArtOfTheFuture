import Foundation

@MainActor
final class Container {
    static let shared = Container()
    
    // MARK: - Services
    lazy var galleryService: GalleryServiceProtocol = {
        GalleryService()
    }()
    
    lazy var userService: UserServiceProtocol = {
        UserService()
    }()
    lazy var lessonService: LessonServiceProtocol = {
        LessonService()
    }()

    lazy var progressService: ProgressServiceProtocol = {
        ProgressService()
    }()
    
    private init() {
        print("Container initialized")
    }
}
