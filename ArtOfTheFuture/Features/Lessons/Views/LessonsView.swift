// MARK: - Updated Lessons View with Learning Tree
// **REPLACE:** ArtOfTheFuture/Features/Lessons/Views/LessonsView.swift

import SwiftUI

struct LessonsView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Learning Tree Tab
            LearningTreeView()
                .tabItem {
                    Label("Path", systemImage: "map")
                }
                .tag(0)

            // Practice Tab (existing lessons list for quick access)
            PracticeLessonsView()
                .tabItem {
                    Label("Practice", systemImage: "pencil.and.scribble")
                }
                .tag(1)
        }
    }
}
// MARK: - Practice Lessons View (Quick Access)
struct PracticeLessonsView: View {
    @StateObject private var viewModel = LessonsViewModel()
    @State private var selectedLesson: Lesson?
    @State private var showFilters = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView("Loading lessons...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            quickStatsView
                                .padding(.horizontal)

                            filterPillsView

                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.filteredLessons) { lesson in
                                    QuickAccessLessonCard(
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
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .navigationTitle("Practice")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showFilters = true } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
        .sheet(isPresented: $showFilters) {
            FiltersView(viewModel: viewModel)
        }
        .fullScreenCover(item: $selectedLesson) { lesson in
            LessonPlayerView(lesson: lesson)
        }
        .task {
            await viewModel.loadLessons()
        }
    }

    // MARK: - Quick Stats
    private var quickStatsView: some View {
        HStack(spacing: 12) {
            LessonStatCard(
                title: "Streak",
                value: "\(viewModel.currentStreak)",
                icon: "flame.fill",
                color: .orange
            )
            LessonStatCard(
                title: "Level",
                value: "\(viewModel.currentLevel)",
                icon: "star.fill",
                color: .yellow
            )
            LessonStatCard(
                title: "Total XP",
                value: "\(viewModel.currentTotalXP)",
                icon: "sparkles",
                color: .purple
            )
        }
    }

    // MARK: - Filter Pills
    private var filterPillsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterPill(
                    title: "All",
                    isSelected: viewModel.selectedCategory == nil,
                    action: { viewModel.selectedCategory = nil }
                )
                ForEach(LessonCategory.allCases, id: \.self) { category in
                    FilterPill(
                        title: category.rawValue,
                        isSelected: viewModel.selectedCategory == category,
                        action: { viewModel.selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Quick Access Lesson Card
struct QuickAccessLessonCard: View {
    let lesson: Lesson
    let progress: Double?
    let isLocked: Bool
    let isCompleted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(lesson.color.gradient.opacity(isLocked ? 0.3 : 1.0))
                        .frame(width: 60, height: 60)

                    Image(systemName: lesson.icon)
                        .font(.title2)
                        .foregroundColor(.white)

                    if isLocked {
                        Circle()
                            .fill(Color.black.opacity(0.5))
                            .frame(width: 60, height: 60)
                        Image(systemName: "lock.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(lesson.title)
                        .font(.headline)
                        .foregroundColor(isLocked ? .secondary : .primary)

                    HStack(spacing: 12) {
                        Label("\(lesson.estimatedMinutes) min", systemImage: "clock")
                        Label("\(lesson.xpReward) XP", systemImage: "star.fill")
                        if isCompleted {
                            Label("Done", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)

                    if let p = progress, p > 0 && !isCompleted {
                        ProgressView(value: p)
                            .progressViewStyle(.linear)
                            .tint(lesson.color)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isLocked)
    }
}

// MARK: - Stat Card
struct LessonStatCard: View {
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
                .font(.title3)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

// MARK: - Filter Pill
struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color(.systemGray5))
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Filters View
struct FiltersView: View {
    @ObservedObject var viewModel: LessonsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Difficulty") {
                    ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                        Toggle(difficulty.rawValue,
                               isOn: Binding(
                                   get: { viewModel.selectedDifficulties.contains(difficulty) },
                                   set: { _ in viewModel.toggleDifficulty(difficulty) }
                               )
                        )
                    }
                }

                Section("Status") {
                    Toggle("Show Completed", isOn: $viewModel.showCompleted)
                    Toggle("Show Locked", isOn: $viewModel.showLocked)
                    Toggle("Show In Progress", isOn: $viewModel.showInProgress)
                }

                Section("Sort By") {
                    Picker("Sort", selection: $viewModel.sortOption) {
                        ForEach(LessonSortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section {
                    Button("Clear All Filters") {
                        viewModel.clearFilters()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
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

#Preview {
    LessonsView()
}
