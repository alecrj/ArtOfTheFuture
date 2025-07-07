import SwiftUI

struct ProfileView: View {
    @State private var user = MockDataService.shared.getMockUser()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    ProfileHeaderView(user: user)
                    
                    // Stats Cards
                    StatsGridView(user: user)
                    
                    // Achievements Preview
                    AchievementsSection()
                    
                    // Settings Button
                    Button(action: {}) {
                        Label("Settings", systemImage: "gearshape.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Profile")
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct ProfileHeaderView: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 100, height: 100)
                .overlay(
                    Text(user.displayName.prefix(2).uppercased())
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
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
            StatCard(
                icon: "flame.fill",
                value: "\(user.currentStreak)",
                label: "Day Streak",
                color: .orange
            )
            
            StatCard(
                icon: "star.fill",
                value: "\(user.totalXP)",
                label: "Total XP",
                color: .yellow
            )
            
            StatCard(
                icon: "paintbrush.fill",
                value: "7",
                label: "Artworks",
                color: .blue
            )
        }
        .padding(.horizontal)
    }
}

struct StatCard: View {
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

#Preview {
    ProfileView()
}
