// MARK: - Enhanced Learning Tree View - Duolingo-Style UI
// File: ArtOfTheFuture/Features/Lessons/Views/LearningTreeView.swift

import SwiftUI

struct LearningTreeView: View {
    @StateObject private var viewModel = LearningTreeViewModel()
    @State private var selectedUnit: LearningUnit?
    @State private var showContent = false
    @State private var scrollOffset: CGFloat = 0
    @Namespace private var animation
    
    var body: some View {
        NavigationView {
            ZStack {
                // Premium gradient background
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemGray6)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if viewModel.learningTree.sections.isEmpty && viewModel.isLoading {
                    // Loading state
                    LoadingView()
                } else if viewModel.learningTree.sections.isEmpty && !viewModel.isLoading {
                    // Empty state
                    EmptyStateView()
                } else {
                    // Main content
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Sticky header with parallax effect
                            GeometryReader { geometry in
                                PremiumHeaderView(
                                    viewModel: viewModel,
                                    scrollOffset: geometry.frame(in: .global).minY
                                )
                            }
                            .frame(height: 280)
                            .zIndex(1)
                            
                            // Content
                            VStack(spacing: 24) {
                                // Section tabs
                                if !viewModel.learningTree.sections.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(viewModel.learningTree.sections.indices, id: \.self) { index in
                                                SectionTab(
                                                    section: viewModel.learningTree.sections[index],
                                                    isSelected: viewModel.selectedSection == index,
                                                    namespace: animation
                                                ) {
                                                    withAnimation(.spring(response: 0.3)) {
                                                        viewModel.selectedSection = index
                                                    }
                                                    viewModel.trackSectionView(viewModel.learningTree.sections[index].id)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                    .padding(.top, -20)
                                }
                                
                                // Units grid
                                if !viewModel.learningTree.sections.isEmpty {
                                    let currentSection = viewModel.learningTree.sections[viewModel.selectedSection]
                                    UnitsGrid(
                                        section: currentSection,
                                        viewModel: viewModel,
                                        onUnitSelected: { unit in
                                            viewModel.trackUnitTap(unit.id)
                                            selectedUnit = unit
                                        }
                                    )
                                }
                                
                                // Bottom padding
                                Color.clear.frame(height: 100)
                            }
                        }
                    }
                    .opacity(showContent ? 1.0 : 0.0)
                }
                
                // Error toast
                if viewModel.showError {
                    ErrorToast(message: viewModel.errorMessage ?? "Something went wrong")
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(2)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                Task {
                    await viewModel.loadTree()
                    withAnimation(.spring(response: 0.6)) {
                        showContent = true
                    }
                }
            }
            .refreshable {
                await viewModel.loadTree()
            }
            .sheet(item: $selectedUnit) { unit in
                UnitDetailView(unit: unit, viewModel: viewModel)
            }
        }
    }
}

// MARK: - Premium Header View
struct PremiumHeaderView: View {
    @ObservedObject var viewModel: LearningTreeViewModel
    let scrollOffset: CGFloat
    
    private var headerHeight: CGFloat {
        max(150, 280 + scrollOffset)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Background with parallax
            ZStack {
                // Animated gradient background
                MeshGradient(
                    width: 3,
                    height: 3,
                    points: [
                        [0, 0], [0.5, 0], [1, 0],
                        [0, 0], [0.5, 0], [1, 0],
                        [0, 0.5], [0.5, 0.5], [1, 0.5],
                        [0, 1], [0.5, 1], [1, 1]
                    ],
                    colors: [
                        .blue.opacity(0.3), .purple.opacity(0.2), .blue.opacity(0.3),
                        .purple.opacity(0.2), .orange.opacity(0.1), .purple.opacity(0.2),
                        .blue.opacity(0.3), .purple.opacity(0.2), .blue.opacity(0.3)
                    ]
                )
                .blur(radius: 40)
                .offset(y: scrollOffset * 0.5)
                
                VStack(spacing: 20) {
                    // Stats row
                    HStack(spacing: 30) {
                        StatPill(
                            icon: "flame.fill",
                            value: "\(viewModel.dailyStreak)",
                            label: "Streak",
                            color: .orange
                        )
                        
                        StatPill(
                            icon: "star.fill",
                            value: "\(viewModel.totalXP)",
                            label: "XP",
                            color: .yellow
                        )
                        
                        StatPill(
                            icon: "chart.line.uptrend.xyaxis",
                            value: "Lv.\(viewModel.currentLevel)",
                            label: "Level",
                            color: .purple
                        )
                    }
                    .padding(.top, 60)
                    .opacity(Double(max(0, min(1, 1 - (scrollOffset * -1) / 100))))
                    
                    // Progress section
                    VStack(spacing: 12) {
                        Text("Your Learning Journey")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        
                        // Progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray5))
                                
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * viewModel.learningTree.overallProgress)
                                    .animation(.spring(response: 0.6), value: viewModel.learningTree.overallProgress)
                            }
                        }
                        .frame(height: 24)
                        
                        HStack {
                            Text("\(viewModel.completedLessons.count) lessons completed")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(Int(viewModel.learningTree.overallProgress * 100))%")
                                .font(.subheadline.bold())
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .opacity(Double(max(0, min(1, 1 - (scrollOffset * -1) / 150))))
                }
            }
            .frame(height: headerHeight)
            .clipped()
            
