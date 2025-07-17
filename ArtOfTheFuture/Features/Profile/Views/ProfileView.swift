import SwiftUI

struct ProfileView: View {
    @ObservedObject var gamification = GamificationEngine.shared
    @State private var userProfile: UserProfile?
    @State private var showEditProfile = false
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if isLoading {
                        ProgressView("Loading Profile...")
                            .frame(height: 200)
                    } else {
                        // Profile header
                        profileHeaderSection
                        
                        // Level Progress
                        levelProgressSection
                        
                        // Quick Stats Grid
                        statsGridSection
                        
                        // Recent Activity
                        recentActivitySection
                        
                        // Skills Overview
                        skillsOverviewSection
                        
                        // Achievements Preview
                        achievementsPreviewSection
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showEditProfile = true
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(userProfile: $userProfile)
            }
        }
        .task {
            await loadUserProfile()
        }
    }
    
    // MARK: - Profile Header Section
    private var profileHeaderSection: some View {
        VStack(spacing: 16) {
            // Avatar and basic info
            HStack(spacing: 20) {
                // Avatar with gradient background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 90, height: 90)
                    
                    Text(userProfile?.displayName.prefix(1).uppercased() ?? "A")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
                .overlay(
                    // Level badge
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Text("\(gamification.currentLevel)")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.white)
                        )
                        .offset(x: 30, y: -30)
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(userProfile?.displayName ?? "Artist")
                        .font(.title2.weight(.bold))
                    
                    Text("Level \(gamification.currentLevel) Artist")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Member since
                    if let profile = userProfile {
                        Text("Member since \(formatMemberDate(profile.lastActiveDate))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    // MARK: - Level Progress Section
    private var levelProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Level Progress")
                    .font(.headline)
                Spacer()
                Text("\(currentLevelXP)/\(xpForNextLevel) XP")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // XP Progress Bar
            ProgressView(value: levelProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(y: 3)
            
            Text("Total XP: \(gamification.totalXP)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Stats Grid Section
    private var statsGridSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            ProfileStatCard(
                title: "Current Streak",
                value: "\(gamification.currentStreak)",
                subtitle: "days",
                icon: "flame.fill",
                color: .orange
            )
            
            ProfileStatCard(
                title: "Best Streak",
                value: "\(userProfile?.longestStreak ?? 0)",
                subtitle: "days",
                icon: "star.fill",
                color: .yellow
            )
            
            ProfileStatCard(
                title: "Lessons",
                value: "\(userProfile?.completedLessons.count ?? 0)",
                subtitle: "completed",
                icon: "book.fill",
                color: .green
            )
            
            ProfileStatCard(
                title: "Badges",
                value: "\(userProfile?.earnedBadges.count ?? 0)",
                subtitle: "earned",
                icon: "award.fill",
                color: .purple
            )
        }
    }
    
    // MARK: - Recent Activity Section
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
            
            VStack(spacing: 8) {
                if let recentLessons = getRecentLessons() {
                    ForEach(recentLessons, id: \.lessonId) { progress in
                        ActivityRow(
                            title: "Lesson \(progress.lessonId)",
                            subtitle: "Last practiced \(formatDate(progress.lastAttemptDate))",
                            icon: "book.circle.fill",
                            color: .blue
                        )
                    }
                } else {
                    Text("No recent activity")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Skills Overview Section
    private var skillsOverviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Skills Progress")
                    .font(.headline)
                Spacer()
                Button("View All") {
                    // Navigate to skills view
                }
                .font(.caption)
            }
            
            if let skills = getTopSkills() {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(skills, id: \.skillId) { skill in
                        SkillCard(skill: skill)
                    }
                }
            } else {
                Text("Start learning to track your skills!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Achievements Preview Section
    private var achievementsPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Achievements")
                    .font(.headline)
                Spacer()
                Button("View All") {
                    // Navigate to achievements view
                }
                .font(.caption)
            }
            
            if let badges = getRecentBadges() {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(badges, id: \.self) { badgeId in
                        BadgePreview(badgeId: badgeId)
                    }
                }
            } else {
                Text("Complete lessons to earn achievements!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Methods
    private func loadUserProfile() async {
        do {
            userProfile = try await UserProgressService.shared.getCurrentUser()
        } catch {
            print("Failed to load user profile: \(error)")
        }
        isLoading = false
    }
    
    private var currentLevelXP: Int {
        gamification.totalXP % 100
    }
    
    private var xpForNextLevel: Int {
        100
    }
    
    private var levelProgress: Double {
        Double(currentLevelXP) / Double(xpForNextLevel)
    }
    
    private func formatMemberDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Never" }
        let formatter = RelativeDateTimeFormatter()
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func getRecentLessons() -> [LessonProgress]? {
        guard let profile = userProfile else { return nil }
        return Array(profile.lessonProgress.values
            .sorted { $0.lastAttemptDate ?? Date.distantPast > $1.lastAttemptDate ?? Date.distantPast }
            .prefix(3))
    }
    
    private func getTopSkills() -> [SkillProgress]? {
        guard let profile = userProfile else { return nil }
        return Array(profile.skillProgress.values
            .sorted { $0.level > $1.level }
            .prefix(4))
    }
    
    private func getRecentBadges() -> [String]? {
        guard let profile = userProfile else { return nil }
        return Array(profile.earnedBadges.suffix(6))
    }
}

// MARK: - Supporting Views

struct ProfileStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title.weight(.bold))
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption.weight(.medium))
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct ActivityRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct SkillCard: View {
    let skill: SkillProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: getSkillIcon(skill.skillId))
                    .foregroundColor(.blue)
                Spacer()
                Text("Lv.\(skill.level)")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.blue)
            }
            
            Text(skill.skillId.capitalized)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)
            
            ProgressView(value: Double(skill.xp % 100) / 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(y: 1.5)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func getSkillIcon(_ skillId: String) -> String {
        switch skillId.lowercased() {
        case "drawing": return "pencil"
        case "color": return "paintpalette"
        case "composition": return "rectangle.3.group"
        case "technique": return "hand.draw"
        default: return "star"
        }
    }
}

struct BadgePreview: View {
    let badgeId: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: getBadgeIcon(badgeId))
                .font(.title2)
                .foregroundColor(.orange)
            
            Text(getBadgeName(badgeId))
                .font(.caption2.weight(.medium))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
    
    private func getBadgeIcon(_ badgeId: String) -> String {
        switch badgeId {
        case "first_lesson": return "graduationcap"
        case "streak_week": return "flame"
        case "skill_master": return "star"
        default: return "award"
        }
    }
    
    private func getBadgeName(_ badgeId: String) -> String {
        switch badgeId {
        case "first_lesson": return "First Lesson"
        case "streak_week": return "Week Streak"
        case "skill_master": return "Skill Master"
        default: return "Achievement"
        }
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @Binding var userProfile: UserProfile?
    @Environment(\.dismiss) private var dismiss
    @State private var displayName = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile") {
                    TextField("Display Name", text: $displayName)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                }
            }
        }
        .onAppear {
            displayName = userProfile?.displayName ?? ""
        }
    }
    
    private func saveProfile() {
        Task {
            guard var profile = userProfile else { return }
            profile.displayName = displayName
            
            do {
                try await UserProgressService.shared.saveUserProfile(profile)
                await MainActor.run {
                    userProfile = profile
                    dismiss()
                }
            } catch {
                print("Failed to save profile: \(error)")
            }
        }
    }
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
