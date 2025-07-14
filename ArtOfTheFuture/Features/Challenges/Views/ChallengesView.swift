// MARK: - Fixed Daily Challenges System (ALL BUILD ERRORS RESOLVED)
// **REPLACE:** ArtOfTheFuture/Features/Challenges/Views/ChallengesView.swift

import SwiftUI
import PencilKit

struct ChallengesView: View {
    @StateObject private var viewModel = ChallengesViewModel()
    @State private var selectedChallenge: DailyChallenge?
    @State private var showCompletedChallenges = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    ColorPalette.primaryOrange.opacity(0.05),
                    ColorPalette.primaryYellow.opacity(0.03),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Dimensions.paddingLarge) {
                    // Header with streak and rewards
                    challengeHeader
                    
                    // Today's Featured Challenge
                    if let todayChallenge = viewModel.todayChallenge {
                        featuredChallengeCard(todayChallenge)
                    }
                    
                    // Challenge Categories
                    challengeCategories
                    
                    // Active Challenges
                    activeChallengesSection
                    
                    // Weekly Challenges
                    weeklyChallengesSection
                    
                    // Challenge History
                    challengeHistorySection
                }
                .padding(.horizontal)
                .padding(.vertical)
            }
        }
        .navigationTitle("Daily Challenges")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showCompletedChallenges.toggle() }) {
                    Image(systemName: "trophy.circle")
                        .symbolVariant(showCompletedChallenges ? .fill : .none)
                }
            }
        }
        .sheet(item: $selectedChallenge) { challenge in
            ChallengePlayerView(challenge: challenge, viewModel: viewModel)
        }
        .sheet(isPresented: $showCompletedChallenges) {
            CompletedChallengesView(viewModel: viewModel)
        }
        .task {
            await viewModel.loadChallenges()
        }
        .onReceive(NotificationCenter.default.publisher(for: .challengeCompleted)) { notification in
            if let challenge = notification.object as? DailyChallenge {
                Task {
                    await viewModel.handleChallengeCompletion(challenge)
                }
            }
        }
    }
    
    // MARK: - Challenge Header
    private var challengeHeader: some View {
        ModernCard {
            VStack(spacing: Dimensions.paddingMedium) {
                // Title and streak
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Daily Challenges")
                            .font(Typography.title2)
                            .fontWeight(.bold)
                        
                        Text("Push your limits every day!")
                            .font(Typography.subheadline)
                            .foregroundColor(ColorPalette.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Challenge streak
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(ColorPalette.warningGradient)
                                .frame(width: 60, height: 60)
                            
                            VStack(spacing: 2) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                
                                Text("\(viewModel.challengeStreak)")
                                    .font(Typography.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Text("Challenge\nStreak")
                            .font(Typography.caption)
                            .foregroundColor(ColorPalette.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Daily progress
                HStack(spacing: Dimensions.paddingLarge) {
                    LessonStatCard(
                        title: "Today",
                        value: "\(viewModel.todayChallengesCompleted)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )

                    LessonStatCard(
                        title: "This Week",
                        value: "\(viewModel.weekChallengesCompleted)",
                        icon: "calendar.circle.fill",
                        color: .blue
                    )

                    LessonStatCard(
                        title: "Total",
                        value: "\(viewModel.totalChallengesCompleted)",
                        icon: "trophy.fill",
                        color: .yellow
                    )
                }
            }
            .padding()
        }
    }
    
    // MARK: - Featured Challenge Card
    private func featuredChallengeCard(_ challenge: DailyChallenge) -> some View {
        ModernCard(backgroundColor: ColorPalette.primaryOrange.opacity(0.1)) {
            VStack(spacing: Dimensions.paddingMedium) {
                // Challenge badge
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.white)
                        Text("Today's Challenge")
                            .font(Typography.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(ColorPalette.warningGradient)
                    )
                    
                    Spacer()
                    
                    // Time remaining
                    if !challenge.isCompleted {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(viewModel.timeRemainingText)
                                .font(Typography.caption)
                                .foregroundColor(ColorPalette.textSecondary)
                            
                            Text("remaining")
                                .font(Typography.caption) // FIXED: was caption2
                                .foregroundColor(ColorPalette.textSecondary)
                        }
                    }
                }
                
                // Challenge content
                HStack(spacing: Dimensions.paddingMedium) {
                    // Challenge icon
                    ZStack {
                        Circle()
                            .fill(challenge.isCompleted ? ColorPalette.successGradient : challenge.category.gradient)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: challenge.isCompleted ? "checkmark.circle.fill" : challenge.iconName)
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    }
                    
                    // Challenge details
                    VStack(alignment: .leading, spacing: 8) {
                        Text(challenge.title)
                            .font(Typography.headline)
                            .fontWeight(.bold)
                        
                        Text(challenge.description)
                            .font(Typography.subheadline)
                            .foregroundColor(ColorPalette.textSecondary)
                            .lineLimit(2)
                        
                        // Difficulty and rewards
                        HStack(spacing: 16) {
                            HStack(spacing: 4) {
                                Image(systemName: "target")
                                    .font(.caption)
                                Text(challenge.difficulty.rawValue)
                                    .font(Typography.caption)
                            }
                            .foregroundColor(challenge.difficulty.color)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                                Text("\(challenge.xpReward) XP")
                                    .font(Typography.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    
                    Spacer()
                }
                
                // Action button
                ModernButton(
                    title: challenge.isCompleted ? "Completed! ✨" : "Start Challenge",
                    icon: challenge.isCompleted ? nil : "play.circle.fill",
                    style: challenge.isCompleted ? .secondary : .primary,
                    isEnabled: !challenge.isCompleted
                ) {
                    if !challenge.isCompleted {
                        selectedChallenge = challenge
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Challenge Categories
    private var challengeCategories: some View {
        VStack(alignment: .leading, spacing: Dimensions.paddingMedium) {
            ModernSectionHeader("Categories", subtitle: "Choose your focus")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ChallengeCategory.allCases, id: \.self) { category in
                        ChallengeCategoryCard(
                            category: category,
                            challengesCompleted: viewModel.getCategoryProgress(category),
                            action: {
                                Task {
                                    await viewModel.filterByCategory(category)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Active Challenges Section
    private var activeChallengesSection: some View {
        VStack(alignment: .leading, spacing: Dimensions.paddingMedium) {
            ModernSectionHeader(
                "Active Challenges",
                subtitle: "\(viewModel.activeChallenges.count) available",
                actionTitle: "View All"
            ) {
                // Navigate to all challenges
            }
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.activeChallenges.prefix(3)) { challenge in
                    ChallengeListCard(challenge: challenge) {
                        selectedChallenge = challenge
                    }
                }
            }
        }
    }
    
    // MARK: - Weekly Challenges Section
    private var weeklyChallengesSection: some View {
        VStack(alignment: .leading, spacing: Dimensions.paddingMedium) {
            ModernSectionHeader(
                "Weekly Challenge",
                subtitle: "Special limited-time challenge"
            )
            
            if let weeklyChallenge = viewModel.weeklyChallenge {
                WeeklyChallengeCard(challenge: weeklyChallenge) {
                    selectedChallenge = weeklyChallenge
                }
            } else {
                ModernEmptyState(
                    icon: "calendar.badge.clock",
                    title: "New Weekly Challenge",
                    message: "Check back Monday for a new weekly challenge!"
                )
            }
        }
    }
    
    // MARK: - Challenge History Section
    private var challengeHistorySection: some View {
        VStack(alignment: .leading, spacing: Dimensions.paddingMedium) {
            ModernSectionHeader(
                "Recent Completions",
                actionTitle: "View All"
            ) {
                showCompletedChallenges = true
            }
            
            if viewModel.recentCompletions.isEmpty {
                ModernEmptyState(
                    icon: "clock.badge.checkmark",
                    title: "No completions yet",
                    message: "Complete your first challenge to see your progress here!"
                )
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.recentCompletions.prefix(3)) { completion in
                        ChallengeCompletionRow(completion: completion)
                    }
                }
            }
        }
    }
}

// MARK: - Challenge Category Card
struct ChallengeCategoryCard: View {
    let category: ChallengeCategory
    let challengesCompleted: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            Task {
                await HapticManager.shared.impact(.medium)
            }
            action()
        }) {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(category.gradient)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: category.iconName)
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }
                
                // Category info
                VStack(spacing: 4) {
                    Text(category.rawValue)
                        .font(Typography.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(ColorPalette.textPrimary)
                    
                    Text("\(challengesCompleted) completed")
                        .font(Typography.caption)
                        .foregroundColor(ColorPalette.textSecondary)
                }
            }
            .frame(width: 120)
        }
        .buttonStyle(PressedButtonStyle())
    }
}

// MARK: - Challenge List Card
struct ChallengeListCard: View {
    let challenge: DailyChallenge
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            Task {
                await HapticManager.shared.impact(.light)
            }
            action()
        }) {
            ModernCard {
                HStack(spacing: Dimensions.paddingMedium) {
                    // Challenge icon
                    ZStack {
                        Circle()
                            .fill(challenge.isCompleted ? ColorPalette.successGradient : LinearGradient(colors: [challenge.category.primaryColor.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)) // FIXED: type mismatch
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: challenge.isCompleted ? "checkmark.circle.fill" : challenge.iconName)
                            .font(.title3)
                            .foregroundColor(challenge.isCompleted ? .white : challenge.category.primaryColor)
                    }
                    
                    // Challenge details
                    VStack(alignment: .leading, spacing: 4) {
                        Text(challenge.title)
                            .font(Typography.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(ColorPalette.textPrimary)
                        
                        Text("\(challenge.estimatedMinutes) min • \(challenge.xpReward) XP")
                            .font(Typography.caption)
                            .foregroundColor(ColorPalette.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Status indicator
                    if challenge.isCompleted {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(ColorPalette.textTertiary)
                    }
                }
                .padding()
            }
        }
        .buttonStyle(.plain)
        .opacity(challenge.isCompleted ? 0.7 : 1.0)
    }
}

// MARK: - Weekly Challenge Card
struct WeeklyChallengeCard: View {
    let challenge: DailyChallenge
    let action: () -> Void
    
    var body: some View {
        ModernCard(backgroundColor: ColorPalette.primaryPurple.opacity(0.1)) {
            VStack(spacing: Dimensions.paddingMedium) {
                // Weekly badge
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.white)
                        Text("Weekly Challenge")
                            .font(Typography.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(ColorPalette.primaryGradient)
                    )
                    
                    Spacer()
                }
                
                HStack(spacing: Dimensions.paddingMedium) {
                    // Challenge visual
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(ColorPalette.premiumGradient)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: challenge.iconName)
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(challenge.title)
                            .font(Typography.headline)
                            .fontWeight(.bold)
                        
                        Text(challenge.description)
                            .font(Typography.subheadline)
                            .foregroundColor(ColorPalette.textSecondary)
                            .lineLimit(2)
                        
                        HStack(spacing: 16) {
                            Label("\(challenge.estimatedMinutes) min", systemImage: "clock")
                                .font(Typography.caption)
                                .foregroundColor(ColorPalette.textSecondary)
                            
                            Label("\(challenge.xpReward) XP", systemImage: "star.fill")
                                .font(Typography.caption)
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Spacer()
                }
                
                ModernButton(
                    title: challenge.isCompleted ? "Completed! 🏆" : "Accept Challenge",
                    style: challenge.isCompleted ? .secondary : .primary,
                    isEnabled: !challenge.isCompleted,
                    action: action
                )
            }
            .padding()
        }
    }
}

// MARK: - Challenge Completion Row
struct ChallengeCompletionRow: View {
    let completion: ChallengeCompletion
    
    var body: some View {
        HStack(spacing: 12) {
            // Challenge icon
            Circle()
                .fill(completion.challenge.category.gradient)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: completion.challenge.iconName)
                        .font(.title3)
                        .foregroundColor(.white)
                )
            
            // Completion details
            VStack(alignment: .leading, spacing: 2) {
                Text(completion.challenge.title)
                    .font(Typography.subheadline)
                    .fontWeight(.medium)
                
                Text("Completed \(completion.completedAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(Typography.caption)
                    .foregroundColor(ColorPalette.textSecondary)
            }
            
            Spacer()
            
            // XP earned
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
                Text("+\(completion.xpEarned)")
                    .font(Typography.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Data Models (FIXED: All Codable conformances)

enum ChallengeCategory: String, CaseIterable, Codable { // FIXED: Added Codable
    case drawing = "Drawing"
    case color = "Color"
    case composition = "Composition"
    case technique = "Technique"
    case speed = "Speed"
    case creativity = "Creativity"
    
    var iconName: String {
        switch self {
        case .drawing: return "pencil.tip"
        case .color: return "paintpalette.fill"
        case .composition: return "viewfinder"
        case .technique: return "hand.draw.fill"
        case .speed: return "stopwatch.fill"
        case .creativity: return "sparkles"
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .drawing: return ColorPalette.primaryGradient
        case .color: return ColorPalette.warningGradient
        case .composition: return ColorPalette.successGradient
        case .technique: return LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)
        case .speed: return LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
        case .creativity: return ColorPalette.premiumGradient
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .drawing: return .blue
        case .color: return .orange
        case .composition: return .green
        case .technique: return .purple
        case .speed: return .red
        case .creativity: return .pink
        }
    }
}

enum ChallengeDifficulty: String, CaseIterable, Codable { // FIXED: Added Codable
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case expert = "Expert"
    
    var color: Color {
        switch self {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        case .expert: return .purple
        }
    }
    
    var xpMultiplier: Double {
        switch self {
        case .easy: return 1.0
        case .medium: return 1.5
        case .hard: return 2.0
        case .expert: return 3.0
        }
    }
}

struct DailyChallenge: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let category: ChallengeCategory
    let difficulty: ChallengeDifficulty
    let iconName: String
    let estimatedMinutes: Int
    let baseXPReward: Int
    let requirements: [ChallengeRequirement]
    let isWeekly: Bool
    let availableDate: Date
    let expiryDate: Date
    var isCompleted: Bool = false
    var completedAt: Date?
    
    var xpReward: Int {
        return Int(Double(baseXPReward) * difficulty.xpMultiplier)
    }
    
    var isExpired: Bool {
        return Date() > expiryDate
    }
    
    var isAvailable: Bool {
        return Date() >= availableDate && !isExpired
    }
}

enum ChallengeRequirement: Codable {
    case drawForMinutes(Int)
    case useSpecificTool(String)
    case createWithColorPalette([String])
    case drawSpecificShape(String)
    case achieveStrokeCount(Int)
    case completeInTime(TimeInterval)
    case useOnlyColors(Int) // max number of colors
    case drawFromReference(String)
    case recreateStyle(String)
    case improviseTheme(String)
}

struct ChallengeCompletion: Identifiable, Codable {
    let id: String
    let challenge: DailyChallenge
    let completedAt: Date
    let timeTaken: TimeInterval
    let xpEarned: Int
    let accuracy: Double
    let artworkId: String? // FIXED: Made optional to resolve missing parameter
}

// MARK: - Challenges ViewModel
@MainActor
final class ChallengesViewModel: ObservableObject {
    @Published var todayChallenge: DailyChallenge?
    @Published var weeklyChallenge: DailyChallenge?
    @Published var activeChallenges: [DailyChallenge] = []
    @Published var completedChallenges: [DailyChallenge] = []
    @Published var recentCompletions: [ChallengeCompletion] = []
    
    @Published var challengeStreak: Int = 0
    @Published var todayChallengesCompleted: Int = 0
    @Published var weekChallengesCompleted: Int = 0
    @Published var totalChallengesCompleted: Int = 0
    
    @Published var timeRemainingText: String = ""
    
    private let progressService: LessonsProgressService
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private var challengeGenerator = ChallengeGenerator()
    private var timer: Timer?
    
    init() {
        self.progressService = LessonsProgressService.shared
        
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        
        startTimeUpdateTimer()
    }
    
    func loadChallenges() async {
        // Generate today's challenge if needed
        generateTodaysChallenge()
        
        // Generate weekly challenge if needed
        generateWeeklyChallengeIfNeeded()
        
        // Load active challenges
        generateActiveChallenges()
        
        // Load completion history
        loadCompletionHistory()
        
        // Update stats
        updateChallengeStats()
    }
    
    private func generateTodaysChallenge() {
        let today = Calendar.current.startOfDay(for: Date())
        let key = "dailyChallenge_\(today.timeIntervalSince1970)"
        
        if let data = userDefaults.data(forKey: key),
           let challenge = try? decoder.decode(DailyChallenge.self, from: data) {
            todayChallenge = challenge
        } else {
            // Generate new daily challenge
            let newChallenge = challengeGenerator.generateDailyChallenge(for: today)
            todayChallenge = newChallenge
            
            // Save to UserDefaults
            if let data = try? encoder.encode(newChallenge) {
                userDefaults.set(data, forKey: key)
            }
        }
    }
    
    private func generateWeeklyChallengeIfNeeded() {
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: Date())
        let year = calendar.component(.year, from: Date())
        let key = "weeklyChallenge_\(year)_\(weekOfYear)"
        
        if let data = userDefaults.data(forKey: key),
           let challenge = try? decoder.decode(DailyChallenge.self, from: data) {
            weeklyChallenge = challenge
        } else {
            // Generate new weekly challenge
            let newChallenge = challengeGenerator.generateWeeklyChallenge(for: Date())
            weeklyChallenge = newChallenge
            
            // Save to UserDefaults
            if let data = try? encoder.encode(newChallenge) {
                userDefaults.set(data, forKey: key)
            }
        }
    }
    
    private func generateActiveChallenges() {
        // Generate additional challenges based on user skill level and preferences
        activeChallenges = challengeGenerator.generateActiveChallenges(count: 6)
    }
    
    private func loadCompletionHistory() {
        let key = "challengeCompletions"
        if let data = userDefaults.data(forKey: key),
           let completions = try? decoder.decode([ChallengeCompletion].self, from: data) {
            recentCompletions = completions.sorted { $0.completedAt > $1.completedAt }
        }
    }
    
    private func updateChallengeStats() {
        // Calculate challenge streak
        challengeStreak = calculateChallengeStreak()
        
        // Count today's completed challenges
        let today = Calendar.current.startOfDay(for: Date())
        todayChallengesCompleted = recentCompletions.filter { completion in
            Calendar.current.isDate(completion.completedAt, inSameDayAs: today)
        }.count
        
        // Count this week's completed challenges
        let weekStart = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        weekChallengesCompleted = recentCompletions.filter { completion in
            completion.completedAt >= weekStart
        }.count
        
        // Total completed challenges
        totalChallengesCompleted = recentCompletions.count
    }
    
    private func calculateChallengeStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        // Check if today has a completion
        let todayCompletions = recentCompletions.filter { completion in
            calendar.isDate(completion.completedAt, inSameDayAs: currentDate)
        }
        
        if todayCompletions.isEmpty {
            // Check yesterday
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        // Count consecutive days with completions
        while true {
            let dayCompletions = recentCompletions.filter { completion in
                calendar.isDate(completion.completedAt, inSameDayAs: currentDate)
            }
            
            if dayCompletions.isEmpty {
                break
            }
            
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        return streak
    }
    
    private func startTimeUpdateTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            self.updateTimeRemainingText()
        }
        updateTimeRemainingText()
    }
    
    private func updateTimeRemainingText() {
        guard let challenge = todayChallenge, !challenge.isCompleted else {
            timeRemainingText = ""
            return
        }
        
        let timeRemaining = challenge.expiryDate.timeIntervalSince(Date())
        
        if timeRemaining <= 0 {
            timeRemainingText = "Expired"
        } else {
            let hours = Int(timeRemaining) / 3600
            let minutes = (Int(timeRemaining) % 3600) / 60
            
            if hours > 0 {
                timeRemainingText = "\(hours)h \(minutes)m"
            } else {
                timeRemainingText = "\(minutes)m"
            }
        }
    }
    
    func handleChallengeCompletion(_ challenge: DailyChallenge) async {
        let completion = ChallengeCompletion(
            id: UUID().uuidString,
            challenge: challenge,
            completedAt: Date(),
            timeTaken: TimeInterval(challenge.estimatedMinutes * 60), // Mock time
            xpEarned: challenge.xpReward,
            accuracy: 0.85, // Mock accuracy
            artworkId: nil // FIXED: Added missing parameter
        )
        
        // Add to completions
        recentCompletions.insert(completion, at: 0)
        
        // Mark challenge as completed
        if todayChallenge?.id == challenge.id {
            todayChallenge?.isCompleted = true
            todayChallenge?.completedAt = Date()
        }
        
        if weeklyChallenge?.id == challenge.id {
            weeklyChallenge?.isCompleted = true
            weeklyChallenge?.completedAt = Date()
        }
        
        // Update active challenges
        if let index = activeChallenges.firstIndex(where: { $0.id == challenge.id }) {
            activeChallenges[index].isCompleted = true
            activeChallenges[index].completedAt = Date()
        }
        
        // Save completion history
        saveCompletionHistory()
        
        // Update progress service
        await progressService.recordPracticeSession(
            timeSpent: completion.timeTaken,
            activityType: .dailyChallenge
        )
        
        // Update stats
        updateChallengeStats()
        
        print("🏆 Challenge completed: \(challenge.title) (+\(challenge.xpReward) XP)")
    }
    
    private func saveCompletionHistory() {
        let key = "challengeCompletions"
        if let data = try? encoder.encode(recentCompletions) {
            userDefaults.set(data, forKey: key)
        }
    }
    
    func getCategoryProgress(_ category: ChallengeCategory) -> Int {
        return recentCompletions.filter { $0.challenge.category == category }.count
    }
    
    func filterByCategory(_ category: ChallengeCategory) async {
        activeChallenges = challengeGenerator.generateActiveChallenges(
            count: 6,
            category: category
        )
    }
    
    deinit {
        timer?.invalidate()
    }
}

