// MARK: - Updated Profile View (Dark Mode Toggle Removed)
// File: ArtOfTheFuture/Features/Profile/Views/ProfileView.swift

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: FirebaseAuthService
    @StateObject private var userDataService = UserDataService.shared
    @State private var showEditProfile = false
    @State private var selectedTab = 0 // 0 = Profile, 1 = Settings

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                HStack(spacing: 0) {
                    Button(action: { selectedTab = 0 }) {
                        Text("Profile")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(selectedTab == 0 ? .white : .white.opacity(0.7))
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(selectedTab == 0 ? Color.blue : Color.clear)
                            .cornerRadius(8)
                    }
                    
                    Button(action: { selectedTab = 1 }) {
                        Text("Settings")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(selectedTab == 1 ? .white : .white.opacity(0.7))
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(selectedTab == 1 ? Color.blue : Color.clear)
                            .cornerRadius(8)
                    }
                }
                .padding(4)
                .background(Color(.systemGray5).opacity(0.3))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top)
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        if selectedTab == 0 {
                            profileContent
                        } else {
                            settingsContent
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(selectedTab == 0 ? "Profile" : "Settings")
            .toolbar {
                if selectedTab == 0 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Edit") {
                            showEditProfile = true
                        }
                        .foregroundColor(.cyan)
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
        }
        .preferredColorScheme(.dark) // Force dark mode
        .onAppear {
            // Load user data when view appears
            Task {
                if let uid = authService.currentUserUID {
                    await userDataService.loadUserData(uid: uid)
                }
            }
        }
    }
    
    // MARK: - Profile Content
    
    @ViewBuilder
    private var profileContent: some View {
        if userDataService.isLoading {
            ProgressView("Loading profile...")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let user = userDataService.currentUser {
            realProfileContent(user: user)
        } else {
            Text("Unable to load profile")
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    @ViewBuilder
    private func realProfileContent(user: User) -> some View {
        VStack(spacing: 24) {
            // Profile Header
            VStack(spacing: 16) {
                // Avatar
                AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay {
                            Text(String(user.displayName.prefix(1)).uppercased())
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)
                        }
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(.ultraThinMaterial, lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                
                // User Info
                VStack(spacing: 8) {
                    Text(user.displayName)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    if let email = user.email {
                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    HStack {
                        Text("Joined")
                        Text(user.joinedDate, style: .date)
                    }
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.vertical)
            
            // Stats Cards
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ProfileStatCard(
                    title: "Level",
                    value: "\(user.currentLevel)",
                    icon: "star.fill",
                    color: .yellow
                )
                
                ProfileStatCard(
                    title: "Total XP",
                    value: "\(user.totalXP)",
                    icon: "bolt.fill",
                    color: .orange
                )
                
                ProfileStatCard(
                    title: "Current Streak",
                    value: "\(user.currentStreak)",
                    icon: "flame.fill",
                    color: .red
                )
                
                ProfileStatCard(
                    title: "Progress",
                    value: "\(Int(user.levelProgress * 100))%",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Level \(user.currentLevel)")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(user.totalXP % 100)/100 XP")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                ProgressView(value: user.levelProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Settings Content (Dark Mode Toggle Removed)
    
    @ViewBuilder
    private var settingsContent: some View {
        VStack(spacing: 20) {
            // Account Section
            ProfileSettingsSection(title: "Account") {
                ProfileSettingsRow(
                    icon: "person.fill",
                    title: "Edit Profile",
                    action: { showEditProfile = true }
                )
                
                ProfileSettingsRow(
                    icon: "envelope.fill",
                    title: "Email",
                    subtitle: authService.currentUserEmail ?? "Not available"
                )
            }
            
            // App Info Section (New section to replace Preferences)
            ProfileSettingsSection(title: "App Info") {
                ProfileSettingsRow(
                    icon: "info.circle.fill",
                    title: "Version",
                    subtitle: "1.0.0"
                )
                
                ProfileSettingsRow(
                    icon: "paintbrush.fill",
                    title: "Theme",
                    subtitle: "Theme 1 (implement more themes later)"
                )
            }
            
            // Sign Out
            Button(action: {
                authService.signOut()
            }) {
                HStack {
                    Image(systemName: "arrow.right.square")
                        .foregroundColor(.red)
                    Text("Sign Out")
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            }
            
            Spacer()
        }
    }
}

// MARK: - Supporting Views (Updated for Dark Mode)

struct ProfileStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(color: color.opacity(0.2), radius: 4, y: 2)
    }
}

struct ProfileSettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                content
            }
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
    }
}

struct ProfileSettingsRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: action ?? {}) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.cyan)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .foregroundColor(.white)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding()
        }
        .disabled(action == nil)
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var userDataService = UserDataService.shared
    @State private var displayName = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile Information") {
                    TextField("Display Name", text: $displayName)
                        .foregroundColor(.white)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.cyan)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            isLoading = true
                            await userDataService.updateDisplayName(displayName)
                            isLoading = false
                            dismiss()
                        }
                    }
                    .foregroundColor(.cyan)
                    .disabled(displayName.isEmpty || isLoading)
                }
            }
            .onAppear {
                displayName = userDataService.userDisplayName
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ProfileView()
        .environmentObject(FirebaseAuthService())
}
