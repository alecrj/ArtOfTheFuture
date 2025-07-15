// MARK: - Shared Lesson Components
// File: ArtOfTheFuture/Features/Lessons/Views/SharedLessonComponents.swift

import SwiftUI

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
                        .fill(isSelected ? Color.blue : Color(.systemGray6))
                )
        }
        .buttonStyle(.plain)
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
                // Icon
                ZStack {
                    Circle()
                        .fill(isLocked ? Color(.systemGray4) : lesson.color.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: isLocked ? "lock.fill" : lesson.icon)
                        .font(.title3)
                        .foregroundColor(isLocked ? .secondary : lesson.color)
                }

                VStack(alignment: .leading, spacing: 4) {
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
