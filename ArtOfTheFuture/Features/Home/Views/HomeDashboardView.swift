// MARK: - Art Learning Central Hub - HomeDashboardView
// File: ArtOfTheFuture/Features/Home/Views/HomeDashboardView.swift

import SwiftUI
import PencilKit

struct HomeDashboardView: View {
    @StateObject private var viewModel = HomeDashboardViewModel()
    @StateObject private var userDataService = UserDataService.shared
    @EnvironmentObject var authService: FirebaseAuthService
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Artistic background
                ArtisticBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        if viewModel.isLoading {
                            loadingView
                        } else {
                            heroSection
                            todaysCreativePrompt
                            progressRings
                            recentArtworksSection
                            learningPathSection
                            weeklyInsights
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(greetingText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(viewModel.userName.isEmpty ? "Artist" : viewModel.userName)
                            .font(.headline.bold())
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        notificationButton
                        profileButton
                    }
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
    }
    
    // MARK: - Artistic Background
    
    struct ArtisticBackground: View {
        var body: some View {
            ZStack {
                // Base gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.95, blue: 0.99),
                        Color(red: 0.95, green: 0.98, blue: 0.99),
                        Color(red: 0.99, green: 0.95, blue: 0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Paint splash effects
                GeometryReader { geometry in
                    ForEach(0..<3) { index in
                        PaintSplash()
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            )
                            .opacity(0.03)
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(spacing: 20) {
            // Motivational quote
            VStack(spacing: 8) {
                Text("Create Something")
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Beautiful Today")
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .pink, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .padding(.top, 20)
            
            // Quick action buttons
            HStack(spacing: 16) {
                QuickStartButton(
                    title: "Start Drawing",
                    icon: "paintbrush.fill",
                    gradient: [.purple, .pink],
                    action: {
                        // Navigate to drawing
                    }
                )
                
                QuickStartButton(
                    title: "Continue Lesson",
                    icon: "book.fill",
                    gradient: [.blue, .cyan],
                    action: {
                        // Continue last lesson
                    }
                )
            }
        }
    }
    
    // MARK: - Today's Creative Prompt
    
    private var todaysCreativePrompt: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Today's Challenge", systemImage: "sparkles")
                    .font(.headline.weight(.semibold))
                
                Spacer()
                
                Text("Day \(viewModel.currentStreak)")
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.orange.opacity(0.2)))
                    .foregroundColor(.orange)
            }
            
            CreativePromptCard(
                prompt: "Draw your favorite memory using only 3 colors",
                difficulty: "Intermediate",
                timeEstimate: "15-20 min",
                xpReward: 50
            ) {
                // Start challenge
            }
        }
    }
    
    // MARK: - Progress Rings
    
