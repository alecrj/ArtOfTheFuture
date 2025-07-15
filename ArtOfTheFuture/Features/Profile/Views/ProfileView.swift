import SwiftUI

struct ProfileView: View {
    @ObservedObject var gamification = GamificationEngine.shared

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile header
                    VStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)

                        Text("Level \(gamification.currentLevel)")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("\(gamification.totalXP) Total XP")
                            .foregroundColor(.secondary)
                    }

                    // Stats
                    HStack(spacing: 40) {
                        VStack {
                            Text("\(gamification.currentStreak)")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Day Streak")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        VStack {
                            Text("\(gamification.currentLevel)")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Level")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Profile")
        }
    }
}

// Optional preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
