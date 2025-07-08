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
    
    private init() {
        print("Container initialized")
    }
}