            // Section title that appears on scroll
            if scrollOffset < -100 {
                HStack {
                    Text(viewModel.learningTree.sections[safe: viewModel.selectedSection]?.title ?? "")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(.systemBackground).opacity(0.9))
                .overlay(
                    Rectangle()
                        .fill(Color(.separator))
                        .frame(height: 0.5),
                    alignment: .bottom
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

// MARK: - Units Grid
struct UnitsGrid: View {
    let section: LearningSection
    @ObservedObject var viewModel: LearningTreeViewModel
    let onUnitSelected: (LearningUnit) -> Void
    
    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: 16
        ) {
            ForEach(Array(section.units.enumerated()), id: \.element.id) { index, unit in
                UnitCard(
                    unit: unit,
                    index: index,
                    sectionColor: section.color,
                    isExpanded: viewModel.expandedUnits.contains(unit.id),
                    onTap: {
                        if unit.isUnlocked {
                            withAnimation(.spring(response: 0.3)) {
                                onUnitSelected(unit)
                            }
                        } else {
                            // Show locked animation
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                viewModel.toggleUnitExpansion(unit.id)
                            }
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity).animation(.spring(response: 0.5).delay(Double(index) * 0.05)),
                    removal: .scale.combined(with: .opacity)
                ))
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Unit Card
struct UnitCard: View {
    let unit: LearningUnit
    let index: Int
    let sectionColor: Color
    let isExpanded: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Icon container
                ZStack {
                    // Progress ring
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 6)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: unit.progress)
                        .stroke(
                            LinearGradient(
                                colors: [sectionColor, sectionColor.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6), value: unit.progress)
                    
                    // Icon
                    Image(systemName: unit.iconName)
                        .font(.system(size: 32))
                        .foregroundColor(unit.isUnlocked ? sectionColor : .secondary)
                    
                    // Lock overlay
                    if !unit.isUnlocked {
                        Circle()
                            .fill(Color.black.opacity(0.5))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "lock.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
                .scaleEffect(isPressed ? 0.95 : 1.0)
                
                // Title and progress
                VStack(spacing: 4) {
                    Text(unit.title)
                        .font(.headline)
                        .foregroundColor(unit.isUnlocked ? .primary : .secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text("\(unit.completedLessons)/\(unit.lessons.count) lessons")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Locked message
                if !unit.isUnlocked && isExpanded {
                    Text("Complete previous unit to unlock")
                        .font(.caption2)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.orange.opacity(0.1))
                        )
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(unit.isUnlocked ? sectionColor.opacity(0.3) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Helper Components
struct StatPill: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(value)
                    .font(.headline)
            }
            .foregroundColor(color)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
        )
    }
}

struct SectionTab: View {
    let section: LearningSection
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
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
                                    colors: [section.color, section.color.opacity(0.8)],
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


struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "books.vertical.circle")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            
            Text("No lessons available")
                .font(.title2.bold())
            
            Text("Check back soon for new content!")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(40)
    }
}

struct ErrorToast: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.red)
            )
            .padding(.top, 50)
            .padding(.horizontal, 20)
    }
}


