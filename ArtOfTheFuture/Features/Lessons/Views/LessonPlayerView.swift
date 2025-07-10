import SwiftUI
import PencilKit

struct LessonPlayerView: View {
    let lesson: Lesson
    @StateObject private var viewModel: LessonPlayerViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingExitAlert = false
    
    init(lesson: Lesson) {
        self.lesson = lesson
        _viewModel = StateObject(wrappedValue: LessonPlayerViewModel(lesson: lesson))
        print("🎯 LessonPlayerView initialized with: \(lesson.title)")
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Simple background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Simple header
                    headerView
                    
                    // Content area
                    contentArea
                    
                    // Bottom controls
                    bottomControls
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            print("📱 LessonPlayerView appeared")
            print("📊 Current step: \(viewModel.currentStepIndex)")
            print("📝 Total steps: \(lesson.steps.count)")
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                Button("Exit") {
                    dismiss()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray5))
                .cornerRadius(20)
                
                Spacer()
                
                Text(lesson.title)
                    .font(.headline)
                
                Spacer()
                
                Text("\(viewModel.currentStepIndex + 1)/\(lesson.steps.count)")
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray5))
                    .cornerRadius(20)
            }
            
            // Simple progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * viewModel.progress, height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding()
    }
    
    // MARK: - Content Area
    private var contentArea: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let currentStep = viewModel.currentStep {
                    // Step title
                    Text(currentStep.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    // Step instruction
                    Text(currentStep.instruction)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Simple content based on step type
                    stepContentView(currentStep)
                } else {
                    Text("No step content available")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .padding()
        }
    }
    
    // MARK: - Step Content
    @ViewBuilder
    private func stepContentView(_ step: LessonStep) -> some View {
        switch step.content {
        case .introduction(let content):
            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                ForEach(Array(content.bulletPoints.enumerated()), id: \.offset) { _, point in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(point)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
            .onAppear {
                print("📝 Introduction step appeared")
                viewModel.setCanProceed(true)
            }
            
        case .drawing(let content):
            VStack(spacing: 16) {
                Text("Drawing Exercise")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                // Simple canvas placeholder
                Rectangle()
                    .fill(Color(.systemGray6))
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            Image(systemName: "paintbrush.fill")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("Drawing Canvas")
                                .foregroundColor(.gray)
                        }
                    )
                    .cornerRadius(12)
                
                Button("Mark as Complete") {
                    viewModel.setCanProceed(true)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .onAppear {
                print("🎨 Drawing step appeared")
            }
            
        case .theory(let content):
            VStack(spacing: 16) {
                Text("Theory Question")
                    .font(.headline)
                    .foregroundColor(.purple)
                
                Text(content.question)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                
                ForEach(content.options) { option in
                    Button(action: {
                        viewModel.selectAnswer(option.id)
                    }) {
                        HStack {
                            Image(systemName: viewModel.selectedAnswers.contains(option.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(viewModel.selectedAnswers.contains(option.id) ? .blue : .gray)
                            
                            Text(option.text)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
            }
            .onAppear {
                print("🧠 Theory step appeared")
            }
            
        case .challenge(let content):
            VStack(spacing: 16) {
                Text("Challenge")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                Text(content.prompt)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                
                Button("Complete Challenge") {
                    viewModel.setCanProceed(true)
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .onAppear {
                print("🏆 Challenge step appeared")
            }
        }
    }
    
    // MARK: - Bottom Controls
    private var bottomControls: some View {
        VStack(spacing: 16) {
            Button(action: {
                print("🔄 Main action button pressed")
                viewModel.handleMainAction()
            }) {
                Text(viewModel.mainActionTitle)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(viewModel.canProceed ? Color.blue : Color(.systemGray4))
                    .cornerRadius(16)
            }
            .disabled(!viewModel.canProceed)
            
            if viewModel.showSuccess {
                Text("🎉 Success! +\(viewModel.stepXPEarned) XP")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Simplified ViewModel
@MainActor
final class LessonPlayerViewModel: ObservableObject {
    let lesson: Lesson
    
    @Published var currentStepIndex = 0
    @Published var progress: Double = 0
    @Published var canProceed = false
    @Published var showSuccess = false
    @Published var selectedAnswers: Set<String> = []
    
    var currentStep: LessonStep? {
        guard currentStepIndex < lesson.steps.count else {
            print("❌ Step index \(currentStepIndex) out of bounds")
            return nil
        }
        return lesson.steps[currentStepIndex]
    }
    
    var mainActionTitle: String {
        if canProceed {
            return currentStepIndex == lesson.steps.count - 1 ? "Complete Lesson" : "Continue"
        } else {
            return "Continue"
        }
    }
    
    var isLessonComplete: Bool {
        currentStepIndex >= lesson.steps.count - 1
    }
    
    var stepXPEarned: Int {
        currentStep?.xpValue ?? 0
    }
    
    init(lesson: Lesson) {
        self.lesson = lesson
        updateProgress()
        print("✅ ViewModel initialized with \(lesson.steps.count) steps")
    }
    
    func handleMainAction() {
        print("🎯 Handling main action - canProceed: \(canProceed)")
        
        if canProceed {
            if isLessonComplete {
                print("🎊 Lesson complete!")
                // Show completion and exit
            } else {
                print("➡️ Moving to next step")
                nextStep()
            }
        }
    }
    
    func nextStep() {
        if currentStepIndex < lesson.steps.count - 1 {
            currentStepIndex += 1
            resetStepState()
            updateProgress()
            print("📍 Moved to step \(currentStepIndex + 1)")
        }
    }
    
    func setCanProceed(_ canProceed: Bool) {
        print("🔄 Setting canProceed to: \(canProceed)")
        self.canProceed = canProceed
    }
    
    func selectAnswer(_ answerId: String) {
        print("🎯 Answer selected: \(answerId)")
        selectedAnswers = [answerId]
        setCanProceed(true)
    }
    
    private func resetStepState() {
        canProceed = false
        showSuccess = false
        selectedAnswers.removeAll()
    }
    
    private func updateProgress() {
        let totalSteps = max(lesson.steps.count, 1)
        progress = Double(currentStepIndex + 1) / Double(totalSteps)
        print("📊 Progress updated: \(progress)")
    }
}

#Preview {
    if let lesson = Curriculum.allLessons.first {
        LessonPlayerView(lesson: lesson)
    } else {
        Text("No lessons available")
    }
}
