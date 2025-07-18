// MARK: - Apple Fitness-Inspired Home Dashboard View
// File: ArtOfTheFuture/Features/Home/Views/HomeDashboardView.swift

import SwiftUI

struct HomeDashboardView: View {
    @StateObject private var viewModel = HomeDashboardViewModel()
    @StateObject private var userDataService = UserDataService.shared
    @EnvironmentObject var authService: FirebaseAuthService
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if viewModel.isLoading {
                        loadingView
                    } else {
                        activityRingsSection
                        metricsCards
                        continueSection
                        weeklyProgressCard
                        achievementsSection
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            .background(backgroundGradient)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(greetingText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(viewModel.userName.isEmpty ? "Artist" : viewModel.userName)
                            .font(.headline.bold())
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    profileButton
                }
            }
            .refreshable {
                await viewModel.refreshDashboard()
            }
        }
        .onAppear {
            Task {
                await viewModel.loadDashboard()
            }
        }
        .overlay(alignment: .bottom) {
            if viewModel.showXPAnimation {
                XPGainAnimation(amount: viewModel.newXPGained)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                viewModel.showXPAnimation = false
                            }
                        }
                    }
            }
        }
    }
    
    // MARK: - Background Gradient
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: colorScheme == .dark ?
                [Color.black, Color(white: 0.05)] :
                [Color(white: 0.98), Color(white: 0.94)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Greeting Text
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
    
    // MARK: - Profile Button
    
    private var profileButton: some View {
        AsyncImage(url: URL(string: userDataService.currentUser?.profileImageURL ?? "")) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Image(systemName: "person.circle.fill")
                .font(.title2)
                .foregroundColor(.gray)
        }
        .frame(width: 32, height: 32)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ActivityRingsPlaceholder()
                .frame(width: 200, height: 200)
                .shimmer()
            
            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 150, height: 20)
                    .shimmer()
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 100, height: 16)
                    .shimmer()
            }
        }
        .padding(.top, 60)
    }
    
    // MARK: - Activity Rings Section
    
    private var activityRingsSection: some View {
        VStack(spacing: 32) {
            // Activity Rings
            ZStack {
                // Background rings
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(
                            ringColor(for: index).opacity(0.2),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .frame(width: ringSize(for: index), height: ringSize(for: index))
                }
                
                // Progress rings
                ActivityRing(
                    progress: Double(viewModel.todayMinutes) / Double(viewModel.targetMinutes),
                    color: .red,
                    size: 200
                )
                
                ActivityRing(
                    progress: viewModel.levelProgress,
                    color: .green,
                    size: 160
                )
                
                ActivityRing(
                    progress: min(Double(viewModel.lessonsCompleted) / 3.0, 1.0),
                    color: .blue,
                    size: 120
                )
                
                // Center metrics
                VStack(spacing: 4) {
                    Text("\(viewModel.todayXP)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.red, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("XP TODAY")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 220)
            .padding(.top, 20)
            
            // Ring Labels
            HStack(spacing: 32) {
                RingLabel(
                    value: "\(viewModel.todayMinutes)",
                    label: "MIN",
                    color: .red,
                    progress: Double(viewModel.todayMinutes) / Double(viewModel.targetMinutes)
                )
                
                RingLabel(
                    value: "\(Int(viewModel.levelProgress * 100))%",
                    label: "LEVEL",
                    color: .green,
                    progress: viewModel.levelProgress
                )
                
                RingLabel(
                    value: "\(viewModel.lessonsCompleted)",
                    label: "LESSONS",
                    color: .blue,
                    progress: min(Double(viewModel.lessonsCompleted) / 3.0, 1.0)
                )
            }
        }
    }
    
    // MARK: - Metrics Cards
    
    private var metricsCards: some View {
        HStack(spacing: 16) {
            MetricCard(
                title: "Streak",
                value: "\(viewModel.currentStreak)",
                subtitle: "days",
                icon: "flame.fill",
                gradient: [.orange, .red]
            )
            
            MetricCard(
                title: "Level",
                value: "\(viewModel.currentLevel)",
                subtitle: "\(viewModel.xpToNextLevel) to next",
                icon: "star.fill",
                gradient: [.purple, .pink]
            )
        }
    }
    
    // MARK: - Continue Section
    
    private var continueSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Continue Learning")
                .font(.title3.bold())
            
            if viewModel.recommendedLessons.isEmpty {
                EmptyLessonsCard()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.recommendedLessons.prefix(3), id: \.id) { lesson in
                            ContinueLessonCard(lesson: lesson) {
                                // Navigate to lesson
                            }
                        }
                        
                        SeeAllCard {
                            // Navigate to all lessons
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
    }
    
    // MARK: - Weekly Progress Card
    
    private var weeklyProgressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Weekly Progress")
                    .font(.title3.bold())
                
                Spacer()
                
                Text("\(viewModel.weeklyStats.totalMinutes) min")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            
            WeeklyProgressChart(stats: viewModel.weeklyStats)
                .frame(height: 140)
                .padding(.horizontal, -8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    // MARK: - Achievements Section
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Achievements")
                    .font(.title3.bold())
                
                Spacer()
                
                Text("\(viewModel.achievements.filter { $0.isUnlocked }.count)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.orange)
                    +
                Text(" / \(viewModel.achievements.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 16) {
                ForEach(viewModel.achievements.prefix(6), id: \.id) { achievement in
                    AchievementTile(achievement: achievement)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func ringSize(for index: Int) -> CGFloat {
        switch index {
        case 0: return 200
        case 1: return 160
        default: return 120
        }
    }
    
    private func ringColor(for index: Int) -> Color {
        switch index {
        case 0: return .red
        case 1: return .green
        default: return .blue
        }
    }
}

// MARK: - Activity Ring Component

struct ActivityRing: View {
    let progress: Double
    let color: Color
    let size: CGFloat
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        Circle()
            .trim(from: 0, to: animatedProgress)
            .stroke(
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                style: StrokeStyle(lineWidth: 20, lineCap: .round)
            )
            .frame(width: size, height: size)
            .rotationEffect(.degrees(-90))
            .onAppear {
                withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                    animatedProgress = min(progress, 1.0)
                }
            }
            .onChange(of: progress) { newValue in
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    animatedProgress = min(newValue, 1.0)
                }
            }
    }
    
    private var gradientColors: [Color] {
        switch color {
        case .red:
            return [.red, .pink]
        case .green:
            return [.green, Color(red: 0.7, green: 1, blue: 0)]
        case .blue:
            return [.blue, .cyan]
        default:
            return [color, color.opacity(0.8)]
        }
    }
}

// MARK: - Ring Label

struct RingLabel: View {
    let value: String
    let label: String
    let color: Color
    let progress: Double
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundColor(.secondary)
                .tracking(0.5)
            
            // Mini progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(color.opacity(0.2))
                    
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * min(progress, 1.0))
                }
            }
            .frame(height: 3)
        }
        .frame(width: 60)
    }
}

