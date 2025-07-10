import SwiftUI

struct HomeDashboardView: View {
    @StateObject private var viewModel = HomeDashboardViewModel()
    @State private var showingProfile = false
    @State private var selectedLesson: Lesson?
    @State private var showingStreakCelebration = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with streak
                    headerSection
                    
                    // Daily Progress
                    dailyProgressSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Recommended Lessons
                    recommendedLessonsSection
                    
                    // Recent Artwork
                    if !viewModel.recentArtworks.isEmpty {
                        recentArtworkSection
                    }
                    
                    // Weekly Stats
                    weeklyStatsSection
                    
                    // Achievements
                    if !viewModel.achievements.isEmpty {
                        achievementsSection
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .refreshable {
                await viewModel.refreshDashboard()
            }
            .task {
                await viewModel.loadDashboard()
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
            }
            .sheet(item: $selectedLesson) { lesson in
                // Lesson detail view
                Text("Lesson: \(lesson.title)")
            }
            .overlay(
                Group {
                    if showingStreakCelebration {
                        StreakCelebrationView(
                            streak: viewModel.currentStreak,
                            onDismiss: {
                                showingStreakCelebration = false
                            }
                        )
                    }
                }
            )
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: 16) {
            // Greeting
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(viewModel.userName)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            // Streak Badge
            StreakBadge(
                streak: viewModel.currentStreak,
                onTap: {
                    if viewModel.currentStreak > 0 {
                        showingStreakCelebration = true
                        Task {
                            await HapticManager.shared.notification(.success)
                        }
                    }
                }
            )
            
            // Profile Button
            Button(action: { showingProfile = true }) {
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(viewModel.userName.prefix(1).uppercased())
                            .font(.headline)
                            .foregroundColor(.white)
                    )
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Daily Progress Section
    private var dailyProgressSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Today's Progress")
                    .font(.headline)
                
                Spacer()
                
                Text("\(viewModel.todayProgress.completedMinutes) / \(viewModel.todayProgress.targetMinutes) min")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Progress Ring
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 12)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: viewModel.todayProgress.progressPercentage)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6), value: viewModel.todayProgress.progressPercentage)
                
                // Center content
                VStack(spacing: 8) {
                    if viewModel.todayProgress.isComplete {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                    } else {
                        Text("\(Int(viewModel.todayProgress.progressPercentage * 100))%")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                    Text("\(viewModel.todayProgress.xpEarned) XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 150, height: 150)
            .padding(.vertical)
            
            // Stats
            HStack(spacing: 32) {
                VStack(spacing: 4) {
                    Text("\(viewModel.todayProgress.lessonsCompleted)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Lessons")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(viewModel.todayProgress.completedMinutes)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Minutes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(viewModel.todayProgress.xpEarned)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("XP Earned")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        .padding(.horizontal)
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        HStack(spacing: 12) {
            QuickActionButton(
                title: "Draw",
                icon: "paintbrush.fill",
                color: .blue,
                action: {
                    // Navigate to drawing
                }
            )
            
            QuickActionButton(
                title: "Learn",
                icon: "book.fill",
                color: .green,
                action: {
                    // Navigate to lessons
                }
            )
            
            QuickActionButton(
                title: "Challenge",
                icon: "flag.fill",
                color: .orange,
                action: {
                    // Navigate to challenges
                }
            )
            
            QuickActionButton(
                title: "Gallery",
                icon: "photo.stack",
                color: .purple,
                action: {
                    // Navigate to gallery
                }
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Recommended Lessons Section
    private var recommendedLessonsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recommended for You")
                    .font(.headline)
                
                Spacer()
                
                Button("See All") {
                    // Navigate to all lessons
                }
                .font(.caption)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.recommendedLessons) { lesson in
                        RecommendedLessonCard(
                            lesson: lesson,
                            action: {
                                selectedLesson = lesson
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Recent Artwork Section
    private var recentArtworkSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Artwork")
                    .font(.headline)
                
                Spacer()
                
                Button("View Gallery") {
                    // Navigate to gallery
                }
                .font(.caption)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.recentArtworks) { artwork in
                        RecentArtworkCard(artwork: artwork)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Weekly Stats Section
    private var weeklyStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Week")
                .font(.headline)
                .padding(.horizontal)
            
            WeeklyStatsChart(stats: viewModel.weeklyStats)
                .frame(height: 200)
                .padding(.horizontal)
            
            HStack(spacing: 32) {
                VStack(spacing: 4) {
                    Text("\(viewModel.weeklyStats.totalMinutes)")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("Total Minutes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("\(viewModel.weeklyStats.totalXP)")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("XP Earned")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(String(format: "%.0f", viewModel.weeklyStats.averageMinutesPerDay))
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("Avg/Day")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        .padding(.horizontal)
    }
    
    // MARK: - Achievements Section
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Achievements")
                    .font(.headline)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to achievements
                }
                .font(.caption)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.achievements.prefix(5), id: \.id) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Helper Properties
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }
}

// MARK: - Supporting Views
struct StreakBadge: View {
    let streak: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundColor(streak > 0 ? .orange : .gray)
                
                Text("\(streak)")
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(streak > 0 ? Color.orange.opacity(0.2) : Color(.systemGray5))
            )
        }
        .buttonStyle(.plain)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct RecommendedLessonCard: View {
    let lesson: Lesson
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Thumbnail
                RoundedRectangle(cornerRadius: 12)
                    .fill(lesson.category.categoryColor.opacity(0.3)) // FIXED: categoryColor instead of color
                    .frame(width: 200, height: 120)
                    .overlay(
                        Image(systemName: lesson.category.iconName) // FIXED: iconName instead of icon
                            .font(.largeTitle)
                            .foregroundColor(lesson.category.categoryColor) // FIXED: categoryColor instead of color
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    HStack {
                        Label("\(lesson.estimatedMinutes)m", systemImage: "clock")
                        Spacer()
                        Label("\(lesson.xpReward) XP", systemImage: "star.fill")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .frame(width: 200)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        }
        .buttonStyle(.plain)
    }
}

struct RecentArtworkCard: View {
    let artwork: Artwork
    
    var body: some View {
        VStack {
            if let thumbnailData = artwork.thumbnailData,
               let uiImage = UIImage(data: thumbnailData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .frame(width: 100, height: 100)
            }
            
            Text(artwork.relativeDate)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.yellow.opacity(0.2) : Color(.systemGray5))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
            }
            
            Text(achievement.title)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 80)
            
            if !achievement.isUnlocked {
                ProgressView(value: achievement.progress)
                    .frame(width: 60)
                    .tint(.yellow)
            }
        }
    }
}

#Preview {
    HomeDashboardView()
}
