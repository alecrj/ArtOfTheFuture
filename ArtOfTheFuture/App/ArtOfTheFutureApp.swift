import SwiftUI
import Firebase  // Add this import

@main
struct ArtOfTheFutureApp: App {
    
    // Add this initializer
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