// MARK: - Metric Card

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let gradient: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(
                        LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundColor(.secondary)
                .tracking(0.5)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

// MARK: - Continue Lesson Card

struct ContinueLessonCard: View {
    let lesson: Lesson
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Progress indicator
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [lesson.color, lesson.color.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 100, height: 4)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(lesson.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    HStack {
                        Label("\(lesson.estimatedMinutes)m", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(lesson.xpReward) XP")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(lesson.color)
                    }
                }
                
                Spacer()
            }
            .padding()
            .frame(width: 200, height: 120)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
        }
        .buttonStyle(FitnessScaleButtonStyle())
    }
}

// MARK: - See All Card

struct SeeAllCard: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("See All")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .frame(width: 120, height: 120)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Empty Lessons Card

struct EmptyLessonsCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.largeTitle)
                .foregroundColor(.gray)
            
            Text("No lessons available")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Check back later for new content")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

// MARK: - Weekly Progress Chart

struct WeeklyProgressChart: View {
    let stats: WeeklyStats
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(stats.days, id: \.date) { day in
                VStack(spacing: 4) {
                    // Bar
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            day.minutes > 0 ?
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .top,
                                endPoint: .bottom
                            ) :
                            LinearGradient(
                                colors: [Color.gray.opacity(0.3)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: barHeight(for: day.minutes))
                    
                    // Day label
                    Text(dayLabel(for: day.date))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func barHeight(for minutes: Int) -> CGFloat {
        let maxMinutes = stats.days.map(\.minutes).max() ?? 30
        let normalizedHeight = CGFloat(minutes) / CGFloat(max(maxMinutes, 1))
        return max(normalizedHeight * 100, 4)
    }
    
    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
}

// MARK: - Achievement Tile

struct AchievementTile: View {
    let achievement: Achievement
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked ?
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
            
            Text(achievement.title)
                .font(.caption2.weight(.medium))
                .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 30)
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        }
    }
}

// MARK: - Supporting Components

struct ActivityRingsPlaceholder: View {
    var body: some View {
        ZStack {
            ForEach(0..<3) { index in
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: size(for: index), height: size(for: index))
            }
        }
    }
    
    private func size(for index: Int) -> CGFloat {
        switch index {
        case 0: return 200
        case 1: return 160
        default: return 120
        }
    }
}

struct FitnessScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension View {
    func shimmer() -> some View {
        self
            .redacted(reason: .placeholder)
            .shimmering()
    }
    
    func shimmering() -> some View {
        self.overlay(
            GeometryReader { geometry in
                let gradient = LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.3),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                
                Rectangle()
                    .fill(gradient)
                    .offset(x: -geometry.size.width)
                    .animation(
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false),
                        value: UUID()
                    )
            }
            .clipped()
        )
    }
}

// MARK: - XP Gain Animation (Updated)

struct XPGainAnimation: View {
    let amount: Int
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "star.fill")
                .font(.title2)
                .foregroundColor(.yellow)
            
            Text("+\(amount) XP")
                .font(.title2.bold())
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .yellow.opacity(0.3), radius: 10, x: 0, y: 5)
        )
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

#Preview {
    HomeDashboardView()
        .environmentObject(FirebaseAuthService())
}