// MARK: - Challenge Generator
struct ChallengeGenerator {
    private let baseXPReward = 50
    
    func generateDailyChallenge(for date: Date) -> DailyChallenge {
        let category = ChallengeCategory.allCases.randomElement()!
        let difficulty = ChallengeDifficulty.allCases.randomElement()!
        
        let challengeData = getChallengeData(for: category, difficulty: difficulty)
        
        let calendar = Calendar.current
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date))!
        
        return DailyChallenge(
            id: "daily_\(date.timeIntervalSince1970)",
            title: challengeData.title,
            description: challengeData.description,
            category: category,
            difficulty: difficulty,
            iconName: challengeData.icon,
            estimatedMinutes: challengeData.minutes,
            baseXPReward: baseXPReward,
            requirements: challengeData.requirements,
            isWeekly: false,
            availableDate: calendar.startOfDay(for: date),
            expiryDate: endOfDay
        )
    }
    
    func generateWeeklyChallenge(for date: Date) -> DailyChallenge {
        let category = ChallengeCategory.allCases.randomElement()!
        let difficulty = ChallengeDifficulty.hard // Weekly challenges are harder
        
        let challengeData = getWeeklyChallengeData(for: category)
        
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        let weekEnd = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart)!
        
        return DailyChallenge(
            id: "weekly_\(weekStart.timeIntervalSince1970)",
            title: challengeData.title,
            description: challengeData.description,
            category: category,
            difficulty: difficulty,
            iconName: challengeData.icon,
            estimatedMinutes: challengeData.minutes,
            baseXPReward: baseXPReward * 3, // Higher reward for weekly
            requirements: challengeData.requirements,
            isWeekly: true,
            availableDate: weekStart,
            expiryDate: weekEnd
        )
    }
    
    func generateActiveChallenges(count: Int, category: ChallengeCategory? = nil) -> [DailyChallenge] {
        var challenges: [DailyChallenge] = []
        
        for i in 0..<count {
            let challengeCategory = category ?? ChallengeCategory.allCases.randomElement()!
            let difficulty = ChallengeDifficulty.allCases.randomElement()!
            
            let challengeData = getChallengeData(for: challengeCategory, difficulty: difficulty)
            
            let challenge = DailyChallenge(
                id: "active_\(i)_\(Date().timeIntervalSince1970)",
                title: challengeData.title,
                description: challengeData.description,
                category: challengeCategory,
                difficulty: difficulty,
                iconName: challengeData.icon,
                estimatedMinutes: challengeData.minutes,
                baseXPReward: baseXPReward,
                requirements: challengeData.requirements,
                isWeekly: false,
                availableDate: Date(),
                expiryDate: Date().addingTimeInterval(24 * 60 * 60 * 7) // 1 week
            )
            
            challenges.append(challenge)
        }
        
        return challenges
    }
    
    private func getChallengeData(for category: ChallengeCategory, difficulty: ChallengeDifficulty) -> (title: String, description: String, icon: String, minutes: Int, requirements: [ChallengeRequirement]) {
        
        switch category {
        case .drawing:
            return drawingChallenges.randomElement()!
        case .color:
            return colorChallenges.randomElement()!
        case .composition:
            return compositionChallenges.randomElement()!
        case .technique:
            return techniqueChallenges.randomElement()!
        case .speed:
            return speedChallenges.randomElement()!
        case .creativity:
            return creativityChallenges.randomElement()!
        }
    }
    
    private func getWeeklyChallengeData(for category: ChallengeCategory) -> (title: String, description: String, icon: String, minutes: Int, requirements: [ChallengeRequirement]) {
        
        switch category {
        case .drawing:
            return ("Master Study Week", "Complete 5 detailed studies of master artworks", "paintbrush.pointed.fill", 60, [.drawForMinutes(60), .recreateStyle("Classical")])
        case .color:
            return ("Color Harmony Challenge", "Create artworks using only complementary colors", "paintpalette.fill", 45, [.useOnlyColors(2), .createWithColorPalette(["Red", "Green"])])
        case .composition:
            return ("Rule of Thirds Mastery", "Create 3 compositions perfectly using rule of thirds", "viewfinder", 40, [.drawForMinutes(40), .drawSpecificShape("Grid")])
        case .technique:
            return ("Cross-Hatching Marathon", "Master cross-hatching with 10 different subjects", "hand.draw.fill", 50, [.useSpecificTool("Pen"), .achieveStrokeCount(1000)])
        case .speed:
            return ("Lightning Sketches", "Complete 20 one-minute gesture drawings", "stopwatch.fill", 30, [.completeInTime(60), .drawForMinutes(30)])
        case .creativity:
            return ("Abstract Expression Week", "Create 5 abstract pieces expressing different emotions", "sparkles", 75, [.improviseTheme("Emotions"), .drawForMinutes(75)])
        }
    }
    
    // Challenge templates - FIXED: Using proper enum syntax
    private let drawingChallenges = [
        ("Line Confidence", "Draw 20 straight lines without lifting your pencil", "pencil.tip", 10, [ChallengeRequirement.achieveStrokeCount(20), ChallengeRequirement.useSpecificTool("Pen")]),
        ("Shape Studies", "Practice drawing perfect circles, squares, and triangles", "circle", 15, [ChallengeRequirement.drawSpecificShape("Circle"), ChallengeRequirement.drawForMinutes(15)]),
        ("Gesture Drawing", "Capture the essence of 10 poses in 30 seconds each", "figure.walk", 8, [ChallengeRequirement.completeInTime(30), ChallengeRequirement.drawForMinutes(8)]),
        ("Contour Challenge", "Draw 5 objects using only contour lines", "scribble", 20, [ChallengeRequirement.useSpecificTool("Pencil"), ChallengeRequirement.drawForMinutes(20)])
    ]
    
    private let colorChallenges = [
        ("Monochrome Magic", "Create a stunning artwork using only one color", "paintpalette", 25, [ChallengeRequirement.useOnlyColors(1), ChallengeRequirement.drawForMinutes(25)]),
        ("Warm vs Cool", "Create a composition showing warm and cool contrast", "thermometer", 30, [ChallengeRequirement.createWithColorPalette(["Orange", "Blue"]), ChallengeRequirement.drawForMinutes(30)]),
        ("Color Harmony", "Use complementary colors to create visual impact", "circle.hexagongrid", 20, [ChallengeRequirement.createWithColorPalette(["Red", "Green"]), ChallengeRequirement.drawForMinutes(20)])
    ]
    
    private let compositionChallenges = [
        ("Rule of Thirds", "Create a landscape following the rule of thirds", "viewfinder", 25, [ChallengeRequirement.drawSpecificShape("Grid"), ChallengeRequirement.drawForMinutes(25)]),
        ("Leading Lines", "Use strong lines to guide the viewer's eye", "arrow.right", 20, [ChallengeRequirement.drawSpecificShape("Arrow"), ChallengeRequirement.drawForMinutes(20)]),
        ("Negative Space", "Focus on the spaces between objects", "circle.dotted", 30, [ChallengeRequirement.drawForMinutes(30)])
    ]
    
    private let techniqueChallenges = [
        ("Cross-Hatching Master", "Use cross-hatching to create depth and shadow", "grid", 25, [ChallengeRequirement.useSpecificTool("Pen"), ChallengeRequirement.achieveStrokeCount(200)]),
        ("Blending Practice", "Create smooth gradients using blending techniques", "paintbrush.fill", 20, [ChallengeRequirement.useSpecificTool("Pencil"), ChallengeRequirement.drawForMinutes(20)]),
        ("Stippling Study", "Create texture using only dots", "circle.grid.3x3.fill", 30, [ChallengeRequirement.achieveStrokeCount(500), ChallengeRequirement.drawForMinutes(30)])
    ]
    
    private let speedChallenges = [
        ("60-Second Sketches", "Complete 10 drawings in 1 minute each", "timer", 12, [ChallengeRequirement.completeInTime(60), ChallengeRequirement.drawForMinutes(12)]),
        ("Lightning Portraits", "Draw 5 faces in 2 minutes each", "person.crop.circle", 12, [ChallengeRequirement.completeInTime(120), ChallengeRequirement.drawForMinutes(12)]),
        ("Quick Studies", "Capture 8 objects in 90 seconds each", "stopwatch", 15, [ChallengeRequirement.completeInTime(90), ChallengeRequirement.drawForMinutes(15)])
    ]
    
    private let creativityChallenges = [
        ("Emotion Expression", "Draw your current mood without using words", "face.smiling", 20, [ChallengeRequirement.improviseTheme("Emotion"), ChallengeRequirement.drawForMinutes(20)]),
        ("Random Word Art", "Create art inspired by a random word generator", "shuffle", 25, [ChallengeRequirement.improviseTheme("Random"), ChallengeRequirement.drawForMinutes(25)]),
        ("Abstract Feelings", "Express a complex emotion through abstract shapes", "scribble.variable", 30, [ChallengeRequirement.improviseTheme("Abstract"), ChallengeRequirement.drawForMinutes(30)])
    ]
}

// MARK: - Challenge Player View (Placeholder)
struct ChallengePlayerView: View {
    let challenge: DailyChallenge
    @ObservedObject var viewModel: ChallengesViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Challenge Player")
                    .font(.largeTitle)
                Text("Playing: \(challenge.title)")
                    .font(.headline)
                
                Spacer()
                
                ModernButton(title: "Complete Challenge", style: .primary) {
                    Task {
                        await viewModel.handleChallengeCompletion(challenge)
                        NotificationCenter.default.post(name: .challengeCompleted, object: challenge)
                        dismiss()
                    }
                }
                .padding()
            }
            .navigationTitle(challenge.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Completed Challenges View (Placeholder)
struct CompletedChallengesView: View {
    @ObservedObject var viewModel: ChallengesViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(viewModel.recentCompletions) { completion in
                ChallengeCompletionRow(completion: completion)
            }
            .navigationTitle("Completed Challenges")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let challengeCompleted = Notification.Name("challengeCompleted")
}
