// MARK: - Updated Home Dashboard View (Real Firebase Data)
// File: ArtOfTheFuture/Features/Home/Views/HomeDashboardView.swift

import SwiftUI

struct HomeDashboardView: View {
    @StateObject private var viewModel = HomeDashboardViewModel()
    @StateObject private var userDataService = UserDataService.shared
    @EnvironmentObject var authService: FirebaseAuthService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if viewModel.isLoading {
                        loadingView
                    } else {
                        headerSection
                        dailyProgressCard
                        quickActionsRow
                        recommendedLessonsSection
                        achievementsSection
                        weeklyActivityCard
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100) // Tab bar spacing
            }
            .navigationTitle("Good morning")
            .navigationBarTitleDisplayMode(.large)
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
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            viewModel.showXPAnimation = false
                        }
                    }
            }
        }
        .alert("🎉 Level Up!", isPresented: $viewModel.showLevelUpCelebration) {
            Button("Awesome!") { }
        } message: {
            Text("Congratulations! You've reached level \(viewModel.currentLevel)!")
        }
        .alert("🔥 Streak Milestone!", isPresented: $viewModel.showStreakCelebration) {
            Button("Keep it up!") { }
        } message: {
            Text("Amazing! You've maintained a \(viewModel.currentStreak)-day streak!")
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading your dashboard...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Welcome Message
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back,")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.userName.isEmpty ? "Artist" : viewModel.userName)
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Profile Image
                AsyncImage(url: URL(string: userDataService.currentUser?.profileImageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.blue.gradient)
                        .overlay {
                            Text(String(viewModel.userName.prefix(1)).uppercased())
                                .font(.title2.bold())
                                .foregroundColor(.white)
                        }
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            }
            
            // Streak & Level Info
            HStack(spacing: 16) {
                // Current Streak
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(viewModel.currentStreak)")
                            .font(.title2.bold())
                        Text("day streak")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                
                // Current Level
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Level \(viewModel.currentLevel)")
                            .font(.title2.bold())
                        Text("\(viewModel.totalXP) XP")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
            }
        }
    }
    
    // MARK: - Daily Progress Card
    
    private var dailyProgressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Progress")
                    .font(.headline.weight(.semibold))
                
                Spacer()
                
                Text("\(viewModel.todayMinutes)/\(viewModel.targetMinutes) min")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.blue)
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                ProgressView(value: Double(viewModel.todayMinutes), total: Double(viewModel.targetMinutes))
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                
                HStack {
                    Text("🏆 \(viewModel.lessonsCompleted) lessons completed")
                    Spacer()
                    Text("⚡ \(viewModel.todayXP) XP earned")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsRow: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline.weight(.semibold))
            
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Continue Learning",
                    icon: "book.fill",
                    color: .blue
                ) {
                    // Navigate to lessons
                }
                
                QuickActionButton(
                    title: "Start Drawing",
                    icon: "paintbrush.fill",
                    color: .purple
                ) {
                    // Navigate to drawing
                }
                
                QuickActionButton(
                    title: "View Gallery",
                    icon: "photo.stack.fill",
                    color: .green
                ) {
                    // Navigate to gallery
                }
            }
        }
    }
    
    // MARK: - Recommended Lessons
    
    private var recommendedLessonsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recommended for You")
                    .font(.headline.weight(.semibold))
                
                Spacer()
                
                Button("See All") {
                    // Navigate to all lessons
                }
                .font(.subheadline.weight(.medium))
                .foregroundColor(.blue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.recommendedLessons, id: \.id) { lesson in
                        LessonCard(lesson: lesson) {
                            // Navigate to lesson
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
            
            // Simple weekly stats
            HStack {
                VStack(alignment: .leading) {
                    Text("\(viewModel.weeklyStats.totalMinutes)")
                        .font(.title2.bold())
                    Text("Minutes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(viewModel.weeklyStats.totalXP)")
                        .font(.title2.bold())
                    Text("Total XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(Int(viewModel.weeklyStats.averageMinutesPerDay))")
                        .font(.title2.bold())
                    Text("Avg/Day")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Supporting Views

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

struct XPGainAnimation: View {
    let amount: Int
    
    var body: some View {
        Text("+\(amount) XP")
            .font(.title.bold())
            .foregroundColor(.yellow)
            .padding()
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .shadow(radius: 10)
            )
            .scaleEffect(1.2)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: amount)
    }
}

struct HomeScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    HomeDashboardView()
        .environmentObject(FirebaseAuthService())
}
