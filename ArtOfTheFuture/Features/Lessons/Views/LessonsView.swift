// MARK: - Modern Lessons View (BUILD ERROR FIXED)
// **REPLACE:** ArtOfTheFuture/Features/Lessons/Views/LessonsView.swift

import SwiftUI

struct LessonsView: View {
    @StateObject private var viewModel = LessonsViewModel()
    @State private var selectedLesson: Lesson?
    @State private var searchText = ""
    @State private var showFilters = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private let adaptiveColumns = [
        GridItem(.adaptive(minimum: DeviceType.current.isIPad ? 350 : 300), spacing: Dimensions.paddingMedium)
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            // Content
            if DeviceType.current.isIPad && horizontalSizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
            }
            
            // Floating filter button
            floatingFilterButton
        }
        .task {
            await viewModel.loadLessons()
        }
        .sheet(item: $selectedLesson) { lesson in
            NavigationView {
                LessonPlayerView(lesson: lesson)
            }
        }
        .sheet(isPresented: $showFilters) {
            FiltersSheet(viewModel: viewModel)
        }
    }
    
    // MARK: - iPhone Layout
    private var iPhoneLayout: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            customNavigationBar
            
            ScrollView {
                VStack(spacing: Dimensions.paddingLarge) {
                    // Progress Overview
                    progressOverview
                        .padding(.horizontal)
                    
                    // Category Pills
                    categoryPills
                    
                    // Lessons List
                    lessonsList
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
    }
    
    // MARK: - iPad Layout
    private var iPadLayout: some View {
        NavigationView {
            // Sidebar
            sidebarContent
                .navigationTitle("Learn")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showFilters = true }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .symbolVariant(viewModel.hasActiveFilters ? .fill : .none)
                        }
                    }
                }
            
            // Detail view
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    progressOverview
                        .padding()
                    
                    Text("Select a lesson to begin")
                        .font(Typography.headline)
                        .foregroundColor(ColorPalette.textSecondary)
                }
            }
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
    
    // MARK: - Custom Navigation Bar
    private var customNavigationBar: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Learn")
                        .font(Typography.largeTitle)
                        .foregroundColor(ColorPalette.textPrimary)
                    
                    if viewModel.currentStreak > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            
                            Text("\(viewModel.currentStreak) day streak")
                                .font(Typography.caption)
                                .foregroundColor(ColorPalette.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                // Level Badge
                ZStack {
                    Circle()
                        .fill(ColorPalette.warningGradient)
                        .frame(width: 48, height: 48)
                    
                    Text("\(viewModel.currentLevel)")
                        .font(Typography.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, Dimensions.paddingSmall)
            
            // Search Bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(ColorPalette.textSecondary)
                
                TextField("Search lessons", text: $searchText)
                    .font(Typography.body)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(ColorPalette.textSecondary)
                    }
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom, Dimensions.paddingSmall)
        }
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Progress Overview
    private var progressOverview: some View {
        ModernCard {
            VStack(spacing: Dimensions.paddingMedium) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Progress")
                            .font(Typography.headline)
                        
                        Text("\(viewModel.completedLessonsCount) of \(viewModel.lessons.count) completed")
                            .font(Typography.subheadline)
                            .foregroundColor(ColorPalette.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Total XP
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.title3)
                            
                            Text("\(viewModel.currentTotalXP)")
                                .font(Typography.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(ColorPalette.warningGradient)
                        }
                        
                        Text("Total XP")
                            .font(Typography.caption)
                            .foregroundColor(ColorPalette.textSecondary)
                    }
                }
                
                // Progress Bar
                CircularProgressBar(
                    progress: viewModel.overallProgress,
                    gradient: ColorPalette.primaryGradient
                )
                
                // Stats Grid
                HStack(spacing: Dimensions.paddingMedium) {
                    ProgressStatItem(
                        value: "\(viewModel.totalHoursLearned)",
                        label: "Hours",
                        icon: "clock.fill",
                        color: .blue
                    )
                    
                    ProgressStatItem(
                        value: "\(viewModel.averageAccuracy)%",
                        label: "Accuracy",
                        icon: "target",
                        color: .green
                    )
                    
                    ProgressStatItem(
                        value: "\(viewModel.skillsUnlocked)",
                        label: "Skills",
                        icon: "sparkles",
                        color: .purple
                    )
                }
            }
            .padding()
        }
    }
    
    // MARK: - Category Pills
    private var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryPill(
                    title: "All",
                    icon: "square.grid.2x2",
                    isSelected: viewModel.selectedCategory == nil,
                    action: { viewModel.selectedCategory = nil }
                )
                
                ForEach(LessonCategory.allCases, id: \.self) { category in
                    CategoryPill(
                        title: category.rawValue,
                        icon: category.iconName,
                        isSelected: viewModel.selectedCategory == category,
                        action: { viewModel.selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Lessons List
    private var lessonsList: some View {
        LazyVStack(spacing: Dimensions.paddingSmall) {
            ForEach(viewModel.filteredLessons) { lesson in
                ModernLessonCard(
                    lesson: lesson,
                    progress: viewModel.getLessonProgress(for: lesson.id),
                    isLocked: viewModel.isLessonLocked(lesson.id),
                    isCompleted: viewModel.completedLessons.contains(lesson.id),
                    action: {
                        if !viewModel.isLessonLocked(lesson.id) {
                            selectedLesson = lesson
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            }
        }
    }
    
    // MARK: - Sidebar Content (iPad)
    private var sidebarContent: some View {
        List {
            // Progress section
            Section {
                progressOverview
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            
            // Categories
            Section("Categories") {
                ForEach(LessonCategory.allCases, id: \.self) { category in
                    Label(category.rawValue, systemImage: category.iconName)
                        .foregroundColor(viewModel.selectedCategory == category ? ColorPalette.primaryBlue : ColorPalette.textPrimary)
                        .onTapGesture {
                            viewModel.selectedCategory = category
                        }
                }
            }
            
            // Lessons
            Section("Lessons") {
                ForEach(viewModel.filteredLessons) { lesson in
                    LessonListRow(
                        lesson: lesson,
                        isCompleted: viewModel.completedLessons.contains(lesson.id),
                        isLocked: viewModel.isLessonLocked(lesson.id),
                        onTap: {
                            selectedLesson = lesson
                        }
                    )
                }
            }
        }
        .listStyle(SidebarListStyle())
        .searchable(text: $searchText)
    }
    
    // MARK: - Floating Filter Button
    private var floatingFilterButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                if viewModel.hasActiveFilters {
                    Text("\(viewModel.activeFilterCount)")
                        .font(Typography.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(Circle().fill(ColorPalette.error))
                        .offset(x: -12, y: 12)
                }
                
                IconButton(
                    icon: "line.3.horizontal.decrease.circle.fill",
                    size: .large,
                    style: .primary,
                    action: { showFilters = true }
                )
                .shadow(
                    color: ColorPalette.primaryBlue.opacity(0.3),
                    radius: 12,
                    y: 6
                )
            }
            .padding(.trailing, Dimensions.paddingMedium)
            .padding(.bottom, DeviceType.current.isIPad ? 100 : 80)
        }
    }
}

// MARK: - Modern Lesson Card (FIXED TYPE MISMATCH)
struct ModernLessonCard: View {
    let lesson: Lesson
    let progress: Double?
    let isLocked: Bool
    let isCompleted: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.impact(.medium)
            action()
        }) {
            ModernCard(backgroundColor: cardBackgroundColor) {
                HStack(spacing: Dimensions.paddingMedium) {
                    // Visual Element
                    lessonVisual
                    
                    // Content
                    VStack(alignment: .leading, spacing: 8) {
                        // Title and category
                        VStack(alignment: .leading, spacing: 4) {
                            Text(lesson.title)
                                .font(Typography.headline)
                                .foregroundColor(ColorPalette.textPrimary)
                                .lineLimit(1)
                            
                            HStack(spacing: 8) {
                                Label(lesson.category.rawValue, systemImage: lesson.category.iconName)
                                    .font(Typography.caption)
                                    .foregroundColor(lesson.category.categoryColor)
                                
                                Text("•")
                                    .foregroundColor(ColorPalette.textTertiary)
                                
                                Text(lesson.difficulty.rawValue)
                                    .font(Typography.caption)
                                    .foregroundColor(lesson.difficulty.difficultyColor)
                            }
                        }
                        
                        // Description
                        Text(lesson.description)
                            .font(Typography.subheadline)
                            .foregroundColor(ColorPalette.textSecondary)
                            .lineLimit(2)
                        
                        // Bottom row
                        HStack(spacing: Dimensions.paddingMedium) {
                            // Duration
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.caption)
                                Text("\(lesson.estimatedMinutes)m")
                                    .font(Typography.caption)
                            }
                            .foregroundColor(ColorPalette.textTertiary)
                            
                            // XP
                            if !isLocked {
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.caption)
                                        .foregroundColor(.yellow)
                                    Text("\(lesson.xpReward) XP")
                                        .font(Typography.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.yellow)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.yellow.opacity(0.2))
                                .cornerRadius(8)
                            }
                            
                            Spacer()
                            
                            // Status indicator
                            statusIndicator
                        }
                    }
                }
                .padding()
            }
            .opacity(isLocked ? 0.6 : 1)
            .overlay(
                isCompleted ?
                RoundedRectangle(cornerRadius: Dimensions.cornerRadiusMedium)
                    .stroke(ColorPalette.primaryGreen, lineWidth: 2)
                : nil
            )
            .scaleEffect(isPressed ? 0.98 : 1)
        }
        .buttonStyle(PressedButtonStyle())
        .disabled(isLocked)
    }
    
    private var cardBackgroundColor: Color {
        if isCompleted {
            return ColorPalette.primaryGreen.opacity(0.05)
        } else if isLocked {
            return Color(.systemGray6)
        } else {
            return ColorPalette.surface
        }
    }
    
    // FIXED: Ensures consistent return type (AnyView)
    @ViewBuilder
    private var lessonVisual: some View {
        ZStack {
            if let progress = progress, !isCompleted {
                CircularProgressView(
                    progress: progress,
                    lineWidth: 6,
                    size: DeviceType.current.isIPad ? 80 : 70,
                    gradient: ColorPalette.primaryGradient
                )
            } else {
                Circle()
                    .fill(visualBackgroundFill)
                    .frame(width: DeviceType.current.isIPad ? 80 : 70, height: DeviceType.current.isIPad ? 80 : 70)
            }
            
            Image(systemName: lessonIcon)
                .font(.system(size: DeviceType.current.isIPad ? 32 : 28))
                .foregroundColor(iconColor)
        }
    }
    
    // FIXED: Returns consistent LinearGradient type
    private var visualBackgroundFill: LinearGradient {
        if isLocked {
            return LinearGradient(colors: [Color(.systemGray5)], startPoint: .topLeading, endPoint: .bottomTrailing)
        } else if isCompleted {
            return ColorPalette.successGradient
        } else {
            return LinearGradient(
                colors: [lesson.category.categoryColor.opacity(0.3), lesson.category.categoryColor.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var lessonIcon: String {
        if isLocked {
            return "lock.fill"
        } else if isCompleted {
            return "checkmark.circle.fill"
        } else {
            return lesson.category.iconName
        }
    }
    
    private var iconColor: Color {
        if isLocked {
            return .gray
        } else if isCompleted {
            return .white
        } else {
            return lesson.category.categoryColor
        }
    }
    
    @ViewBuilder
    private var statusIndicator: some View {
        if isCompleted {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(.green)
                .font(.title3)
        } else if !isLocked {
            Image(systemName: "chevron.right")
                .foregroundColor(ColorPalette.textTertiary)
                .font(.caption)
        }
    }
}

// MARK: - Category Pill
struct CategoryPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.selection()
            action()
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline)
                
                Text(title)
                    .font(Typography.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : ColorPalette.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? ColorPalette.primaryGradient : LinearGradient(colors: [Color(.systemGray5)], startPoint: .leading, endPoint: .trailing))
            )
            .overlay(
                !isSelected ?
                Capsule()
                    .stroke(Color(.systemGray4), lineWidth: 1)
                : nil
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Progress Stat Item
struct ProgressStatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(Typography.headline)
                .fontWeight(.bold)
            
            Text(label)
                .font(Typography.caption)
                .foregroundColor(ColorPalette.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Circular Progress Bar
struct CircularProgressBar: View {
    let progress: Double
    let gradient: LinearGradient
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(height: 16)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(gradient)
                    .frame(width: geometry.size.width * animatedProgress, height: 16)
            }
        }
        .frame(height: 16)
        .onAppear {
            withAnimation(AnimationPresets.smooth.delay(0.2)) {
                animatedProgress = progress
            }
        }
    }
}

