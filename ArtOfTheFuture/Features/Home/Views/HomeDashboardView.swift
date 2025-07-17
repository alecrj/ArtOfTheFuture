import SwiftUI

struct HomeDashboardView: View {
    @StateObject private var viewModel = HomeDashboardViewModel()
    @StateObject private var gamification = GamificationEngine.shared
    @State private var selectedLesson: Lesson?
    @State private var showProfile = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showStreakAnimation = false
    @State private var showXPAnimation = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dynamic background
                backgroundGradient
                
                // Main content
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 24) {
                        // Welcome Header
                        welcomeHeader
                        
                        // Hero Stats Cards
                        heroStatsGrid
                        
                        // Daily Progress Ring
                        dailyProgressCard
                        
                        // Quick Actions
                        quickActionsGrid
                        
                        // Continue Learning
                        continueLearningSection
                        
                        // Recent Achievements
                        achievementsSection
                        
                        // Weekly Activity Chart
                        weeklyActivityCard
                        
                        // Spacer for bottom padding
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
                .refreshable {
                    await refreshDashboard()
                }
                
                // Floating streak celebration
                if showStreakAnimation {
                    streakCelebration
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            await loadDashboard()
        }
        .sheet(item: $selectedLesson) { lesson in
            LessonPlayerView(lesson: lesson)
                .onDisappear {
                    Task { await refreshDashboard() }
                }
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.1),
                Color.purple.opacity(0.05),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 1.0), value: colorScheme)
    }
    
    // MARK: - Welcome Header
    private var welcomeHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(currentGreeting)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(viewModel.userName)
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .scaleEffect(showStreakAnimation ? 1.2 : 1.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showStreakAnimation)
                    
                    Text("\(gamification.currentStreak) day streak")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            // Profile Avatar
            Button(action: { showProfile = true }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Text(viewModel.userName.prefix(1).uppercased())
                        .font(.title.weight(.bold))
                        .foregroundColor(.white)
                    
                    // Notification badge
                    if viewModel.hasNotifications {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .offset(x: 22, y: -22)
                    }
                }
                .scaleEffect(showProfile ? 0.95 : 1.0)
                .animation(.spring(response: 0.3), value: showProfile)
            }
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Hero Stats Grid
    private var heroStatsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            // Level & XP Card
            HomeStatCard(
                title: "Level \(gamification.currentLevel)",
                subtitle: "\(gamification.totalXP) XP",
                icon: "star.fill",
                color: .blue,
                progress: levelProgress
            )
            
            // Today's Progress
            HomeStatCard(
                title: "Today's Goal",
                subtitle: "\(viewModel.todayProgress.completedMinutes)/\(viewModel.todayProgress.targetMinutes) min",
                icon: "target",
                color: .green,
                progress: todayProgress
            )
        }
    }
    
    // MARK: - Daily Progress Card
    private var dailyProgressCard: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Daily Progress")
                    .font(.headline.weight(.semibold))
                
                Spacer()
                
                Text("\(Int(todayProgress * 100))%")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.green)
            }
            
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: todayProgress)
                    .stroke(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: todayProgress)
                
                // Center content
                VStack(spacing: 4) {
                    Text("\(viewModel.todayProgress.completedMinutes)")
                        .font(.title.weight(.bold))
                        .foregroundColor(.primary)
                    
                    Text("minutes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Today's stats
            HStack(spacing: 32) {
                HomeStatItem(
                    icon: "book.fill",
                    value: "\(viewModel.todayProgress.lessonsCompleted)",
                    label: "Lessons"
                )
                
                HomeStatItem(
                    icon: "star.fill",
                    value: "\(viewModel.todayProgress.xpEarned)",
                    label: "XP Earned"
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Quick Actions Grid
    private var quickActionsGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline.weight(.semibold))
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                QuickActionCard(
                    title: "Start Drawing",
                    icon: "paintbrush.fill",
                    color: .purple,
                    action: { /* Navigate to drawing */ }
                )
                
                QuickActionCard(
                    title: "Browse Lessons",
                    icon: "book.fill",
                    color: .blue,
                    action: { /* Navigate to lessons */ }
                )
                
                QuickActionCard(
                    title: "View Gallery",
                    icon: "photo.stack.fill",
                    color: .orange,
                    action: { /* Navigate to gallery */ }
                )
                
                QuickActionCard(
                    title: "Daily Challenge",
                    icon: "trophy.fill",
                    color: .red,
                    action: { /* Show daily challenge */ }
                )
            }
        }
    }
    
    // MARK: - Continue Learning Section
    private var continueLearningSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Continue Learning")
                    .font(.headline.weight(.semibold))
                
                Spacer()
                
                Button("See All") {
                    // Navigate to lessons
                }
                .font(.subheadline.weight(.medium))
                .foregroundColor(.blue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.recommendedLessons.prefix(5), id: \.id) { lesson in
                        LessonCard(lesson: lesson) {
                            selectedLesson = lesson
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Achievements Section
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Achievements")
                    .font(.headline.weight(.semibold))
                
                Spacer()
                
                Text("\(viewModel.achievements.filter { $0.isUnlocked }.count) / \(viewModel.achievements.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.achievements.prefix(6), id: \.id) { achievement in
                        AchievementBadge(achievement: achievement)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Weekly Activity Card
    private var weeklyActivityCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("This Week's Activity")
                    .font(.headline.weight(.semibold))
                
                Spacer()
                
                Text("\(viewModel.weeklyStats.totalMinutes) min")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.blue)
            }
            
            // Simple bar chart
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(viewModel.weeklyStats.days.indices, id: \.self) { index in
                    let day = viewModel.weeklyStats.days[index]
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: day.completed ? [.blue, .purple] : [.gray.opacity(0.3)],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(width: 32, height: max(8, CGFloat(day.minutes) * 2))
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: day.minutes)
                        
                        Text(dayLabel(for: day.date))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 80)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Streak Celebration
    private var streakCelebration: some View {
        VStack(spacing: 16) {
            Image(systemName: "flame.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
                .scaleEffect(showStreakAnimation ? 1.2 : 0.8)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showStreakAnimation)
            
            Text("🔥 Streak Milestone! 🔥")
                .font(.title.weight(.bold))
                .multilineTextAlignment(.center)
            
            Text("\(gamification.currentStreak) days in a row!")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        )
        .scaleEffect(showStreakAnimation ? 1.0 : 0.1)
        .opacity(showStreakAnimation ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showStreakAnimation)
    }
    
    // MARK: - Helper Methods
    private func loadDashboard() async {
        await viewModel.loadDashboard()
        
        // Show streak animation if it's a milestone
        if gamification.currentStreak > 0 && gamification.currentStreak % 7 == 0 {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5)) {
                showStreakAnimation = true
            }
            
            // Hide after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    showStreakAnimation = false
                }
            }
        }
    }
    
    private func refreshDashboard() async {
        await viewModel.refreshDashboard()
    }
    
    private var currentGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }
    
    private var levelProgress: Double {
        let currentLevelXP = gamification.totalXP % 100
        return Double(currentLevelXP) / 100.0
    }
    
    private var todayProgress: Double {
        let completed = Double(viewModel.todayProgress.completedMinutes)
        let target = Double(viewModel.todayProgress.targetMinutes)
        return target > 0 ? min(completed / target, 1.0) : 0.0
    }
    
    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct HomeStatCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.caption.weight(.medium))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.semibold))
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(y: 2)
                .animation(.easeInOut(duration: 1.0), value: progress)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        )
    }
}

struct HomeStatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.headline.weight(.bold))
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(color)
                            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(HomeScaleButtonStyle())
    }
}

struct LessonCard: View {
    let lesson: Lesson
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: lesson.icon)
                        .font(.title2)
                        .foregroundColor(lesson.color)
                    
                    Spacer()
                    
                    Text("\(lesson.estimatedMinutes)m")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                }
                
                Text(lesson.title)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(lesson.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                HStack {
                    Text(lesson.category.rawValue)
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(lesson.color.opacity(0.1))
                        .foregroundColor(lesson.color)
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Text("\(lesson.xpReward) XP")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.blue)
                }
            }
            .padding(16)
            .frame(width: 200)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(HomeScaleButtonStyle())
    }
}

struct AchievementBadge: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.icon)
                .font(.title)
                .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(achievement.isUnlocked ? Color.yellow.opacity(0.1) : Color.gray.opacity(0.1))
                )
            
            Text(achievement.title)
                .font(.caption.weight(.medium))
                .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 80, height: 100)
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
        .scaleEffect(achievement.isUnlocked ? 1.0 : 0.9)
    }
}

struct HomeScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview
struct HomeDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        HomeDashboardView()
    }
}
