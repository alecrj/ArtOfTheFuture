import SwiftUI

struct ProfileView: View {
    @State private var user = User.mock
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    ProfileHeaderView(user: user)
                    
                    // Stats Grid
                    StatsGridView(user: user)
                    
                    // Achievements
                    AchievementsSection()
                    
                    // Learning Progress
                    LearningProgressSection()
                    
                    // Settings
                    SettingsSection(showingSettings: $showingSettings)
                }
                .padding(.bottom, 100)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
}

struct ProfileHeaderView: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                
                Text(user.displayName.prefix(2).uppercased())
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // Name and Level
            VStack(spacing: 4) {
                Text(user.displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Level \(user.currentLevel)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Level Progress Bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(user.totalXP) XP")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(user.currentLevel * 100) XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: geometry.size.width * user.levelProgress, height: 8)
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}

struct StatsGridView: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 16) {
            ProfileStatCard(
                icon: "flame.fill",
                value: "\(user.currentStreak)",
                label: "Day Streak",
                color: .orange
            )
            
            ProfileStatCard(
                icon: "star.fill",
                value: "\(user.totalXP)",
                label: "Total XP",
                color: .yellow
            )
            
            ProfileStatCard(
                icon: "paintbrush.fill",
                value: "7",
                label: "Artworks",
                color: .blue
            )
        }
        .padding(.horizontal)
    }
}

// Renamed from StatCard to ProfileStatCard to avoid conflicts
struct ProfileStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}

struct AchievementsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Achievements")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<3) { _ in
                        AchievementBadge()
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct AchievementBadge: View {
    var body: some View {
        VStack {
            Circle()
                .fill(Color.yellow.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                )
            
            Text("First Steps")
                .font(.caption2)
                .multilineTextAlignment(.center)
                .frame(width: 70)
        }
    }
}

struct LearningProgressSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Learning Progress")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ProgressRow(
                    title: "Drawing Basics",
                    progress: 0.75,
                    color: .blue
                )
                
                ProgressRow(
                    title: "Color Theory",
                    progress: 0.45,
                    color: .purple
                )
                
                ProgressRow(
                    title: "Composition",
                    progress: 0.30,
                    color: .pink
                )
            }
            .padding(.horizontal)
        }
    }
}

struct ProgressRow: View {
    let title: String
    let progress: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

struct SettingsSection: View {
    @Binding var showingSettings: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Button {
                showingSettings = true
            } label: {
                HStack {
                    Image(systemName: "gearshape")
                    Text("Settings")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            
            Button {
                // Handle sign out
            } label: {
                HStack {
                    Image(systemName: "arrow.left.square")
                    Text("Sign Out")
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .foregroundColor(.red)
        }
        .padding(.horizontal)
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    Label("Email", systemImage: "envelope")
                    Label("Subscription", systemImage: "creditcard")
                }
                
                Section("Preferences") {
                    Label("Notifications", systemImage: "bell")
                    Label("Daily Goal", systemImage: "target")
                    Label("Privacy", systemImage: "lock")
                }
                
                Section("Support") {
                    Label("Help Center", systemImage: "questionmark.circle")
                    Label("Contact Us", systemImage: "bubble.left")
                    Label("Rate App", systemImage: "star")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