// MARK: - Lesson List Row (iPad)
struct LessonListRow: View {
    let lesson: Lesson
    let isCompleted: Bool
    let isLocked: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: isLocked ? "lock.fill" : lesson.category.iconName)
                .foregroundColor(isLocked ? .gray : lesson.category.categoryColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(Typography.subheadline)
                    .foregroundColor(ColorPalette.textPrimary)
                
                HStack(spacing: 8) {
                    Text("\(lesson.estimatedMinutes)m")
                        .font(Typography.caption)
                        .foregroundColor(ColorPalette.textSecondary)
                    
                    if !isLocked {
                        Text("• \(lesson.xpReward) XP")
                            .font(Typography.caption)
                            .foregroundColor(.yellow)
                    }
                }
            }
            
            Spacer()
            
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .opacity(isLocked ? 0.6 : 1)
    }
}

// MARK: - Filters Sheet
struct FiltersSheet: View {
    @ObservedObject var viewModel: LessonsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Difficulty") {
                    ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                        HStack {
                            Label(difficulty.rawValue, systemImage: "circle.fill")
                                .foregroundColor(difficulty.difficultyColor)
                            
                            Spacer()
                            
                            if viewModel.selectedDifficulties.contains(difficulty) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(ColorPalette.primaryBlue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.toggleDifficulty(difficulty)
                        }
                    }
                }
                
                Section("Status") {
                    Toggle("Show Completed", isOn: $viewModel.showCompleted)
                    Toggle("Show Locked", isOn: $viewModel.showLocked)
                    Toggle("Show In Progress", isOn: $viewModel.showInProgress)
                }
                
                Section("Sort By") {
                    ForEach(LessonSortOption.allCases, id: \.self) { option in
                        HStack {
                            Text(option.rawValue)
                            
                            Spacer()
                            
                            if viewModel.sortOption == option {
                                Image(systemName: "checkmark")
                                    .foregroundColor(ColorPalette.primaryBlue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.sortOption = option
                        }
                    }
                }
                
                if viewModel.hasActiveFilters {
                    Section {
                        Button("Clear All Filters") {
                            viewModel.clearFilters()
                        }
                        .foregroundColor(ColorPalette.error)
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply") {
                        viewModel.applyFilters()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Enhanced View Model Extensions
extension LessonsViewModel {
    var overallProgress: Double {
        guard lessons.count > 0 else { return 0 }
        return Double(completedLessonsCount) / Double(lessons.count)
    }
    
    var totalHoursLearned: Int {
        // Calculate from completed lessons
        completedLessons.compactMap { lessonId in
            lessons.first { $0.id == lessonId }?.estimatedMinutes
        }.reduce(0, +) / 60
    }
    
    var averageAccuracy: Int {
        // Mock for now
        85
    }
    
    var skillsUnlocked: Int {
        // Count unique categories completed
        Set(lessons.filter { completedLessons.contains($0.id) }.map { $0.category }).count
    }
    
    var currentStreak: Int {
        // Mock for now
        7
    }
    
    var hasActiveFilters: Bool {
        !selectedDifficulties.isEmpty || selectedCategory != nil || !showCompleted || !showLocked
    }
    
    var activeFilterCount: Int {
        selectedDifficulties.count + (selectedCategory != nil ? 1 : 0) + (!showCompleted ? 1 : 0) + (!showLocked ? 1 : 0)
    }
}

#Preview {
    LessonsView()
}
