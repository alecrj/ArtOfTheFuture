// MARK: - Premium Learning Tree View - FAANG Quality
// File: ArtOfTheFuture/Features/Lessons/Views/LearningTreeView.swift

import SwiftUI

struct LearningTreeView: View {
    @StateObject private var viewModel = LearningTreeViewModel()
    @State private var selectedUnit: LearningUnit?
    @State private var showContent = false
    @State private var selectedSection = 0
    @Namespace private var animation
    
    var body: some View {
        NavigationView {
            ZStack {
                // Premium gradient background
                PremiumLearningBackground()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Premium header
                        PremiumLearningHeader(
                            totalLessons: viewModel.learningTree.totalLessons,
                            completedLessons: viewModel.learningTree.completedLessons,
                            currentLevel: viewModel.currentLevel,
                            totalXP: viewModel.totalXP,
                            animated: showContent
                        )
                        .padding(.horizontal, 20)
                        
                        // Section selector
                        PremiumSectionSelector(
                            sections: viewModel.learningTree.sections,
                            selectedIndex: $selectedSection,
                            namespace: animation
                        )
                        .padding(.horizontal, 20)
                        
                        // Learning units
                        if !viewModel.learningTree.sections.isEmpty {
                            PremiumLearningSection(
                                section: viewModel.learningTree.sections[selectedSection],
                                onUnitSelected: { unit in
                                    selectedUnit = unit
                                },
                                animated: showContent
                            )
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                Task {
                    await viewModel.loadTree()
                    withAnimation(.spring(response: 0.6).delay(0.2)) {
                        showContent = true
                    }
                }
            }
            .sheet(item: $selectedUnit) { unit in
                UnitDetailView(
                    unit: unit,
                    onLessonSelect: { lesson in
                        // Navigate to lesson player
                        selectedUnit = nil
                    }
                )
            }
        }
    }
}

// MARK: - Premium Learning Background
struct PremiumLearningBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color.blue.opacity(0.02),
                    Color.purple.opacity(0.02)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Animated accent gradient
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.05),
                    Color.pink.opacity(0.03),
                    Color.clear
                ],
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animateGradient)
            
            // Geometric pattern
            GeometryReader { geometry in
                ForEach(0..<5) { index in
                    Circle()
                        .fill(Color.blue.opacity(0.02))
                        .frame(width: 200, height: 200)
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat(index) * 200
                        )
                        .blur(radius: 30)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            animateGradient = true
        }
    }
}

// MARK: - Premium Learning Header
struct PremiumLearningHeader: View {
    let totalLessons: Int
    let completedLessons: Int
    let currentLevel: Int
    let totalXP: Int
    let animated: Bool
    
    private var progressPercentage: Int {
        totalLessons > 0 ? Int((Double(completedLessons) / Double(totalLessons)) * 100) : 0
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Title and stats
            VStack(spacing: 16) {
                Text("Your Learning Journey")
                    .font(.largeTitle.bold())
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                HStack(spacing: 32) {
                    PremiumStatBadge(
                        value: "\(completedLessons)",
                        label: "Lessons Done",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    
                    PremiumStatBadge(
                        value: "Level \(currentLevel)",
                        label: "Current",
                        icon: "chart.line.uptrend.xyaxis",
                        color: .blue
                    )
                    
                    PremiumStatBadge(
                        value: "\(totalXP)",
                        label: "Total XP",
                        icon: "star.fill",
                        color: .orange
                    )
                }
            }
            
            // Overall progress bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Overall Progress")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(progressPercentage)% Complete")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.blue)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .frame(height: 16)
                        
                        // Progress
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: animated ? geometry.size.width * (Double(progressPercentage) / 100) : 0,
                                height: 16
                            )
                            .animation(.spring(response: 0.8, dampingFraction: 0.8), value: animated)
                        
                        // Shimmer effect
                        if progressPercentage > 0 && progressPercentage < 100 {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [.clear, .white.opacity(0.4), .clear],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 60, height: 16)
                                .offset(x: geometry.size.width * (Double(progressPercentage) / 100) - 30)
                                .opacity(animated ? 1 : 0)
                                .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: animated)
                        }
                    }
                }
                .frame(height: 16)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 15, y: 8)
        )
        .scaleEffect(animated ? 1.0 : 0.9)
        .opacity(animated ? 1.0 : 0.0)
    }
}

// MARK: - Premium Stat Badge
struct PremiumStatBadge: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.headline.bold())
                    .foregroundColor(.primary)
                
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Premium Section Selector
struct PremiumSectionSelector: View {
    let sections: [LearningSection]
    @Binding var selectedIndex: Int
    let namespace: Namespace.ID
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                    PremiumSectionTab(
                        section: section,
                        isSelected: selectedIndex == index,
                        namespace: namespace,
                        action: {
                            selectedIndex = index
                        }
                    )
                }
            }
        }
    }
}

