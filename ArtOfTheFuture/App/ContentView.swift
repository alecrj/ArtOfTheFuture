import SwiftUI

struct ContentView: View {
    @StateObject private var authService = FirebaseAuthService()
    @State private var isInitialized = false

    var body: some View {
        Group {
            if !isInitialized {
                // Show loading while Firebase initializes
                VStack {
                    ProgressView()
                    Text("Loading...")
                        .padding(.top)
                }
            } else if authService.isAuthenticated {
                MainTabView()
                    .environmentObject(authService)
            } else {
                AuthView()
                    .environmentObject(authService)
            }
        }
        .onAppear {
            // Small delay to ensure Firebase is fully configured
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isInitialized = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
