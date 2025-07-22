// MARK: - Main Tab View (Gallery and Profile Tabs Removed)
// File: ArtOfTheFuture/App/MainTabView.swift

import SwiftUI

// MARK: - Achievement Notification View
struct AchievementNotificationView: View {
    let achievement: Achievement
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Achievement Unlocked!")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.cyan)
                    
                    HStack(spacing: 16) {
                        Image(systemName: achievement.icon)
                            .font(.title)
                            .foregroundColor(.yellow)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(achievement.title)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(achievement.description)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Button(action: onDismiss) {
                            Image(systemName: "xmark")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .shadow(radius: 8)
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
    @State private var position = CGPoint(x: 0, y: 0)
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    let colors = [Color.yellow, Color.orange, Color.pink, Color.purple, Color.cyan, Color.green]
    
    var body: some View {
        Rectangle()
            .fill(colors[index % colors.count])
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
            Color.black.opacity(0.7)
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
                                    .opacity(isAnimating ? 0.8 : 1.0)
                                    .animation(.spring(response: 1.0, dampingFraction: 0.8).delay(Double(index) * 0.1), value: isAnimating)
                            }
                            
                            // Center XP text
                            Text("+\(xpGained) XP")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                                .scaleEffect(isAnimating ? 1.2 : 1.0)
                                .animation(.spring(response: 0.6), value: isAnimating)
                        }
                        
                        // Level up notification
                        if let newLevel = newLevel {
                            VStack(spacing: 8) {
                                Text("LEVEL UP!")
                                    .font(.headline.bold())
                                    .foregroundColor(.cyan)
                                
                                Text("Level \(newLevel)")
                                    .font(.title.bold())
                                    .foregroundColor(.white)
                            }
                            .scaleEffect(isAnimating ? 1.0 : 0.8)
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .animation(.spring(response: 0.8).delay(0.3), value: isAnimating)
                        }
                        
                        // Total XP
                        Text("Total: \(totalXP) XP")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .animation(.easeInOut.delay(0.5), value: isAnimating)
                    }
                }
                
                // Dismiss button
                Button("Continue") {
                    onDismiss()
                }
                .font(.headline.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
                .shadow(color: .cyan.opacity(0.3), radius: 8, y: 4)
                .opacity(isAnimating ? 1.0 : 0.0)
                .animation(.easeInOut.delay(1.0), value: isAnimating)
            }
            .padding(40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                isAnimating = true
                showConfetti = true
            }
        }
    }
}

// MARK: - Main Tab View Model
@MainActor
final class MainTabViewModel: ObservableObject {
    @Published var showXPCelebration = false
    @Published var xpGained = 0
    @Published var totalXP = 0
    @Published var newLevel: Int?
    @Published var newAchievement: Achievement?
    @Published var hasNewLessons = false
    
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
        // Check for new lessons - Enhanced logic could go here
        hasNewLessons = false
        
        debugService.debug("Content check complete: hasNewLessons=\(hasNewLessons)", category: .general)
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var tabViewModel = MainTabViewModel()
    @StateObject private var debugService = DebugService.shared

    var body: some View {
        ZStack {
            // TabView with Gallery and Profile tabs removed - now only 3 tabs
            TabView(selection: $selectedTab) {
                HomeDashboardView()
                    .tabItem {
                        Label("Home", systemImage: selectedTab == 0 ? "house.fill" : "house")
                    }
                    .tag(0)
                    .debugOnAppear("Home Tab", category: .ui)

                LessonsView()
                    .tabItem {
                        Label("Learn", systemImage: selectedTab == 1 ? "book.fill" : "book")
                    }
                    .tag(1)
                    .badge(tabViewModel.hasNewLessons ? "New" : nil)
                    .debugOnAppear("Learn Tab", category: .ui)

                DrawingView()
                    .tabItem {
                        Label("Draw", systemImage: selectedTab == 2 ? "paintbrush.fill" : "paintbrush")
                    }
                    .tag(2)
                    .debugOnAppear("Draw Tab", category: .ui)
            }
            .accentColor(.cyan)
            .onAppear {
                setupTabBarAppearance()
                GamificationEngine.shared.updateStreak()
                debugService.info("MainTabView appeared", category: .ui)
            }

            // Global XP animation overlay, non-interactive and top‑most
            XPAnimationOverlay()
                .allowsHitTesting(false)
                .zIndex(1000)

            // XP celebration view
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

            // Achievement notification
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
        .preferredColorScheme(.dark) // Force dark theme
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Dark theme colors for tab bar
        appearance.backgroundColor = UIColor.black
        appearance.selectionIndicatorTintColor = UIColor.systemCyan

        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray
        ]
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemCyan
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemCyan
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance

        debugService.debug("Tab bar appearance configured for dark theme", category: .ui)
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
