// MARK: - Enhanced ContentView with Onboarding Flow
// File: ArtOfTheFuture/App/ContentView.swift

import SwiftUI

// MARK: - Enhanced ContentView with Debug Logging
// File: ArtOfTheFuture/App/ContentView.swift

import SwiftUI

struct ContentView: View {
    @StateObject private var authService = FirebaseAuthService()
    @State private var isInitialized = false
    
    var body: some View {
        Group {
            if !isInitialized {
                // Show loading while Firebase initializes
                LoadingView()
                    .onAppear {
                        print("📱 App loading...")
                    }
            } else if !authService.isAuthenticated {
                // User not authenticated - show auth
                AuthView()
                    .environmentObject(authService)
                    .onAppear {
                        print("📱 Showing AuthView - user not authenticated")
                    }
            } else if authService.isCheckingOnboardingStatus {
                // Checking onboarding status from Firestore
                LoadingView(message: "Setting up your experience...")
                    .onAppear {
                        print("📱 Checking onboarding status...")
                    }
            } else if !authService.hasCompletedOnboarding {
                // User authenticated but hasn't completed onboarding
                OnboardingView()
                    .environmentObject(authService)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                    .onAppear {
                        print("📱 Showing OnboardingView - user authenticated but onboarding incomplete")
                    }
            } else {
                // User authenticated and onboarded - show main app
                MainTabView()
                    .environmentObject(authService)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                        removal: .opacity
                    ))
                    .onAppear {
                        print("📱 Showing MainTabView - user fully set up")
                    }
            }
        }
        .onAppear {
            initializeApp()
        }
        .onChange(of: authService.isAuthenticated) { _, newValue in
            print("📱 Auth state changed to: \(newValue)")
        }
        .onChange(of: authService.hasCompletedOnboarding) { _, newValue in
            print("📱 Onboarding completion state changed to: \(newValue)")
        }
    }
    
    private func initializeApp() {
        print("📱 Initializing app...")
        // Small delay to ensure Firebase is fully configured
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.5)) {
                isInitialized = true
                print("📱 App initialization complete")
            }
        }
    }
}

// MARK: - Enhanced Loading View
struct LoadingView: View {
    let message: String
    
    init(message: String = "Loading...") {
        self.message = message
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Animated logo or progress indicator
                ZStack {
                    Circle()
                        .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .animation(
                            .linear(duration: 1.5).repeatForever(autoreverses: false),
                            value: UUID()
                        )
                }
                
                VStack(spacing: 8) {
                    Text(message)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Art of the Future")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            // Trigger the animation
            _ = UUID()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