struct PremiumSectionTab: View {
    let section: LearningSection
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            VStack(spacing: 8) {
                Text(section.title)
                    .font(.subheadline.weight(isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text("\(section.units.count) units")
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .matchedGeometryEffect(id: "sectionTab", in: namespace)
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Premium Learning Section
struct PremiumLearningSection: View {
    let section: LearningSection
    let onUnitSelected: (LearningUnit) -> Void
    let animated: Bool
    
    @State private var visibleUnits: Set<String> = []
    @State private var animationTrigger = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Section info
            VStack(alignment: .leading, spacing: 8) {
                Text(section.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                
                HStack {
                    Label("\(section.completedLessons) of \(section.totalLessons) lessons complete",
                          systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Text("\(section.totalLessons * 10) XP")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 20)
            .opacity(animated ? 1.0 : 0.0)
            
            // Units with staggered animation
            VStack(spacing: 16) {
                ForEach(Array(section.units.enumerated()), id: \.element.id) { index, unit in
                    PremiumUnitCard(
                        unit: unit,
                        unitColor: section.color,
                        isUnlocked: index == 0 || section.units[index - 1].isCompleted,
                        isVisible: visibleUnits.contains(unit.id),
                        action: {
                            if index == 0 || section.units[index - 1].isCompleted {
                                onUnitSelected(unit)
                            }
                        }
                    )
                    .padding(.horizontal, 20)
                }
            }
        }
        .onAppear {
            if animated {
                // Stagger unit appearances
                for (index, unit) in section.units.enumerated() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + (Double(index) * 0.1)) {
                        _ = visibleUnits.insert(unit.id)
                        }
                    }
                }
            }
        }
    }

// MARK: - Premium Unit Card
struct PremiumUnitCard: View {
    let unit: LearningUnit
    let unitColor: Color
    let isUnlocked: Bool
    let isVisible: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    private var progressPercentage: Double {
        unit.progress
    }
    
    private var totalLessons: Int {
        unit.lessons.count
    }
    
    private var totalXP: Int {
        unit.lessons.count * 10 // Assuming 10 XP per lesson
    }
    
    var body: some View {
        Button(action: {
            if isUnlocked {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                action()
            }
        }) {
            HStack(spacing: 20) {
                // Unit icon with progress ring
                ZStack {
                    // Progress ring
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 4)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: progressPercentage)
                        .stroke(
                            LinearGradient(
                                colors: isUnlocked ? [unitColor, unitColor.opacity(0.7)] : [Color(.systemGray4)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.8), value: progressPercentage)
                    
                    // Icon background
                    Circle()
                        .fill(
                            isUnlocked ?
                            LinearGradient(
                                colors: [unitColor.opacity(0.3), unitColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color(.systemGray5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)
                    
                    // Icon
                    Image(systemName: unit.iconName)
                        .font(.system(size: 32))
                        .foregroundColor(isUnlocked ? unitColor : .secondary)
                        .symbolEffect(.bounce, value: isVisible)
                    
                    // Lock overlay
                    if !isUnlocked {
                        Circle()
                            .fill(Color.black.opacity(0.3))
                            .frame(width: 72, height: 72)
                        
                        Image(systemName: "lock.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                
                // Unit info
                VStack(alignment: .leading, spacing: 8) {
                    Text(unit.title)
                        .font(.headline)
                        .foregroundColor(isUnlocked ? .primary : .secondary)
                        .lineLimit(1)
                    
                    Text(unit.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Progress info
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "book.fill")
                                .font(.caption2)
                            Text("\(unit.completedLessons)/\(totalLessons)")
                                .font(.caption)
                        }
                        .foregroundColor(isUnlocked ? .blue : .secondary)
                        
                        if totalXP > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                Text("\(totalXP) XP")
                                    .font(.caption)
                            }
                            .foregroundColor(isUnlocked ? .orange : .secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .opacity(isUnlocked ? 1 : 0.3)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isUnlocked ? Color(.systemBackground) : Color(.systemGray6))
                    .shadow(
                        color: isUnlocked ? .black.opacity(0.08) : .clear,
                        radius: 15,
                        y: 8
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isUnlocked && unit.isCompleted ?
                                LinearGradient(
                                    colors: [.green.opacity(0.3), .green.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .opacity(isVisible ? 1.0 : 0.0)
            .offset(y: isVisible ? 0 : 20)
            .animation(.spring(response: 0.5), value: isVisible)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isUnlocked)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Unit Detail View
struct UnitDetailView: View {
    let unit: LearningUnit
    let onLessonSelect: (Lesson) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var lessons: [Lesson] = []
    @State private var showContent = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Unit header with hero animation
                        PremiumUnitHeader(
                            unit: unit,
                            unitColor: getUnitColor(),
                            animated: showContent
                        )
                        
                        // Lessons list
                        VStack(spacing: 16) {
                            ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                                PremiumLessonRow(
                                    lesson: lesson,
                                    isUnlocked: index == 0 || lessons[index - 1].isCompleted,
                                    index: index,
                                    animated: showContent,
                                    action: {
                                        if index == 0 || lessons[index - 1].isCompleted {
                                            onLessonSelect(lesson)
                                            dismiss()
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            Text("Back")
                                .font(.body)
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .onAppear {
                loadLessons()
                withAnimation(.spring(response: 0.6).delay(0.2)) {
                    showContent = true
                }
            }
        }
    }
    
    private func loadLessons() {
        // Load lessons for this unit
        Task {
            do {
                // Get lessons by IDs
                let allLessons = try await LessonService.shared.getAllLessons()
                lessons = allLessons.filter { unit.lessons.contains($0.id) }
                // Sort by the order in unit.lessons array
                lessons.sort { lesson1, lesson2 in
                    let index1 = unit.lessons.firstIndex(of: lesson1.id) ?? 0
                    let index2 = unit.lessons.firstIndex(of: lesson2.id) ?? 0
                    return index1 < index2
                }
            } catch {
                print("Failed to load lessons: \(error)")
            }
        }
    }
    
    private func getUnitColor() -> Color {
        // Determine color based on section
        if unit.sectionId.contains("beginner") {
            return .green
        } else if unit.sectionId.contains("intermediate") {
            return .blue
        } else {
            return .purple
        }
    }
}

// MARK: - Premium Unit Header
struct PremiumUnitHeader: View {
    let unit: LearningUnit
    let unitColor: Color
    let animated: Bool
    
    private var totalLessons: Int {
        unit.lessons.count
    }
    
    private var totalXP: Int {
        unit.lessons.count * 10 // Assuming 10 XP per lesson
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Hero icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [unitColor.opacity(0.3), unitColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(animated ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6).delay(0.2), value: animated)
                
                Image(systemName: unit.iconName)
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [unitColor, unitColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(animated ? 1.0 : 0.0)
                    .rotationEffect(.degrees(animated ? 0 : -180))
                    .animation(.spring(response: 0.8).delay(0.3), value: animated)
            }
            
            // Unit info
            VStack(spacing: 12) {
                Text(unit.title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                
                Text(unit.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
            }
            .opacity(animated ? 1.0 : 0.0)
            .offset(y: animated ? 0 : 20)
            .animation(.spring(response: 0.6).delay(0.4), value: animated)
            
            // Stats row
            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    Text("\(unit.completedLessons)")
                        .font(.title2.bold())
                        .foregroundColor(.green)
                    Text("Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(totalLessons)")
                        .font(.title2.bold())
                        .foregroundColor(.blue)
                    Text("Total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(totalXP)")
                        .font(.title2.bold())
                        .foregroundColor(.orange)
                    Text("XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
            )
            .scaleEffect(animated ? 1.0 : 0.9)
            .opacity(animated ? 1.0 : 0.0)
            .animation(.spring(response: 0.6).delay(0.5), value: animated)
        }
        .padding(.top, 32)
    }
}

// MARK: - Premium Lesson Row
struct PremiumLessonRow: View {
    let lesson: Lesson
    let isUnlocked: Bool
    let index: Int
    let animated: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var showRow = false
    
    var body: some View {
        Button(action: {
            if isUnlocked {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                action()
            }
        }) {
            HStack(spacing: 16) {
                // Progress indicator
                ZStack {
                    Circle()
                        .fill(
                            isUnlocked ?
                            (lesson.isCompleted ? Color.green.opacity(0.2) : Color.blue.opacity(0.1)) :
                            Color(.systemGray5)
                        )
                        .frame(width: 56, height: 56)
                    
                    if lesson.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    } else {
                        Text("\(index + 1)")
                            .font(.headline.bold())
                            .foregroundColor(isUnlocked ? .blue : .secondary)
                    }
                    
                    if !isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                // Lesson info
                VStack(alignment: .leading, spacing: 6) {
                    Text(lesson.title)
                        .font(.headline)
                        .foregroundColor(isUnlocked ? .primary : .secondary)
                        .lineLimit(1)
                    
                    HStack(spacing: 16) {
                        Label("\(lesson.estimatedMinutes) min", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label("\(lesson.xpReward) XP", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundColor(isUnlocked ? .orange : .secondary)
                    }
                }
                
                Spacer()
                
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isUnlocked ? Color(.systemBackground) : Color(.systemGray6))
                    .shadow(
                        color: isUnlocked ? .black.opacity(0.05) : .clear,
                        radius: 8,
                        y: 4
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                lesson.isCompleted ?
                                Color.green.opacity(0.3) :
                                Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .opacity(showRow ? 1.0 : 0.0)
            .offset(x: showRow ? 0 : 50)
            .animation(.spring(response: 0.5), value: showRow)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isUnlocked)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onAppear {
            if animated {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6 + (Double(index) * 0.1)) {
                    showRow = true
                }
            } else {
                showRow = true
            }
        }
    }
}
