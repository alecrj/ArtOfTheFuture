import SwiftUI

// Note: Charts framework requires iOS 16+, using custom chart implementation for compatibility

// MARK: - Weekly Stats Chart (Custom Implementation)
struct WeeklyStatsChart: View {
    let stats: WeeklyStats
    @State private var selectedDay: WeeklyStats.DayStats?
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(stats.days) { day in
                VStack(spacing: 4) {
                    // Bar
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(width: 32, height: 120)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                day.completed ?
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .bottom,
                                    endPoint: .top
                                ) :
                                LinearGradient(
                                    colors: [Color(.systemGray4), Color(.systemGray5)],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(
                                width: 32,
                                height: max(8, CGFloat(day.minutes) / max(60, CGFloat(stats.days.map { $0.minutes }.max() ?? 60)) * 120)
                            )
                    }
                    
                    // Checkmark for completed days
                    if day.completed {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                    } else {
                        Spacer()
                            .frame(height: 12)
                    }
                    
                    // Day label
                    Text(dayLabel(for: day.date))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .onTapGesture {
                    selectedDay = selectedDay?.id == day.id ? nil : day
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            if let selectedDay = selectedDay {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(selectedDay.minutes) min")
                        .font(.headline)
                    Text("\(selectedDay.xp) XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(8)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(radius: 4)
                .padding()
            }
        }
    }
    
    private func dayLabel(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

// MARK: - Streak Celebration View
struct StreakCelebrationView: View {
    let streak: Int
    let onDismiss: () -> Void
    
    @State private var isAnimating = false
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)
            
            // Content
            VStack(spacing: 32) {
                // Animated flame
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.orange.opacity(0.8),
                                    Color.orange.opacity(0.4),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                    
                    // Flame icon
                    Image(systemName: "flame.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange, .red],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(isAnimating ? 1.0 : 0)
                        .rotationEffect(.degrees(isAnimating ? 0 : -20))
                }
                
                // Text content
                VStack(spacing: 16) {
                    Text("\(streak) Day Streak!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(streakMessage)
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                // Continue button
                Button(action: onDismiss) {
                    Text("Keep Going!")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.8)
            }
            .padding()
            
            // Confetti
            if isAnimating {
                CelebrationView()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAnimating = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showContent = true
                }
            }
            
            // Auto dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                onDismiss()
            }
        }
    }
    
    private var streakMessage: String {
        switch streak {
        case 1: return "Great start! Keep it up!"
        case 2...6: return "You're building a habit!"
        case 7: return "One week strong! 🎉"
        case 8...13: return "Amazing consistency!"
        case 14: return "Two weeks! You're unstoppable!"
        case 15...29: return "You're on fire! 🔥"
        case 30: return "One month! Incredible dedication!"
        default: return "Legendary streak! Keep going!"
        }
    }
}

// MARK: - Home Dashboard View Model
@MainActor
final class HomeDashboardViewModel: ObservableObject {
    @Published var userName = "Artist"
    @Published var currentStreak = 0
    @Published var todayProgress = DailyProgress(
        targetMinutes: 15,
        completedMinutes: 0,
        lessonsCompleted: 0,
        xpEarned: 0
    )
    @Published var recommendedLessons: [Lesson] = []
    @Published var recentArtworks: [Artwork] = []
    @Published var weeklyStats = WeeklyStats(
        days: [],
        totalMinutes: 0,
        totalXP: 0,
        averageMinutesPerDay: 0
    )
    @Published var achievements: [Achievement] = []
    @Published var isLoading = false
    
    private let userService: UserServiceProtocol
    private let galleryService: GalleryServiceProtocol
    
    init(
        userService: UserServiceProtocol? = nil,
        galleryService: GalleryServiceProtocol? = nil
    ) {
        self.userService = userService ?? UserService()
        self.galleryService = galleryService ?? Container.shared.galleryService
    }
    
