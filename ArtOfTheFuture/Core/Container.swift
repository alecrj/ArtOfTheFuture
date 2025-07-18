// MARK: - Fixed Dependency Injection Container
// File: ArtOfTheFuture/Core/Container.swift

import Foundation

@MainActor
final class Container {
    static let shared = Container()
    
    // MARK: - Services
    lazy var galleryService: GalleryServiceProtocol = {
        GalleryService()
    }()
    
    // Use existing UserDataService instead of UserServiceProtocol
    var userDataService: UserDataService {
        UserDataService.shared
    }
    
    lazy var lessonService: LessonServiceProtocol = {
        LessonService.shared
    }()

    lazy var progressService: ProgressServiceProtocol = {
        ProgressService.shared
    }()
    
    private init() {
        print("Container initialized")
    }
}

extension Container {
    var debugService: DebugService {
        DebugService.shared
    }
}
