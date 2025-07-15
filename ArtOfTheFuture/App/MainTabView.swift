// MARK: - Main Tab View (Updated with Debug Integration)
// **REPLACE:** ArtOfTheFuture/App/MainTabView.swift

import SwiftUI

// MARK: - Main Tab View (Updated with Global XP Overlay)
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var tabViewModel = MainTabViewModel()
    @StateObject private var debugService = DebugService.shared

    var body: some View {
        ZStack {
            // Your existing TabView, now driving streak update on appear
            TabView(selection: $selectedTab) {
                HomeDashboardView()
                    .tabItem {
                        Label("Home", systemImage: selectedTab == 0 ? "house.fill" : "house")
                    }
                    .tag(0)
                    .debugOnAppear("Home Tab")

                LessonsView()
                    .tabItem {
                        Label("Learn", systemImage: selectedTab == 1 ? "book.fill" : "book")
                    }
                    .tag(1)
                    .badge(tabViewModel.hasNewLessons ? "New" : nil)
                    .debugOnAppear("Learn Tab")

                DrawingView()
                    .tabItem {
                        Label("Draw", systemImage: selectedTab == 2 ? "paintbrush.fill" : "paintbrush")
                    }
                    .tag(2)
                    .debugOnAppear("Draw Tab")

                GalleryView()
                    .tabItem {
                        Label("Gallery", systemImage: selectedTab == 3 ? "photo.stack.fill" : "photo.stack")
                    }
                    .tag(3)
                    .badge(tabViewModel.newArtworkCount > 0 ? "\(tabViewModel.newArtworkCount)" : nil)
                    .debugOnAppear("Gallery Tab")

                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: selectedTab == 4 ? "person.circle.fill" : "person.circle")
                    }
                    .tag(4)
                    .debugOnAppear("Profile Tab")
            }
            .accentColor(.blue)
            .onAppear {
                setupTabBarAppearance()
                GamificationEngine.shared.updateStreak()                 // ← NEW: update daily streak
                debugService.info("MainTabView appeared", category: .ui)
            }

            // ← NEW: Global XP animation overlay, non-interactive and top‑most
            XPAnimationOverlay()
                .allowsHitTesting(false)
                .zIndex(1000)

            // Existing XP celebration view
            if tabViewModel.showXPCelebration {
                GlobalXPCelebrationView(
                    xpGained: tabViewModel.xpGained,
                    totalXP: tabViewModel.totalXP,
                    newLevel: tabViewModel.newLevel,
                    onDismiss: {
                        tabViewModel.dismissXPCelebration()
                    }
                )
                .zIndex(999)
            }

            // Existing achievement notification
            if let newAchievement = tabViewModel.newAchievement {
                AchievementNotificationView(
                    achievement: newAchievement,
                    onDismiss: {
                        tabViewModel.dismissAchievement()
                    }
                )
                .zIndex(998)
            }

            // Debug floating button
            DebugFloatingButton()
                .zIndex(997)
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            Task {
                await HapticManager.shared.selection()
                tabViewModel.trackTabSwitch(to: newValue)
                debugService.trackUserAction("Tab Switch", details: ["from": oldValue, "to": newValue])
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .xpGained)) { notification in
            if let xpAmount = notification.userInfo?["amount"] as? Int {
                debugService.logProgressEvent(.xpGained, details: ["amount": xpAmount])
                tabViewModel.handleXPGain(amount: xpAmount)
            }
        }
        .task {
            debugService.info("App initializing", category: .general)
            await tabViewModel.initialize()
            debugService.info("App initialization complete", category: .general)
        }
        .withDebugOverlay()
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground

        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray
        ]
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance

        debugService.debug("Tab bar appearance configured", category: .ui)
    }
}


// MARK: - Global XP Celebration View
struct GlobalXPCelebrationView: View {
    let xpGained: Int
    let totalXP: Int
    let newLevel: Int?
    let onDismiss: () -> Void
    
    @State private var isAnimating = false
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)
            
            VStack(spacing: 32) {
                // Main celebration
                ZStack {
                    // Confetti explosion
                    if showConfetti {
                        ForEach(0..<30, id: \.self) { index in
                            ConfettiParticle(index: index)
                        }
                    }
                    
                    // XP animation
                    VStack(spacing: 24) {
                        // XP burst animation
                        ZStack {
                            ForEach(0..<8, id: \.self) { index in
                                Image(systemName: "star.fill")
                                    .font(.title)
                                    .foregroundColor(.yellow)
                                    .offset(
                                        x: isAnimating ? cos(Double(index) * .pi / 4) * 60 : 0,
                                        y: isAnimating ? sin(Double(index) * .pi / 4) * 60 : 0
                                    )
                                    .opacity(isAnimating ? 0.3 : 1.0)
                                    .animation(
                                        .easeOut(duration: 1.5).delay(Double(index) * 0.05),
                                        value: isAnimating
                                    )
                            }
                            
                            Text("+\(xpGained)")
                                .font(.system(size: 60, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .scaleEffect(isAnimating ? 1.2 : 0.5)
                                .animation(.spring(response: 0.8, dampingFraction: 0.6), value: isAnimating)
                        }
                        
                        // Level up notification (if applicable)
                        if let newLevel = newLevel {
                            VStack(spacing: 12) {
                                Text("🎉 LEVEL UP! 🎉")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("You're now Level \(newLevel)!")
                                    .font(.title2)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .scaleEffect(isAnimating ? 1.0 : 0.8)
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .animation(.spring(response: 1.0).delay(0.5), value: isAnimating)
                        }
                        
                        // Total XP display
                        VStack(spacing: 8) {
                            Text("Total XP: \(totalXP)")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Amazing progress! Keep it up!")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(1.0), value: isAnimating)
                    }
                }
                
                // Continue button
                ModernButton(
                    title: "Continue",
                    style: .success,
                    isFullWidth: false
                ) {
                    onDismiss()
                }
                .opacity(isAnimating ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.5).delay(1.5), value: isAnimating)
            }
            .padding()
        }
        .onAppear {
            DebugService.shared.debug("XP Celebration appeared: +\(xpGained) XP", category: .ui)
            
            withAnimation {
                isAnimating = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfetti = true
            }
            
            // Auto dismiss after 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                onDismiss()
            }
        }
    }
}

