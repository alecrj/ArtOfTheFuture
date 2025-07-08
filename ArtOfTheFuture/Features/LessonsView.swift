import SwiftUI

struct LessonsView: View {
    @State private var lessons = MockDataService.shared.getMockLessons()
    @State private var selectedLesson: Lesson?
    @State private var showingLesson = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(lessons) { lesson in
                        LessonCard(lesson: lesson) {
                            selectedLesson = lesson
                            showingLesson = true
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Learn")
            .background(Color(.systemGroupedBackground))
        }
        .fullScreenCover(isPresented: $showingLesson) {
            if let lesson = selectedLesson {
                SimpleLessonPlayerView(lesson: lesson)
            }
        }
        .onChange(of: showingLesson) { value in
            print("🔍 showingLesson changed to: \(value)")
        }
    }
}

struct LessonCard: View {
    let lesson: Lesson
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Circle()
                    .fill(lesson.isLocked ? Color.gray : Color.blue)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: lesson.isLocked ? "lock.fill" : iconForCategory(lesson.category))
                            .foregroundColor(.white)
                            .font(.title2)
                    )
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.headline)
                        .foregroundColor(lesson.isLocked ? .secondary : .primary)
                    
                    Text(lesson.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // XP only - no time estimate
                    HStack {
                        Label("\(lesson.xpReward) XP", systemImage: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if lesson.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Spacer()
                
                if !lesson.isLocked {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        }
        .disabled(lesson.isLocked)
        .buttonStyle(.plain)
    }
    
    func iconForCategory(_ category: Lesson.LessonCategory) -> String {
        switch category {
        case .basics: return "pencil"
        case .sketching: return "scribble"
        case .coloring: return "paintpalette"
        case .shading: return "circle.lefthalf.filled"
        case .perspective: return "cube"
        case .portrait: return "person"
        case .landscape: return "photo"
        }
    }
}

#Preview {
    LessonsView()
}