    private var progressRings: some View {
        HStack(spacing: 20) {
            // Today's Progress
            VStack(spacing: 12) {
                ZStack {
                    ArtisticProgressRing(
                        progress: Double(viewModel.todayMinutes) / Double(viewModel.targetMinutes),
                        gradient: [.purple, .pink],
                        size: 100,
                        lineWidth: 12
                    )
                    
                    VStack(spacing: 2) {
                        Text("\(viewModel.todayMinutes)")
                            .font(.title2.bold())
                        Text("min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text("Today")
                    .font(.subheadline.weight(.medium))
            }
            
            // Weekly Progress
            VStack(spacing: 12) {
                ZStack {
                    ArtisticProgressRing(
                        progress: Double(viewModel.lessonsCompleted) / 7.0,
                        gradient: [.blue, .cyan],
                        size: 100,
                        lineWidth: 12
                    )
                    
                    VStack(spacing: 2) {
                        Text("\(viewModel.lessonsCompleted)")
                            .font(.title2.bold())
                        Text("lessons")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text("This Week")
                    .font(.subheadline.weight(.medium))
            }
            
            // Level Progress
            VStack(spacing: 12) {
                ZStack {
                    ArtisticProgressRing(
                        progress: viewModel.levelProgress,
                        gradient: [.orange, .yellow],
                        size: 100,
                        lineWidth: 12
                    )
                    
                    VStack(spacing: 2) {
                        Text("Lvl \(viewModel.currentLevel)")
                            .font(.title3.bold())
                        Text("\(Int(viewModel.levelProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text("Level")
                    .font(.subheadline.weight(.medium))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Recent Artworks Section
    
    private var recentArtworksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Your Recent Creations", systemImage: "photo.artframe")
                    .font(.headline.weight(.semibold))
                
                Spacer()
                
                Button("Gallery") {
                    // Navigate to gallery
                }
                .font(.subheadline.weight(.medium))
                .foregroundColor(.purple)
            }
            
            if viewModel.recentArtworks.isEmpty {
                EmptyArtworkCard()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.recentArtworks, id: \.self) { artworkId in
                            RecentArtworkCard(artworkId: artworkId)
                        }
                        
                        AddNewArtworkCard {
                            // Navigate to drawing
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
    }
    
    // MARK: - Learning Path Section
    
    private var learningPathSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Your Learning Path", systemImage: "map.fill")
                    .font(.headline.weight(.semibold))
                
                Spacer()
                
                Button("See All") {
                    // Navigate to lessons
                }
                .font(.subheadline.weight(.medium))
                .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                ForEach(viewModel.recommendedLessons.prefix(3), id: \.id) { lesson in
                    ArtisticLessonCard(lesson: lesson) {
                        // Start lesson
                    }
                }
            }
        }
    }
    
    // MARK: - Weekly Insights
    
    private var weeklyInsights: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Weekly Insights", systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline.weight(.semibold))
            
            HStack(spacing: 16) {
                InsightCard(
                    title: "Total Practice",
                    value: "\(viewModel.weeklyStats.totalMinutes)",
                    unit: "minutes",
                    icon: "clock.fill",
                    color: .purple,
                    trend: "+12%"
                )
                
                InsightCard(
                    title: "XP Earned",
                    value: "\(viewModel.weeklyStats.totalXP)",
                    unit: "points",
                    icon: "star.fill",
                    color: .orange,
                    trend: "+25%"
                )
            }
            
            // Mini chart
            WeeklyArtChart(stats: viewModel.weeklyStats)
                .frame(height: 100)
                .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Helper Properties
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
    
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
        .overlay(
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
    }
    
    private var notificationButton: some View {
           Button {
               // Show notifications
           } label: {
               Image(systemName: "bell")
                   .font(.title3)
                   .foregroundColor(.primary)
           }
       }
        
    
    private var loadingView: some View {
        VStack(spacing: 24) {
            ForEach(0..<3) { _ in
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 150)
                    .shimmer()
            }
        }
        .padding(.top, 40)
    }
}

// MARK: - Supporting Components

struct PaintSplash: View {
    let colors = [Color.purple, Color.pink, Color.orange, Color.blue, Color.cyan]
    @State private var randomColor: Color
    @State private var scale: CGFloat
    
    init() {
        _randomColor = State(initialValue: colors.randomElement()!)
        _scale = State(initialValue: CGFloat.random(in: 0.5...2.0))
    }
    
    var body: some View {
        Circle()
            .fill(randomColor)
            .frame(width: 150 * scale, height: 150 * scale)
            .blur(radius: 30)
    }
}

struct QuickStartButton: View {
    let title: String
    let icon: String
    let gradient: [Color]
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .shadow(color: gradient[0].opacity(0.3), radius: 8, y: 4)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        } perform: {}
    }
}

struct CreativePromptCard: View {
    let prompt: String
    let difficulty: String
    let timeEstimate: String
    let xpReward: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Text(prompt)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "gauge")
                            .font(.caption)
                        Text(difficulty)
                            .font(.caption)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.orange.opacity(0.2)))
                    .foregroundColor(.orange)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text(timeEstimate)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("+\(xpReward) XP")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.purple)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.purple.opacity(0.1),
                                Color.pink.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [.purple.opacity(0.3), .pink.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ArtisticProgressRing: View {
    let progress: Double
    let gradient: [Color]
    let size: CGFloat
    let lineWidth: CGFloat
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
                .frame(width: size, height: size)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
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
            
            // Decorative dots
            ForEach(0..<8) { index in
                Circle()
                    .fill(gradient[0].opacity(0.3))
                    .frame(width: 4, height: 4)
                    .offset(y: -size/2 + lineWidth/2)
                    .rotationEffect(.degrees(Double(index) * 45))
            }
        }
    }
}

struct RecentArtworkCard: View {
    let artworkId: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    colors: [
                        Color.purple.opacity(0.2),
                        Color.pink.opacity(0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 120, height: 120)
            .overlay(
                VStack {
                    Image(systemName: "photo.artframe")
                        .font(.largeTitle)
                        .foregroundColor(.purple.opacity(0.5))
                    
                    Text("Artwork")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
            )
    }
}

struct AddNewArtworkCard: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 120, height: 120)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("New")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .foregroundColor(.purple.opacity(0.3))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyArtworkCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "paintpalette")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Start Creating!")
                .font(.headline)
            
            Text("Your artwork gallery is waiting for your first masterpiece")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.purple.opacity(0.05))
        )
    }
}

struct ArtisticLessonCard: View {
    let lesson: Lesson
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon with gradient background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [lesson.color, lesson.color.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: lesson.icon)
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        Label("\(lesson.estimatedMinutes)m", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(lesson.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // XP and arrow
                VStack(alignment: .trailing, spacing: 4) {
                    Text("+\(lesson.xpReward)")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(lesson.color)
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                        .foregroundColor(lesson.color.opacity(0.3))
                        .scaleEffect(isHovered ? 1.1 : 1.0)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .shadow(color: lesson.color.opacity(0.1), radius: 8, y: 4)
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.3)) {
                isHovered = hovering
            }
        }
    }
}

struct InsightCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    let trend: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
                
                Text(trend)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.green)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title.bold())
                    .foregroundColor(.primary)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(title)
                .font(.caption2.weight(.medium))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.tertiarySystemBackground))
        )
    }
}

struct WeeklyArtChart: View {
    let stats: WeeklyStats
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(stats.days, id: \.date) { day in
                VStack(spacing: 4) {
                    // Bar
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            day.minutes > 0 ?
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .top,
                                endPoint: .bottom
                            ) :
                            LinearGradient(
                                colors: [Color.gray.opacity(0.2)],
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
        return max(normalizedHeight * 80, 4)
    }
    
    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
}

// Shimmer extension
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

#Preview {
    HomeDashboardView()
        .environmentObject(FirebaseAuthService())
}
