// MARK: - Updated Profile View (Real Firebase Data)
// File: ArtOfTheFuture/Features/Profile/Views/ProfileView.swift

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: FirebaseAuthService
    @StateObject private var userDataService = UserDataService.shared
    @State private var showEditProfile = false
    @State private var selectedTab = 0 // 0 = Profile, 1 = Settings
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                HStack(spacing: 0) {
                    Button(action: { selectedTab = 0 }) {
                        Text("Profile")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(selectedTab == 0 ? .white : .secondary)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(selectedTab == 0 ? Color.blue : Color.clear)
                            .cornerRadius(8)
                    }
                    
                    Button(action: { selectedTab = 1 }) {
                        Text("Settings")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(selectedTab == 1 ? .white : .secondary)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(selectedTab == 1 ? Color.blue : Color.clear)
                            .cornerRadius(8)
                    }
                }
                .padding(4)
                .background(Color(.systemGray6))
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
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let user = userDataService.currentUser {
            realProfileContent(user: user)
        } else {
            Text("Unable to load profile")
                .foregroundColor(.secondary)
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
                        .fill(Color.blue.gradient)
                        .overlay {
                            Text(String(user.displayName.prefix(1)).uppercased())
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)
                        }
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                
                // User Info
                VStack(spacing: 8) {
                    Text(user.displayName)
                        .font(.title2.bold())
                    
                    if let email = user.email {
                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Joined")
                        Text(user.joinedDate, style: .date)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
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
                
                StatCard(
                    title: "Total XP",
                    value: "\(user.totalXP)",
                    icon: "bolt.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Current Streak",
                    value: "\(user.currentStreak)",
                    icon: "flame.fill",
                    color: .red
                )
                
                StatCard(
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
                    Spacer()
                    Text("\(user.totalXP % 100)/100 XP")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: user.levelProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Settings Content
    
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
            
            // Preferences Section
            ProfileSettingsSection(title: "Preferences") {
                HStack {
                    Label("Dark Mode", systemImage: "moon.fill")
                    Spacer()
                    Toggle("", isOn: $isDarkMode)
                }
                .padding()
            }
            
            // Sign Out
            Button(action: {
                authService.signOut()
            }) {
                HStack {
                    Image(systemName: "arrow.right.square")
                    Text("Sign Out")
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            Spacer()
        }
    }
}

// MARK: - Supporting Views

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
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ProfileSettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color(.systemGray6))
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
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
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
                    .disabled(displayName.isEmpty || isLoading)
                }
            }
            .onAppear {
                displayName = userDataService.userDisplayName
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(FirebaseAuthService())
}
