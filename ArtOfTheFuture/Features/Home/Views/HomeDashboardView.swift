// MARK: - Enhanced Art Learning Home Dashboard (FAANG-Level Quality)
// File: ArtOfTheFuture/Features/Home/Views/HomeDashboardView.swift

import SwiftUI
import PencilKit

struct HomeDashboardView: View {
    @StateObject private var viewModel = HomeDashboardViewModel()
    @StateObject private var userDataService = UserDataService.shared
    @EnvironmentObject var authService: FirebaseAuthService
    @State private var selectedTab = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var heroOpacity: Double = 1.0
    @State private var showingMoreOptions = false
    @State private var navigateToGallery = false
    @State private var navigateToDraw = false
    @State private var navigateToNextLesson = false
    @State private var nextLesson: Lesson?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Enhanced artistic background
                EnhancedArtisticBackground(scrollOffset: scrollOffset)
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        if viewModel.isLoading {
                            enhancedLoadingView
                        } else {
                            // Hero section with parallax
                            enhancedHeroSection
                                .opacity(heroOpacity)
                            
                            // Main content with enhanced spacing
                            VStack(spacing: 32) {
                                todaysCreativePromptEnhanced
                                enhancedProgressDashboard
                                quickActionsSection
                                recentArtworksEnhanced
                                learningPathEnhanced
                                weeklyInsightsEnhanced
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                        }
                    }
                    .background(
                        // Scroll offset reader
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .named("scroll")).minY)
                        }
                    )
                    .padding(.bottom, 120)
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    scrollOffset = value
                    // Parallax effect for hero section
                    let threshold: CGFloat = 100
                    heroOpacity = max(0.3, 1.0 - abs(value) / threshold)
                }
                
                // Hidden NavigationLinks
                NavigationLink(destination: GalleryView(), isActive: $navigateToGallery) {
                    EmptyView()
                }
                .hidden()
                
                NavigationLink(destination: DrawingView(), isActive: $navigateToDraw) {
                    EmptyView()
                }
                .hidden()
                
                if let nextLesson = nextLesson {
                    NavigationLink(destination: LessonPlayerView(lesson: nextLesson), isActive: $navigateToNextLesson) {
                        EmptyView()
                    }
                    .hidden()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    enhancedUserGreeting
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    enhancedToolbarActions
                }
            }
            .refreshable {
                await viewModel.refreshDashboard()
            }
        }
        .onAppear {
            Task {
                await viewModel.loadDashboard()
                await loadNextLessonInfo()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Enhanced Artistic Background
    
    struct EnhancedArtisticBackground: View {
        let scrollOffset: CGFloat
        
        var body: some View {
            ZStack {
                // Dark gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.12),
                        Color(red: 0.08, green: 0.05, blue: 0.15),
                        Color(red: 0.12, green: 0.08, blue: 0.20),
                        Color(red: 0.06, green: 0.08, blue: 0.16)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Animated paint elements with parallax
                GeometryReader { geometry in
                    ForEach(0..<6, id: \.self) { index in
                        EnhancedPaintSplash(index: index)
                            .position(
                                x: CGFloat(index % 2 == 0 ? 0.2 : 0.8) * geometry.size.width + sin(scrollOffset * 0.01) * 20,
                                y: CGFloat(index) * geometry.size.height / 6 + cos(scrollOffset * 0.005) * 10
                            )
                            .opacity(0.08)
                    }
                }
                
                // Subtle dark texture overlay
                Rectangle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.black.opacity(0.15),
                                Color.purple.opacity(0.05)
                            ]),
                            center: .center,
                            startRadius: 100,
                            endRadius: 500
                        )
                    )
            }
            .ignoresSafeArea()
        }
    }
    
    struct EnhancedPaintSplash: View {
        let index: Int
        let colors = [Color.purple, Color.pink, Color.orange, Color.blue, Color.cyan, Color.mint]
        @State private var scale: CGFloat
        @State private var rotation: Double
        
        init(index: Int) {
            self.index = index
            _scale = State(initialValue: CGFloat.random(in: 0.8...2.5))
            _rotation = State(initialValue: Double.random(in: 0...360))
        }
        
        var body: some View {
            Circle()
                .fill(colors[index % colors.count])
                .frame(width: 200 * scale, height: 200 * scale)
                .blur(radius: 40)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(.easeInOut(duration: Double.random(in: 20...40)).repeatForever(autoreverses: true)) {
                        rotation += 360
                    }
                }
        }
    }
    
    // MARK: - Enhanced Hero Section
    
    private var enhancedHeroSection: some View {
        VStack(spacing: 24) {
            // Enhanced motivational text
            VStack(spacing: 12) {
                Text("Pikaso")
                    .font(.system(size: 42, weight: .heavy, design: .serif))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .purple, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                
                Text("Where Artists Are Born")
                    .font(.system(size: 22, weight: .medium, design: .default))
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(0.9)
            }
            
            // Enhanced streak and level indicator
            HStack(spacing: 20) {
                enhancedStreakCard
                enhancedLevelCard
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var enhancedStreakCard: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: viewModel.currentStreak > 0 ? "flame.fill" : "flame")
                    .font(.title3)
                    .foregroundColor(viewModel.currentStreak > 0 ? .orange : .secondary)
                
                Text("\(viewModel.currentStreak)")
                    .font(.title2.bold())
                    .foregroundColor(viewModel.currentStreak > 0 ? .orange : .secondary)
            }
            
            Text("Day Streak")
                .font(.caption.weight(.medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: viewModel.currentStreak > 0 ? [.orange.opacity(0.5), .yellow.opacity(0.3)] : [Color.gray.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .scaleEffect(viewModel.currentStreak > 0 ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: viewModel.currentStreak)
    }
    
    private var enhancedLevelCard: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.title3)
                    .foregroundColor(.yellow)
                
                Text("Level \(viewModel.currentLevel)")
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
            
            Text("\(Int(viewModel.levelProgress * 100))% to next")
                .font(.caption.weight(.medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [.yellow.opacity(0.5), .orange.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
    
    // MARK: - Enhanced Today's Creative Prompt
    
    private var todaysCreativePromptEnhanced: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Today's Creative Challenge", systemImage: "lightbulb.fill")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("3 min")
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.3))
                    .foregroundColor(.cyan)
                    .cornerRadius(8)
            }
            
            Text("Draw a simple object using only geometric shapes")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: 12) {
                Button("Start Challenge") {
                    // Navigate to today's challenge
                }
                .buttonStyle(PremiumButtonStyle(
                    colors: [.blue, .purple],
                    isCompact: true
                ))
                
                Button("Skip for Today") {
                    // Skip today's challenge
                }
                .buttonStyle(SecondaryButtonStyle(isCompact: true))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.ultraThinMaterial, lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
    
    // MARK: - Enhanced Progress Dashboard
    
    private var enhancedProgressDashboard: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Your Progress")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                // Today's Minutes
                enhancedProgressCard(
                    title: "Today",
                    value: "\(viewModel.todayMinutes)",
                    subtitle: "minutes",
                    progress: Double(viewModel.todayMinutes) / Double(viewModel.targetMinutes),
                    colors: [.purple, .pink],
                    icon: "clock.fill"
                )
                
                // Weekly Lessons
                enhancedProgressCard(
                    title: "This Week",
                    value: "\(viewModel.lessonsCompleted)",
                    subtitle: "lessons",
                    progress: Double(viewModel.lessonsCompleted) / 7.0,
                    colors: [.blue, .cyan],
                    icon: "book.fill"
                )
                
                // XP Earned
                enhancedProgressCard(
                    title: "XP Today",
                    value: "\(viewModel.todayXP)",
                    subtitle: "points",
                    progress: Double(viewModel.todayXP) / 200.0, // Assuming 200 is daily target
                    colors: [.orange, .yellow],
                    icon: "star.fill"
                )
            }
        }
    }
    
    private func enhancedProgressCard(
        title: String,
        value: String,
        subtitle: String,
        progress: Double,
        colors: [Color],
        icon: String
    ) -> some View {
        VStack(spacing: 12) {
            // Icon and title
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(colors[0])
                
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 6)
                    .frame(width: 70, height: 70)
                
                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(
                        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.8, dampingFraction: 0.8), value: progress)
                
                VStack(spacing: 0) {
                    Text(value)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.ultraThinMaterial, lineWidth: 1)
                )
        )
        .shadow(color: colors[0].opacity(0.1), radius: 8, y: 4)
    }
    
    // MARK: - Enhanced Quick Actions
    
    private var quickActionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Quick Start")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                QuickActionCardEnhanced(
                    title: "Free Draw",
                    subtitle: "Express yourself",
                    icon: "paintbrush.fill",
                    colors: [.purple, .pink],
                    action: {
                        navigateToDraw = true
                    }
                )
                
                QuickActionCardEnhanced(
                    title: "Next Lesson",
                    subtitle: nextLesson?.title ?? "Continue learning",
                    icon: "play.circle.fill",
                    colors: [.blue, .cyan],
                    action: {
                        Task {
                            await findAndNavigateToNextLesson()
                        }
                    }
                )
                
                QuickActionCardEnhanced(
                    title: "Gallery",
                    subtitle: "View your art",
                    icon: "photo.stack.fill",
                    colors: [.orange, .yellow],
                    action: {
                        navigateToGallery = true
                    }
                )
                
                QuickActionCardEnhanced(
                    title: "Community",
                    subtitle: "Share & discover",
                    icon: "person.2.fill",
                    colors: [.green, .mint],
                    action: { /* Navigate to community */ }
                )
            }
        }
    }
    
    // MARK: - Enhanced Recent Artworks
    
    private var recentArtworksEnhanced: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recent Artworks")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to full gallery
                }
                .font(.subheadline.weight(.medium))
                .foregroundColor(.cyan)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(0..<5, id: \.self) { index in
                        RecentArtworkCardEnhanced(index: index)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)
        }
    }
    
    struct RecentArtworkCardEnhanced: View {
        let index: Int
        
        var body: some View {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: Double.random(in: 0.8...1.0), green: Double.random(in: 0.8...1.0), blue: Double.random(in: 0.8...1.0)),
                            Color(red: Double.random(in: 0.7...0.9), green: Double.random(in: 0.7...0.9), blue: Double.random(in: 0.7...0.9))
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                .overlay(
                    VStack {
                        Image(systemName: ["paintbrush", "pencil", "scribble", "circle.dashed", "triangle"].randomElement()!)
                            .font(.title)
                            .foregroundColor(.white.opacity(0.8))
                            .shadow(radius: 2)
                    }
                )
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        }
    }
    
    // MARK: - Enhanced Learning Path
    
    private var learningPathEnhanced: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Continue Your Journey")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { index in
                    LearningPathCardEnhanced(
                        title: ["Color Theory Basics", "Drawing Fundamentals", "Digital Art Techniques"][index],
                        progress: [0.7, 0.3, 0.9][index],
                        lessonsCompleted: [7, 3, 12][index],
                        totalLessons: [10, 10, 14][index],
                        difficulty: ["Beginner", "Intermediate", "Advanced"][index],
                        estimatedTime: ["15 min", "20 min", "25 min"][index],
                        colors: [
                            [.purple, .pink],
                            [.blue, .cyan],
                            [.orange, .yellow]
                        ][index]
                    )
                }
            }
        }
    }
    
    struct LearningPathCardEnhanced: View {
        let title: String
        let progress: Double
        let lessonsCompleted: Int
        let totalLessons: Int
        let difficulty: String
        let estimatedTime: String
        let colors: [Color]
        
        var body: some View {
            HStack(spacing: 16) {
                // Progress indicator
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(progress * 100))%")
                        .font(.caption.bold())
                        .foregroundColor(.primary)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                    
                    Text("\(lessonsCompleted)/\(totalLessons) lessons • \(difficulty)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    HStack {
                        Label(estimatedTime, systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Spacer()
                        
                        Text("Continue")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(colors[0])
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(colors: colors.map { $0.opacity(0.3) }, startPoint: .leading, endPoint: .trailing),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: colors[0].opacity(0.1), radius: 6, y: 3)
        }
    }
    
    // MARK: - Enhanced Weekly Insights
    
    private var weeklyInsightsEnhanced: some View {
        VStack(spacing: 16) {
            HStack {
                Text("This Week's Insights")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                InsightCardEnhanced(
                    title: "Minutes Practiced",
                    value: "\(viewModel.weeklyStats.totalMinutes)",
                    subtitle: "This week",
                    icon: "clock.fill",
                    colors: [.blue, .purple],
                    trend: .up,
                    trendValue: "23%"
                )
                
                InsightCardEnhanced(
                    title: "XP Earned",
                    value: "\(viewModel.weeklyStats.totalXP)",
                    subtitle: "Total points",
                    icon: "star.fill",
                    colors: [.orange, .yellow],
                    trend: .up,
                    trendValue: "15%"
                )
                
                InsightCardEnhanced(
                    title: "Daily Average",
                    value: "\(viewModel.weeklyStats.averageMinutesPerDay)",
                    subtitle: "Minutes/day",
                    icon: "chart.line.uptrend.xyaxis",
                    colors: [.green, .mint],
                    trend: .stable,
                    trendValue: "0%"
                )
                
                InsightCardEnhanced(
                    title: "Best Day",
                    value: "Tuesday",
                    subtitle: "Most active",
                    icon: "calendar",
                    colors: [.purple, .pink],
                    trend: nil,
                    trendValue: nil
                )
            }
        }
    }
    
    struct InsightCardEnhanced: View {
        let title: String
        let value: String
        let subtitle: String
        let icon: String
        let colors: [Color]
        let trend: TrendDirection?
        let trendValue: String?
        
        enum TrendDirection {
            case up, down, stable
            
            var icon: String {
                switch self {
                case .up: return "arrow.up.right"
                case .down: return "arrow.down.right"
                case .stable: return "minus"
                }
            }
            
            var color: Color {
                switch self {
                case .up: return .green
                case .down: return .red
                case .stable: return .gray
                }
            }
        }
        
        var body: some View {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(colors[0])
                    
                    Spacer()
                    
                    if let trend = trend, let trendValue = trendValue {
                        HStack(spacing: 2) {
                            Image(systemName: trend.icon)
                                .font(.caption2)
                            Text(trendValue)
                                .font(.caption2.weight(.medium))
                        }
                        .foregroundColor(trend.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(trend.color.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(.title.bold())
                        .foregroundColor(.white)
                    
                    Text(title)
                        .font(.headline.weight(.medium))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.ultraThinMaterial, lineWidth: 1)
                    )
            )
            .shadow(color: colors[0].opacity(0.1), radius: 6, y: 3)
        }
    }
    
    // MARK: - Enhanced Toolbar Components
    
    private var enhancedUserGreeting: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(greetingText)
                .font(.caption.weight(.medium))
                .foregroundColor(.white.opacity(0.7))
            
            Text(viewModel.userName.isEmpty ? "Artist" : viewModel.userName)
                .font(.headline.bold())
                .foregroundColor(.white)
        }
    }
    
    private var enhancedToolbarActions: some View {
        HStack(spacing: 12) {
            Button {
                showingMoreOptions.toggle()
            } label: {
                Image(systemName: "bell.badge")
                    .font(.title3)
                    .foregroundColor(.white)
                    .overlay(
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .offset(x: 8, y: -8),
                        alignment: .topTrailing
                    )
            }
            
            profileButtonEnhanced
        }
    }
    
    private var profileButtonEnhanced: some View {
        NavigationLink(destination: ProfileView()) {
            AsyncImage(url: URL(string: viewModel.userName.isEmpty ? "" : "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                LinearGradient(
                    colors: [.purple, .pink],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                )
            }
            .frame(width: 36, height: 36)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(.ultraThinMaterial, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            .scaleEffect(1.0)
            .animation(.spring(response: 0.3), value: false)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Enhanced Loading View
    
    private var enhancedLoadingView: some View {
        VStack(spacing: 32) {
            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .frame(height: [80, 120, 160, 100][index])
                    .shimmerEffect()
                    .animation(.easeInOut(duration: 1.5).delay(Double(index) * 0.1).repeatForever(autoreverses: true), value: UUID())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 40)
    }
    
    // MARK: - Helper Properties
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }
    
    // MARK: - Navigation Methods
    
    private func findAndNavigateToNextLesson() async {
        do {
            // Get all lessons from the lesson service
            let allLessons = try await LessonService.shared.getAllLessons()
            let progressService = ProgressService.shared
            let completedLessons = try await progressService.getCompletedLessons()
            
            // Find the first lesson that's not completed
            let nextIncompleteLesson = allLessons.first { lesson in
                !completedLessons.contains(lesson.id)
            }
            
            await MainActor.run {
                if let lesson = nextIncompleteLesson {
                    nextLesson = lesson
                    navigateToNextLesson = true
                } else {
                    // All lessons completed - could navigate to a completion screen or show a message
                    print("🎉 All lessons completed!")
                }
            }
        } catch {
            print("❌ Failed to find next lesson: \(error)")
        }
    }
    
    private func loadNextLessonInfo() async {
        do {
            let allLessons = try await LessonService.shared.getAllLessons()
            let progressService = ProgressService.shared
            let completedLessons = try await progressService.getCompletedLessons()
            
            let nextIncompleteLesson = allLessons.first { lesson in
                !completedLessons.contains(lesson.id)
            }
            
            await MainActor.run {
                nextLesson = nextIncompleteLesson
            }
        } catch {
            print("❌ Failed to load next lesson info: \(error)")
        }
    }
}

// MARK: - Enhanced Supporting Components

struct QuickActionCardEnhanced: View {
    let title: String
    let subtitle: String
    let icon: String
    let colors: [Color]
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(Circle())
                    .shadow(color: colors[0].opacity(0.3), radius: 8, y: 4)
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.ultraThinMaterial, lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        } perform: {}
    }
}

// MARK: - Enhanced Button Styles

struct PremiumButtonStyle: ButtonStyle {
    let colors: [Color]
    let isCompact: Bool
    
    init(colors: [Color], isCompact: Bool = false) {
        self.colors = colors
        self.isCompact = isCompact
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, isCompact ? 16 : 24)
            .padding(.vertical, isCompact ? 10 : 14)
            .background(
                LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(isCompact ? 12 : 16)
            .shadow(color: colors[0].opacity(0.3), radius: 8, y: 4)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    let isCompact: Bool
    
    init(isCompact: Bool = false) {
        self.isCompact = isCompact
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: isCompact ? 14 : 16, weight: .medium))
            .foregroundColor(.secondary)
            .padding(.horizontal, isCompact ? 16 : 24)
            .padding(.vertical, isCompact ? 10 : 14)
            .background(.ultraThinMaterial)
            .cornerRadius(isCompact ? 12 : 16)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

// MARK: - Utility Views

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    func shimmerEffect() -> some View {
        self.overlay(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .rotationEffect(.degrees(30))
                .offset(x: -200)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: UUID())
        )
        .clipped()
    }
}
