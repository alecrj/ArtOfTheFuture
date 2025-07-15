import SwiftUI

struct HomeDashboardView: View {
    @StateObject private var viewModel = HomeDashboardViewModel()
    @State private var selectedLesson: Lesson?
    @State private var showProfile = false
    @State private var scrollOffset: CGFloat = 0
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Background gradient
            backgroundGradient
            
            // Main content layout
            if DeviceType.current.isIPad && horizontalSizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
            }
            
            // Celebration overlays (streaks, XP gain)
            celebrationOverlays
        }
        .task {
            await viewModel.loadDashboard()
        }
        .sheet(item: $selectedLesson) { lesson in
            LessonPlayerView(lesson: lesson)
                .onDisappear {
                    Task { await viewModel.refreshXP() }
                }
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                ColorPalette.primaryBlue.opacity(0.05),
                ColorPalette.primaryPurple.opacity(0.03),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - iPhone Layout
        private var iPhoneLayout: some View {
            ScrollView {
                VStack(spacing: Dimensions.paddingLarge) {
                    // Header
                    headerSection
                        .padding(.horizontal)
                    
                    // Hero Stats
                    heroStatsSection
                        .padding(.horizontal)
                    
                    // Daily Progress
                    dailyProgressSection
                        .padding(.horizontal)
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Continue Learning
                    continueLearningSection
                    
                    // Recent Achievements
                    if !viewModel.achievements.isEmpty {
                        achievementsSection
                    }
                    
                    // Weekly Activity
                    weeklyActivitySection
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .refreshable {
                await viewModel.refreshDashboard()
            }
        }




    
    // MARK: - iPad Layout
        private var iPadLayout: some View {
            ScrollView {
                VStack(spacing: Dimensions.paddingXLarge) {
                    // Header
                    headerSection
                        .padding(.horizontal, Dimensions.paddingXLarge)
                    
                    // Stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
                              spacing: Dimensions.paddingLarge) {
                        heroStatsSection
                        dailyProgressSection
                    }
                    .padding(.horizontal, Dimensions.paddingXLarge)
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Main content grid
                    HStack(alignment: .top, spacing: Dimensions.paddingLarge) {
                        // Left column
                        VStack(spacing: Dimensions.paddingLarge) {
                            continueLearningSection
                            weeklyActivitySection
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Right column (achievements)
                        if !viewModel.achievements.isEmpty {
                            achievementsSection
                                .frame(maxWidth: 400)
                        }
                    }
                    .padding(.horizontal, Dimensions.paddingXLarge)
                }
                .padding(.vertical)
            }
            .refreshable {
                await viewModel.refreshDashboard()
            }
        }

    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(alignment: .top, spacing: Dimensions.paddingMedium) {
            VStack(alignment: .leading, spacing: 8) {
                Text(greeting)
                    .font(Typography.caption)
                    .foregroundColor(ColorPalette.textSecondary)
                
                Text(viewModel.userName)
                    .font(Typography.largeTitle)
                    .foregroundColor(ColorPalette.textPrimary)
                
                // Motivational message
                Text(motivationalMessage)
                    .font(Typography.subheadline)
                    .foregroundColor(ColorPalette.textSecondary)
                    .opacity(0.8)
            }
            
            Spacer()
            
            // Profile button with avatar
            Button(action: { showProfile = true }) {
                ZStack {
                    Circle()
                        .fill(ColorPalette.primaryGradient)
                        .frame(width: 56, height: 56)
                    Text(viewModel.userName.prefix(1).uppercased())
                        .font(Typography.title2)
                        .foregroundColor(.white)
                }
                .overlay(
                    // Notification badge
                    Circle()
                        .fill(ColorPalette.error)
                        .frame(width: 12, height: 12)
                        .offset(x: 20, y: -20)
                        .opacity(viewModel.hasNotifications ? 1 : 0)
                )
            }
        }
    }
    
    // MARK: - Hero Stats Section
    private var heroStatsSection: some View {
        ModernCard {
            VStack(spacing: Dimensions.paddingMedium) {
                // Level & XP
                HStack(spacing: Dimensions.paddingMedium) {
                    // Level Badge
                    ZStack {
                        Circle()
                            .fill(ColorPalette.warningGradient)
                            .frame(width: 80, height: 80)
                        VStack(spacing: 2) {
                            Text("LVL")
                                .font(Typography.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Text("\(viewModel.currentLevel)")
                                .font(Typography.title1)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    
                    // XP Progress
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("\(viewModel.totalXP) XP")
                                .font(Typography.headline)
                                .fontWeight(.bold)
                            Spacer()
                            Text("\(viewModel.xpToNextLevel) to level up")
                                .font(Typography.caption)
                                .foregroundColor(ColorPalette.textSecondary)
                        }
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray5))
                                    .frame(height: 12)
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(ColorPalette.warningGradient)
                                    .frame(width: geometry.size.width * viewModel.levelProgress, height: 12)
                            }
                        }
                        .frame(height: 12)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Daily Progress Section
    private var dailyProgressSection: some View {
        ModernCard {
            VStack(spacing: Dimensions.paddingMedium) {
                Text("Daily Progress")
                    .font(Typography.headline)
                // (Placeholder content – implement actual daily progress UI as needed)
                Text("Coming soon")
                    .font(Typography.body)
                    .foregroundColor(ColorPalette.textSecondary)
            }
            .padding()
        }
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: Dimensions.paddingSmall) {
            Text("Quick Start")
                .font(Typography.headline)
                .foregroundColor(ColorPalette.textPrimary)
                .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Dimensions.paddingMedium) {
                    QuickActionCard(
                        title: "Free Draw",
                        subtitle: "Express yourself",
                        icon: "paintbrush.fill",
                        gradient: ColorPalette.primaryGradient,
                        action: {}
                    )
                    QuickActionCard(
                        title: "Daily Challenge",
                        subtitle: "5 min exercise",
                        icon: "flag.fill",
                        gradient: ColorPalette.warningGradient,
                        action: {}
                    )
                    QuickActionCard(
                        title: "Continue Lesson",
                        subtitle: "Resume learning",
                        icon: "play.circle.fill",
                        gradient: ColorPalette.successGradient,
                        action: {}
                    )
                    if DeviceType.current.isIPad {
                        QuickActionCard(
                            title: "Practice Mode",
                            subtitle: "Improve skills",
                            icon: "pencil.and.ruler.fill",
                            gradient: ColorPalette.premiumGradient,
                            action: {}
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Continue Learning Section
    private var continueLearningSection: some View {
        VStack(alignment: .leading, spacing: Dimensions.paddingMedium) {
            HStack {
                Text("Continue Learning")
                    .font(Typography.headline)
                    .foregroundColor(ColorPalette.textPrimary)
                Spacer()
                Button("See All") {}
                    .font(Typography.subheadline)
                    .foregroundColor(ColorPalette.primaryBlue)
            }
            .padding(.horizontal)
            VStack(spacing: Dimensions.paddingSmall) {
                ForEach(viewModel.recommendedLessons.prefix(3)) { lesson in
                    PremiumLessonCard(
                        lesson: lesson,
                        progress: viewModel.getLessonProgress(for: lesson.id),
                        isLocked: false
                    ) {
                        selectedLesson = lesson
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Achievements Section
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: Dimensions.paddingMedium) {
            HStack {
                Text("Recent Achievements")
                    .font(Typography.headline)
                    .foregroundColor(ColorPalette.textPrimary)
                Spacer()
                Text("\(viewModel.achievements.filter { $0.isUnlocked }.count) / \(viewModel.achievements.count)")
                    .font(Typography.caption)
                    .foregroundColor(ColorPalette.textSecondary)
            }
            .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Dimensions.paddingMedium) {
                    ForEach(viewModel.achievements) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Weekly Activity Section
    private var weeklyActivitySection: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: Dimensions.paddingMedium) {
                HStack {
                    Text("This Week")
                        .font(Typography.headline)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(viewModel.weeklyStats.totalMinutes) min")
                            .font(Typography.subheadline)
                            .fontWeight(.medium)
                    }
                }
                // Activity bar chart
                WeeklyActivityChart(stats: viewModel.weeklyStats)
                    .frame(height: 120)
                // Summary stats
                HStack(spacing: Dimensions.paddingLarge) {
                    WeeklyStatItem(value: "\(viewModel.weeklyStats.totalXP)", label: "XP Earned", color: .yellow)
                    WeeklyStatItem(value: "\(Int(viewModel.weeklyStats.averageMinutesPerDay))", label: "Avg Min/Day", color: .blue)
                    WeeklyStatItem(value: "\(viewModel.weeklyStats.days.filter { $0.completed }.count)", label: "Days Active", color: .green)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Celebration Overlays
    private var celebrationOverlays: some View {
        Group {
            if viewModel.showStreakCelebration {
                ModernStreakCelebration(streak: viewModel.currentStreak) {
                    viewModel.showStreakCelebration = false
                }
            }
            if viewModel.showXPAnimation {
                ModernXPAnimation(xpGained: viewModel.newXPGained) {
                    viewModel.showXPAnimation = false
                }
            }
        }
    }
    
    // MARK: - Helpers (Greeting & Motivation)
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }
    private var motivationalMessage: String {
        let messages = [
            "Ready to create something amazing?",
            "Your artistic journey continues!",
            "Let's make today creative!",
            "Time to unleash your creativity!",
            "Every stroke makes you better!"
        ]
        return messages.randomElement() ?? messages[0]
    }
}

// MARK: - Quick Action Card
struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: LinearGradient
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.impact(.medium)
            action()
        }) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Typography.headline)
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(Typography.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .frame(width: 140, height: 140)
            .padding()
            .background(gradient)
            .cornerRadius(Dimensions.cornerRadiusLarge)
            .shadow(color: Color.black.opacity(0.2), radius: 12, y: 6)  // fixed shadow color
            .scaleEffect(isPressed ? 0.95 : 1)
        }
        .buttonStyle(PressedButtonStyle())
    }
}

// MARK: - Achievement Card
struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(
                    achievement.isUnlocked ?
                    ColorPalette.warningGradient :
                    LinearGradient(colors: [Color(.systemGray5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 80, height: 80)
                Image(systemName: achievement.icon)
                    .font(.system(size: 36))
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
            }
            Text(achievement.title)
                .font(Typography.caption)
                .foregroundColor(ColorPalette.textPrimary)
                .multilineTextAlignment(.center)
                .frame(width: 100)
            if !achievement.isUnlocked {
                ProgressView(value: achievement.progress)
                    .frame(width: 60)
                    .tint(ColorPalette.primaryOrange)
            }
        }
        .opacity(achievement.isUnlocked ? 1 : 0.6)
    }
}

// MARK: - Weekly Activity Chart
struct WeeklyActivityChart: View {
    let stats: WeeklyStats
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(stats.days) { day in
                VStack(spacing: 4) {
                    // Bar
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            day.completed ?
                            ColorPalette.successGradient :
                            LinearGradient(colors: [Color(.systemGray5)], startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 32, height: barHeight(for: day))
                        .animation(AnimationPresets.smooth, value: day.minutes)
                    // Day label
                    Text(dayLabel(for: day.date))
                        .font(Typography.caption)
                        .foregroundColor(ColorPalette.textSecondary)
                }
            }
        }
    }
    
    private func barHeight(for day: WeeklyStats.DayStats) -> CGFloat {
        let maxMinutes = CGFloat(stats.days.map { $0.minutes }.max() ?? 60)
        let height = (CGFloat(day.minutes) / maxMinutes) * 80
        return max(8, height)
    }
    
    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
}

// MARK: - Weekly Stat Item
struct WeeklyStatItem: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(Typography.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(Typography.caption)
                .foregroundColor(ColorPalette.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Modern Streak Celebration
struct ModernStreakCelebration: View {
    let streak: Int
    let onDismiss: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)
            VStack(spacing: 32) {
                // Animated flame rings
                ZStack {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(ColorPalette.warningGradient)
                            .frame(width: 150 - CGFloat(index * 30), height: 150 - CGFloat(index * 30))
                            .opacity(0.3)
                            .scaleEffect(isAnimating ? 1.3 : 0.8)
                            .animation(AnimationPresets.smooth.repeatForever(autoreverses: true).delay(Double(index) * 0.2),
                                       value: isAnimating)
                    }
                    Image(systemName: "flame.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(ColorPalette.warningGradient)
                        .scaleEffect(isAnimating ? 1.1 : 0.9)
                        .animation(AnimationPresets.smooth.repeatForever(autoreverses: true), value: isAnimating)
                }
                VStack(spacing: 16) {
                    Text("\(streak) Day Streak!")
                        .font(Typography.largeTitle)
                        .foregroundColor(.white)
                    Text("You're on fire! Keep it up!")
                        .font(Typography.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
                ModernButton(title: "Continue", style: .primary, isFullWidth: false, action: onDismiss)
            }
            .padding()
            .onAppear {
                isAnimating = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    onDismiss()
                }
            }
        }
    }
}

// MARK: - Modern XP Animation
struct ModernXPAnimation: View {
    let xpGained: Int
    let onDismiss: () -> Void
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Burst of stars
            ForEach(0..<8) { index in
                Image(systemName: "star.fill")
                    .font(.title)
                    .foregroundColor(.yellow)
                    .offset(
                        x: scale > 0.5 ? cos(Double(index) * .pi/4) * 100 : 0,
                        y: scale > 0.5 ? sin(Double(index) * .pi/4) * 100 : 0
                    )
                    .opacity(opacity * 0.5)
                    .scaleEffect(scale)
            }
            // XP gained text
            VStack(spacing: 16) {
                Text("+\(xpGained) XP")
                    .font(Typography.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                    .scaleEffect(scale)
                    .opacity(opacity)
                Text("Great job!")
                    .font(Typography.headline)
                    .foregroundColor(.white)
                    .opacity(opacity)
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    scale = 1.0
                    opacity = 1.0
                }
                // Auto-dismiss after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    onDismiss()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(opacity * 0.4).ignoresSafeArea())
    }
}
