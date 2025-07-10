import SwiftUI
import PencilKit

struct LessonPlayerView: View {
    let lesson: Lesson
    @StateObject private var viewModel: LessonPlayerViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(lesson: Lesson) {
        self.lesson = lesson
        _viewModel = StateObject(wrappedValue: LessonPlayerViewModel(lesson: lesson))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Clean background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Content
                    ScrollView {
                        VStack(spacing: 24) {
                            if let currentStep = viewModel.currentStep {
                                stepContentView(currentStep)
                            }
                        }
                        .padding()
                    }
                    
                    // Bottom button - Always visible like Duolingo
                    bottomButton
                }
                
                // Success overlay
                if viewModel.showSuccess {
                    successOverlay
                }
                
                // Lesson complete overlay
                if viewModel.showLessonComplete {
                    lessonCompleteOverlay
                }
            }
        }
        .navigationBarHidden(true)
        .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .frame(width: 40, height: 40)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text(lesson.title)
                    .font(.headline)
                
                Spacer()
                
                Text("\(viewModel.currentStepIndex + 1)/\(lesson.steps.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Progress bar - Duolingo style
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.green)
                        .frame(width: geometry.size.width * viewModel.progress, height: 8)
                        .animation(.spring(response: 0.5), value: viewModel.progress)
                }
            }
            .frame(height: 8)
        }
        .padding()
    }
    
    // MARK: - Step Content
    @ViewBuilder
    private func stepContentView(_ step: LessonStep) -> some View {
        VStack(spacing: 20) {
            // Title and instruction
            VStack(spacing: 12) {
                Text(step.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(step.instruction)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Content based on type
            switch step.content {
            case .introduction(let content):
                introductionView(content)
                
            case .drawing(let content):
                drawingView(content)
                
            case .theory(let content):
                theoryView(content)
                
            case .challenge(let content):
                challengeView(content)
            }
        }
    }
    
    // MARK: - Introduction View
    private func introductionView(_ content: IntroContent) -> some View {
        VStack(spacing: 20) {
            // Icon
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            // Bullet points
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(content.bulletPoints.enumerated()), id: \.offset) { _, point in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                        
                        Text(point)
                            .font(.body)
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .onAppear {
            // Auto-enable continue for introduction
            viewModel.setCanProceed(true)
        }
    }
    
    // MARK: - Drawing View (FIXED COLORS)
    private func drawingView(_ content: DrawingContent) -> some View {
        VStack(spacing: 16) {
            // Drawing canvas with proper colors
            FixedDrawingCanvasView(onDrawingChanged: { hasDrawing in
                viewModel.setCanProceed(hasDrawing)
            })
            .frame(height: 250)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
            
            // Drawing instructions
            Text("Draw on the white canvas above. Your strokes should appear in black.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Theory View
    private func theoryView(_ content: TheoryContent) -> some View {
        VStack(spacing: 16) {
            // Question
            Text(content.question)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            
            // Options
            VStack(spacing: 12) {
                ForEach(content.options) { option in
                    Button(action: {
                        viewModel.selectAnswer(option.id)
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: viewModel.selectedAnswers.contains(option.id) ? "circle.fill" : "circle")
                                .foregroundColor(viewModel.selectedAnswers.contains(option.id) ? .blue : .gray)
                                .font(.title3)
                            
                            Text(option.text)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(viewModel.selectedAnswers.contains(option.id) ? Color.blue.opacity(0.1) : Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(viewModel.selectedAnswers.contains(option.id) ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Challenge View
    private func challengeView(_ content: ChallengeContent) -> some View {
        VStack(spacing: 16) {
            // Prompt
            Text(content.prompt)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    LinearGradient(colors: [.orange.opacity(0.2), .pink.opacity(0.2)], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(12)
            
            // Drawing area with proper colors
            FixedDrawingCanvasView(onDrawingChanged: { hasDrawing in
                viewModel.setCanProceed(hasDrawing)
            })
            .frame(height: 200)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
        }
    }
    
    // MARK: - Bottom Button (Duolingo Style)
    private var bottomButton: some View {
        Button(action: {
            viewModel.handleMainAction()
        }) {
            Text(viewModel.mainActionTitle)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(viewModel.canProceed ? Color.green : Color(.systemGray4))
                .cornerRadius(16)
        }
        .disabled(!viewModel.canProceed)
        .padding()
        .animation(.easeInOut(duration: 0.2), value: viewModel.canProceed)
    }
    
    // MARK: - Success Overlay
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Great!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("+\(viewModel.stepXPEarned) XP")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 10)
        }
    }
    
    // MARK: - Lesson Complete Overlay
    private var lessonCompleteOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Celebration animation
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)
                }
                
                Text("Lesson Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("+\(viewModel.totalXPEarned) XP")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("You unlocked the next lesson!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 10)
        }
    }
}

// MARK: - Fixed Drawing Canvas (COLOR ISSUE RESOLVED)
struct FixedDrawingCanvasView: View {
    @State private var canvasView = PKCanvasView()
    let onDrawingChanged: (Bool) -> Void
    
    var body: some View {
        FixedCanvasRepresentable(canvasView: $canvasView, onDrawingChanged: onDrawingChanged)
    }
}

struct FixedCanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    let onDrawingChanged: (Bool) -> Void
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = UIColor.systemBackground // FIXED: Proper background
        canvasView.isOpaque = false // FIXED: Allow transparency
        canvasView.delegate = context.coordinator
        
        // FIXED: Set proper default tool with correct color
        let blackColor = UIColor.label // FIXED: Use system label color (black in light mode)
        canvasView.tool = PKInkingTool(.pen, color: blackColor, width: 3.0)
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Updates handled by delegate
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onDrawingChanged: onDrawingChanged)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        let onDrawingChanged: (Bool) -> Void
        
        init(onDrawingChanged: @escaping (Bool) -> Void) {
            self.onDrawingChanged = onDrawingChanged
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            let hasDrawing = !canvasView.drawing.strokes.isEmpty
            onDrawingChanged(hasDrawing)
        }
    }
}

// MARK: - Enhanced ViewModel with Progress Persistence
@MainActor
final class LessonPlayerViewModel: ObservableObject {
    let lesson: Lesson
    
    @Published var currentStepIndex = 0
    @Published var progress: Double = 0
    @Published var canProceed = false
    @Published var showSuccess = false
    @Published var showLessonComplete = false
    @Published var selectedAnswers: Set<String> = []
    @Published var shouldDismiss = false
    
    private var stepXPEarnedValues: [Int] = []
    private let progressService: ProgressServiceProtocol
    private let userService: UserServiceProtocol
    
    var currentStep: LessonStep? {
        guard currentStepIndex < lesson.steps.count else { return nil }
        return lesson.steps[currentStepIndex]
    }
    
    var mainActionTitle: String {
        if currentStepIndex == lesson.steps.count - 1 {
            return "Complete Lesson"
        } else {
            return "Continue"
        }
    }
    
    var stepXPEarned: Int {
        currentStep?.xpValue ?? 0
    }
    
    var totalXPEarned: Int {
        stepXPEarnedValues.reduce(0, +) + lesson.xpReward
    }
    
    init(lesson: Lesson) {
        self.lesson = lesson
        self.progressService = Container.shared.progressService
        self.userService = Container.shared.userService
        updateProgress()
    }
    
    // MARK: - Main Action with Progress Persistence
    func handleMainAction() {
        guard let step = currentStep else { return }
        
        // Validate if needed
        if needsValidation(step) {
            if !validateStep(step) {
                // Show error feedback briefly
                return
            }
        }
        
        // Save step progress
        Task {
            do {
                try await progressService.updateLessonProgress(
                    lessonId: lesson.id,
                    stepId: step.id,
                    score: 1.0, // Full score for completion
                    timeSpent: 10.0 // Estimated time
                )
            } catch {
                print("❌ Failed to save step progress: \(error)")
            }
        }
        
        // Track XP
        stepXPEarnedValues.append(step.xpValue)
        
        withAnimation(.spring(response: 0.3)) {
            showSuccess = true
        }
        
        // Auto-proceed after success animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.proceedToNext()
        }
    }
    
    private func proceedToNext() {
        withAnimation(.spring(response: 0.3)) {
            showSuccess = false
        }
        
        if currentStepIndex == lesson.steps.count - 1 {
            // Lesson complete - SAVE PROGRESS
            completeLessonWithPersistence()
        } else {
            // Next step
            currentStepIndex += 1
            resetStepState()
            updateProgress()
        }
    }
    
    // MARK: - Lesson Completion with Persistence
    private func completeLessonWithPersistence() {
        Task {
            do {
                // Save lesson completion
                try await progressService.completeLesson(lesson.id)
                
                // Award total XP to user
                try await userService.updateUser(User(
                    id: "current_user", // This should be the actual user ID
                    displayName: "User",
                    totalXP: totalXPEarned
                ))
                
                print("✅ Lesson completed and progress saved!")
                
                // Show completion overlay
                await MainActor.run {
                    withAnimation(.spring(response: 0.5)) {
                        showLessonComplete = true
                    }
                }
                
                // Auto-dismiss after celebration
                try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                
                await MainActor.run {
                    shouldDismiss = true
                }
                
            } catch {
                print("❌ Failed to save lesson completion: \(error)")
                // Still allow dismissal even if save fails
                await MainActor.run {
                    shouldDismiss = true
                }
            }
        }
    }
    
    func selectAnswer(_ answerId: String) {
        selectedAnswers = [answerId]
        setCanProceed(true)
    }
    
    func setCanProceed(_ canProceed: Bool) {
        self.canProceed = canProceed
    }
    
    private func needsValidation(_ step: LessonStep) -> Bool {
        switch step.content {
        case .theory:
            return true
        default:
            return false
        }
    }
    
    private func validateStep(_ step: LessonStep) -> Bool {
        switch step.content {
        case .theory(let content):
            let correct = Set(content.correctAnswers)
            return selectedAnswers == correct
        default:
            return true
        }
    }
    
    private func resetStepState() {
        canProceed = false
        selectedAnswers.removeAll()
    }
    
    private func updateProgress() {
        let totalSteps = max(lesson.steps.count, 1)
        withAnimation(.spring(response: 0.5)) {
            progress = Double(currentStepIndex + 1) / Double(totalSteps)
        }
    }
}

#Preview {
    if let lesson = Curriculum.allLessons.first {
        LessonPlayerView(lesson: lesson)
    } else {
        Text("No lessons available")
    }
}