// MARK: - Achievement Notification View
struct AchievementNotificationView: View {
    let achievement: Achievement
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    
    var body: some View {
        VStack {
            Spacer()
            
            ModernCard {
                HStack(spacing: 16) {
                    Image(systemName: achievement.icon)
                        .font(.title)
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Achievement Unlocked!")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text(achievement.title)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text(achievement.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Button(action: onDismiss) {
                            Image(systemName: "xmark")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
                .padding()
            }
            .padding(.horizontal)
            .offset(y: isVisible ? 0 : 100)
            .opacity(isVisible ? 1 : 0)
            .animation(.spring(response: 0.6), value: isVisible)
        }
        .onAppear {
            DebugService.shared.debug("Achievement notification appeared: \(achievement.title)", category: .ui)
            isVisible = true
            
            // Auto dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                onDismiss()
            }
        }
    }
}

// MARK: - Confetti Particle
struct ConfettiParticle: View {
    let index: Int
    @State private var position = CGPoint.zero
    @State private var rotation = 0.0
    @State private var scale = 1.0
    
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(colors.randomElement()!)
            .frame(width: 12, height: 8)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .position(position)
            .onAppear {
                let angle = Double.random(in: 0...(2 * .pi))
                let distance = CGFloat.random(in: 150...300)
                
                withAnimation(.easeOut(duration: 3.0)) {
                    position = CGPoint(
                        x: cos(angle) * distance,
                        y: sin(angle) * distance - 200
                    )
                    rotation = Double.random(in: -720...720)
                    scale = 0.1
                }
            }
    }
}

// MARK: - Main Tab ViewModel (Updated with Debug Integration)
@MainActor
final class MainTabViewModel: ObservableObject {
    @Published var showXPCelebration = false
    @Published var xpGained = 0
    @Published var totalXP = 0
    @Published var newLevel: Int?
    @Published var newAchievement: Achievement?
    @Published var hasNewLessons = false
    @Published var newArtworkCount = 0
    
    private let progressService: ProgressServiceProtocol
    private let debugService = DebugService.shared
    private var previousXP = 0
    private var previousLevel = 1
    
    init() {
        self.progressService = Container.shared.progressService
        debugService.debug("MainTabViewModel initialized", category: .general)
    }
    
    func initialize() async {
        let tracker = debugService.startPerformanceTracking(operation: "Main Tab Initialization")
        
        await loadInitialData()
        setupNotifications()
        
        tracker.finish()
        debugService.info("MainTabViewModel initialization complete", category: .general)
    }
    
    private func loadInitialData() async {
        let progressService = self.progressService as! ProgressService
        totalXP = progressService.getTotalXP()
        previousXP = totalXP
        previousLevel = (totalXP / 100) + 1
        
        debugService.debug("Loaded initial data: XP=\(totalXP), Level=\(previousLevel)", category: .progress)
        
        // Check for new content
        checkForNewContent()
    }
    
    func handleXPGain(amount: Int) {
        debugService.logProgressEvent(.xpGained, details: ["amount": amount, "previousXP": totalXP])
        
        xpGained = amount
        totalXP += amount
        
        let newLevel = (totalXP / 100) + 1
        if newLevel > previousLevel {
            self.newLevel = newLevel
            previousLevel = newLevel
            debugService.logProgressEvent(.levelUp, details: ["newLevel": newLevel])
        }
        
        showXPCelebration = true
        
        Task {
            await HapticManager.shared.notification(.success)
        }
    }
    
    func dismissXPCelebration() {
        debugService.debug("XP celebration dismissed", category: .ui)
        
        withAnimation(.easeOut(duration: 0.3)) {
            showXPCelebration = false
        }
        
        // Reset values after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.xpGained = 0
            self.newLevel = nil
        }
    }
    
    func dismissAchievement() {
        debugService.debug("Achievement notification dismissed", category: .ui)
        
        withAnimation(.easeOut(duration: 0.3)) {
            newAchievement = nil
        }
    }
    
    func trackTabSwitch(to tab: Int) {
        debugService.trackUserAction("Tab Switch", details: ["tab": tab])
    }
    
    private func setupNotifications() {
        debugService.debug("Setting up notification observers", category: .general)
        // Setup for various app notifications
    }
    
    private func checkForNewContent() {
        // Check for new lessons
        hasNewLessons = false // Implement actual logic
        
        // Check for new artworks
        newArtworkCount = 0 // Implement actual logic
        
        debugService.debug("Content check complete: hasNewLessons=\(hasNewLessons), newArtworkCount=\(newArtworkCount)", category: .general)
    }
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let xpGained = Notification.Name("xpGained")
    static let achievementUnlocked = Notification.Name("achievementUnlocked")
    static let lessonCompleted = Notification.Name("lessonCompleted")
}

#Preview {
    MainTabView()
}
