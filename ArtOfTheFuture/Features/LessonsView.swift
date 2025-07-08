// MARK: - Updated LessonsView with Interactive Support
// Update your existing ArtOfTheFuture/Features/LessonsView.swift

import SwiftUI

struct LessonsView: View {
    @StateObject private var viewModel = LessonsViewModel()
    @State private var selectedLesson: InteractiveLesson?
    @State private var showingLessonPlayer = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Learning Path Progress
                    learningPathHeader
                    
                    // Interactive Lessons
                    ForEach(viewModel.interactiveLessons) { lesson in
                        InteractiveLessonCard(lesson: lesson) {
                            selectedLesson = lesson
                            showingLessonPlayer = true
                        }
                        .padding(.horizontal)
                    }
                    
                    // Traditional Lessons (if any remain)
                    ForEach(viewModel.traditionalLessons) { lesson in
                        LessonCard(lesson: lesson)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Learn")
            .background(Color(.systemGroupedBackground))
            .task {
                await viewModel.loadLessons()
            }
            .fullScreenCover(isPresented: $showingLessonPlayer) {
                if let lesson = selectedLesson {
                    LessonPlayerView(lesson: lesson)
                }
            }
        }
    }
    
    private var learningPathHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Learning Path")
                        .font(.headline)
                    Text("\(viewModel.completedCount) of \(viewModel.totalLessons) completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Level badge
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 50, height: 50)
                    
                    Text("L\(viewModel.userLevel)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * viewModel.overallProgress, height: 8)
                        .animation(.easeInOut(duration: 0.5), value: viewModel.overallProgress)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        .padding(.horizontal)
    }
}

// MARK: - Interactive Lesson Card
struct InteractiveLessonCard: View {
    let lesson: InteractiveLesson
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Lesson thumbnail/icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(lesson.isLocked ? Color(.systemGray5) : lesson.category.color.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    if lesson.isLocked {
                        Image(systemName: "lock.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                    } else if lesson.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: lesson.category.icon)
                            .font(.title)
                            .foregroundColor(lesson.category.color)
                    }
                }
                
                // Lesson content
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(lesson.title)
                            .font(.headline)
                            .foregroundColor(lesson.isLocked ? .secondary : .primary)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        if lesson.isCompleted {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Text(lesson.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Lesson metadata
                    HStack {
                        Label("\(lesson.estimatedMinutes)m", systemImage: "clock")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Label("\(lesson.xpReward) XP", systemImage: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        if lesson.isCompleted {
                            Text("\(Int(lesson.bestScore * 100))%")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                    }
                    
                    // Progress indicator for partially completed
                    if !lesson.isLocked && !lesson.isCompleted {
                        HStack(spacing: 4) {
                            ForEach(0..<lesson.steps.count, id: \.self) { index in
                                Circle()
                                    .fill(index < getCompletedSteps(lesson) ? Color.blue : Color(.systemGray5))
                                    .frame(width: 6, height: 6)
                            }
                        }
                    }
                }
                
                // Action indicator
                if !lesson.isLocked {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
            .scaleEffect(lesson.isLocked ? 1.0 : 1.0)
            .opacity(lesson.isLocked ? 0.6 : 1.0)
        }
        .disabled(lesson.isLocked)
        .buttonStyle(.plain)
    }
    
    private func getCompletedSteps(_ lesson: InteractiveLesson) -> Int {
        // This would calculate completed steps from progress
        return lesson.isCompleted ? lesson.steps.count : 0
    }
}

// MARK: - Lessons ViewModel
@MainActor
final class LessonsViewModel: ObservableObject {
    @Published var interactiveLessons: [InteractiveLesson] = []
    @Published var traditionalLessons: [Lesson] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let lessonService: LessonServiceProtocol
    private let progressService: ProgressServiceProtocol
    
    var completedCount: Int {
        interactiveLessons.filter { $0.isCompleted }.count
    }
    
    var totalLessons: Int {
        interactiveLessons.count
    }
    
    var overallProgress: Double {
        guard totalLessons > 0 else { return 0 }
        return Double(completedCount) / Double(totalLessons)
    }
    
    var userLevel: Int {
        UserDefaults.standard.integer(forKey: "userLevel")
    }
    
    init(
        lessonService: LessonServiceProtocol? = nil,
        progressService: ProgressServiceProtocol? = nil
    ) {
        self.lessonService = lessonService ?? Container.shared.lessonService
        self.progressService = progressService ?? Container.shared.progressService
    }
    
    func loadLessons() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Load interactive lessons
            let interactive = try await lessonService.getLessonsForUser()
            self.interactiveLessons = interactive
            
            // Keep traditional lessons for now
            self.traditionalLessons = MockDataService.shared.getMockLessons()
            
        } catch {
            errorMessage = "Failed to load lessons: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