    func loadDashboard() async {
        isLoading = true
        
        // Load user data
        if let userId = UserDefaults.standard.string(forKey: "currentUserId"),
           let user = try? await userService.getUser(id: userId) {
            userName = user.displayName
            currentStreak = user.currentStreak
        }
        
        // Load today's progress
        await loadTodayProgress()
        
        // Load weekly stats
        if let stats = try? await userService.getWeeklyStats() {
            weeklyStats = stats
        }
        
        // Load recommended lessons
        await loadRecommendedLessons()
        
        // Load recent artworks
        await loadRecentArtworks()
        
        // Load achievements
        loadAchievements()
        
        isLoading = false
    }
    
    func refreshDashboard() async {
        await loadDashboard()
    }
    
    private func loadTodayProgress() async {
        // This would load from actual data
        // For now, using mock data
        let targetMinutes = UserDefaults.standard.object(forKey: "dailyGoalMinutes") as? Int ?? 15
        
        todayProgress = DailyProgress(
            targetMinutes: targetMinutes,
            completedMinutes: Int.random(in: 0...targetMinutes),
            lessonsCompleted: Int.random(in: 0...3),
            xpEarned: Int.random(in: 0...200)
        )
    }
    
    private func loadRecommendedLessons() async {
        // This would use the recommendation engine
        recommendedLessons = MockDataService.shared.getMockLessons()
            .filter { !$0.isLocked }
            .prefix(5)
            .map { $0 }
    }
    
    private func loadRecentArtworks() async {
        if let artworks = try? await galleryService.loadArtworks() {
            recentArtworks = artworks
                .sorted { $0.modifiedAt > $1.modifiedAt }
                .prefix(5)
                .map { $0 }
        }
    }
    
    private func loadAchievements() {
        // Mock achievements
        achievements = [
            Achievement(
                id: "1",
                title: "First Steps",
                description: "Complete your first lesson",
                icon: "shoe.2.fill",
                unlockedDate: Date(),
                progress: 1.0,
                xpReward: 50
            ),
            Achievement(
                id: "2",
                title: "Artist in Training",
                description: "Draw for 5 days in a row",
                icon: "paintpalette.fill",
                unlockedDate: nil,
                progress: Double(min(currentStreak, 5)) / 5.0,
                xpReward: 100
            ),
            Achievement(
                id: "3",
                title: "Color Explorer",
                description: "Use 10 different colors",
                icon: "eyedropper.halffull",
                unlockedDate: nil,
                progress: 0.7,
                xpReward: 75
            )
        ]
    }
}

// MARK: - Lesson Category Extensions
extension Lesson.LessonCategory {
    var color: Color {
        switch self {
        case .basics: return .blue
        case .sketching: return .green
        case .coloring: return .orange
        case .shading: return .purple
        case .perspective: return .red
        case .portrait: return .pink
        case .landscape: return .teal
        }
    }
    
    var icon: String {
        switch self {
        case .basics: return "pencil"
        case .sketching: return "scribble"
        case .coloring: return "paintpalette"
        case .shading: return "circle.lefthalf.filled"
        case .perspective: return "cube"
        case .portrait: return "person.crop.circle"
        case .landscape: return "photo"
        }
    }
}

// MARK: - Animated Progress Ring
struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let gradient: LinearGradient
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color(.systemGray5), lineWidth: lineWidth)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6), value: progress)
        }
    }
}

// MARK: - Level Badge
struct LevelBadge: View {
    let level: Int
    let xp: Int
    let nextLevelXP: Int
    
    var progress: Double {
        let currentLevelXP = xp % 100
        return Double(currentLevelXP) / 100.0
    }
    
    var body: some View {
        VStack(spacing: 8) {
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
                
                Text("\(level)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // XP Progress
            VStack(spacing: 2) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(.systemGray5))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * progress, height: 4)
                    }
                }
                .frame(width: 50, height: 4)
                
                Text("\(xp % 100)/100 XP")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}
