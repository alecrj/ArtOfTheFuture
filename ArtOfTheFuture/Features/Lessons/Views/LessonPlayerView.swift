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
        ZStack {
            // Premium gradient background
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemGroupedBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with close and progress
                headerView
                
                // Content area
                ScrollView {
                    VStack(spacing: 32) {
                        if let currentStep = viewModel.currentStep {
                            stepContentView(currentStep)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
                
                // Bottom action area - Always visible (Duolingo style)
                bottomActionArea
            }
            
            // Feedback overlays
            if viewModel.showSuccessOverlay {
                SuccessFeedbackOverlay(
                    xpGained: viewModel.stepXPEarned,
                    isCorrect: viewModel.lastAnswerCorrect,
                    explanation: viewModel.currentExplanation,
                    onContinue: { viewModel.proceedAfterFeedback() }
                )
            }
            
            // Lesson completion celebration
            if viewModel.showLessonComplete {
                LessonCompleteCelebration(
                    lesson: lesson,
                    totalXP: viewModel.totalXPEarned,
                    newLevel: viewModel.hasLeveledUp,
                    onDismiss: { viewModel.completeLessonFlow() }
                )
            }
        }
        .navigationBarHidden(true)
        .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
        .onAppear {
            Task {
                await HapticManager.shared.impact(.light)
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                // Close button
                Button(action: {
                    Task {
                        await HapticManager.shared.impact(.light)
                    }
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                // Lesson title
                Text(lesson.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Hearts/lives system
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: index < viewModel.heartsRemaining ? "heart.fill" : "heart")
                            .foregroundColor(index < viewModel.heartsRemaining ? .red : .gray)
                            .font(.title3)
                    }
                }
            }
            
            // Beautiful progress bar
            ProgressBarView(
                progress: viewModel.progress,
                currentStep: viewModel.currentStepIndex + 1,
                totalSteps: lesson.steps.count
            )
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
    
    // MARK: - Step Content
    @ViewBuilder
    private func stepContentView(_ step: LessonStep) -> some View {
        VStack(spacing: 24) {
            // Step header
            VStack(spacing: 12) {
                Text(step.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(step.instruction)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            
            // Content based on type
            switch step.content {
            case .introduction(let content):
                IntroductionContentView(content: content) {
                    viewModel.setCanProceed(true)
                }
                
            case .drawing(let content):
                DrawingContentView(content: content) { hasDrawing in
                    viewModel.setCanProceed(hasDrawing)
                }
                
            case .theory(let content):
                TheoryContentView(
                    content: content,
                    selectedAnswers: $viewModel.selectedAnswers,
                    hasSubmittedAnswer: viewModel.hasSubmittedAnswer,
                    onAnswerSelected: { answerId in
                        viewModel.selectAnswer(answerId)
                    }
                )
                
            case .challenge(let content):
                ChallengeContentView(content: content) { hasContent in
                    viewModel.setCanProceed(hasContent)
                }
            }
        }
    }
    
    // MARK: - Bottom Action Area
    private var bottomActionArea: some View {
        VStack(spacing: 12) {
            // Hint button (when struggling)
            if viewModel.canShowHint && !viewModel.hasSubmittedAnswer {
                Button(action: { viewModel.showHint() }) {
                    HStack {
                        Image(systemName: "lightbulb")
                        Text("Need a hint?")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(20)
                }
            }
            
            // Main action button (Duolingo style)
            Button(action: {
                Task {
                    await HapticManager.shared.impact(.medium)
                    viewModel.handleMainAction()
                }
            }) {
                Text(viewModel.mainActionTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(viewModel.canProceed ?
                                LinearGradient(colors: [.green, .blue], startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [Color(.systemGray4)], startPoint: .leading, endPoint: .trailing)
                            )
                    )
                    .shadow(color: viewModel.canProceed ? .green.opacity(0.3) : .clear, radius: 8, y: 4)
            }
            .disabled(!viewModel.canProceed)
            .scaleEffect(viewModel.canProceed ? 1.0 : 0.95)
            .animation(.spring(response: 0.3), value: viewModel.canProceed)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Progress Bar
struct ProgressBarView: View {
    let progress: Double
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Step \(currentStep) of \(totalSteps)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 12)
                        .animation(.spring(response: 0.6), value: progress)
                }
            }
            .frame(height: 12)
        }
    }
}

// MARK: - Introduction Content
struct IntroductionContentView: View {
    let content: IntroContent
    let onReady: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Hero icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "paintbrush.pointed.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // Bullet points with animations
            VStack(spacing: 16) {
                ForEach(Array(content.bulletPoints.enumerated()), id: \.offset) { index, point in
                    HStack(alignment: .top, spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.2))
                                .frame(width: 28, height: 28)
                            
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        
                        Text(point)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                }
            }
        }
        .onAppear {
            // Auto-enable continue after a moment
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onReady()
            }
        }
    }
}

// MARK: - Drawing Content (FIXED CANVAS)
struct DrawingContentView: View {
    let content: DrawingContent
    let onDrawingChanged: (Bool) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Instructions card
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "hand.draw")
                        .foregroundColor(.blue)
                    Text("Drawing Exercise")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Spacer()
                }
                
                Text("Use your Apple Pencil or finger to draw on the white canvas below. Your strokes will appear in black.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            
            // Fixed drawing canvas
            PerfectDrawingCanvas(onDrawingChanged: onDrawingChanged)
                .frame(height: 280)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }
}

// MARK: - Perfect Drawing Canvas (FULLY FIXED)
struct PerfectDrawingCanvas: View {
    @State private var canvasView = PKCanvasView()
    let onDrawingChanged: (Bool) -> Void
    
    var body: some View {
        PerfectCanvasRepresentable(
            canvasView: $canvasView,
            onDrawingChanged: onDrawingChanged
        )
    }
}

struct PerfectCanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    let onDrawingChanged: (Bool) -> Void
    
    func makeUIView(context: Context) -> PKCanvasView {
        // FIXED: Perfect canvas setup
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = UIColor.white // Pure white
        canvasView.isOpaque = true // Prevents color changes
        canvasView.delegate = context.coordinator
        
        // FIXED: Set perfect black tool
        canvasView.tool = PKInkingTool(.pen, color: UIColor.black, width: 3.0)
        
        // FIXED: Disable interface style changes
        canvasView.overrideUserInterfaceStyle = .light
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // FIXED: Maintain white background on all updates
        uiView.backgroundColor = UIColor.white
        uiView.isOpaque = true
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onDrawingChanged: onDrawingChanged)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        let onDrawingChanged: (Bool) -> Void
        
        init(onDrawingChanged: @escaping (Bool) -> Void) {
            self.onDrawingChanged = onDrawingChanged
        }
        
        func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
            // FIXED: Maintain white background during drawing
            canvasView.backgroundColor = UIColor.white
        }
        
        func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
            // FIXED: Maintain white background after drawing
            canvasView.backgroundColor = UIColor.white
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // FIXED: Maintain white background on changes
            canvasView.backgroundColor = UIColor.white
            let hasDrawing = !canvasView.drawing.strokes.isEmpty
            onDrawingChanged(hasDrawing)
        }
    }
}

// MARK: - Theory Content (FORGIVING WITH FEEDBACK)
struct TheoryContentView: View {
    let content: TheoryContent
    @Binding var selectedAnswers: Set<String>
    let hasSubmittedAnswer: Bool
    let onAnswerSelected: (String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Question card
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(.purple)
                    Text("Question")
                        .font(.headline)
                        .foregroundColor(.purple)
                    Spacer()
                }
                
                Text(content.question)
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(12)
            
            // Answer options
            VStack(spacing: 12) {
                ForEach(content.options) { option in
                    TheoryOptionButton(
                        option: option,
                        isSelected: selectedAnswers.contains(option.id),
                        hasSubmitted: hasSubmittedAnswer,
                        isCorrect: content.correctAnswers.contains(option.id),
                        onTap: { onAnswerSelected(option.id) }
                    )
                }
            }
            
            // Show explanation after submission
            if hasSubmittedAnswer {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.orange)
                        Text("Explanation")
                            .font(.headline)
                            .foregroundColor(.orange)
                        Spacer()
                    }
                    
                    Text(content.explanation)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

// MARK: - Theory Option Button
struct TheoryOptionButton: View {
    let option: TheoryContent.AnswerOption
    let isSelected: Bool
    let hasSubmitted: Bool
    let isCorrect: Bool
    let onTap: () -> Void
    
    var backgroundColor: Color {
        if !hasSubmitted {
            return isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6)
        }
        
        if isCorrect {
            return Color.green.opacity(0.2)
        } else if isSelected {
            return Color.red.opacity(0.2)
        }
        return Color(.systemGray6)
    }
    
    var borderColor: Color {
        if !hasSubmitted {
            return isSelected ? .blue : .clear
        }
        
        if isCorrect {
            return .green
        } else if isSelected {
            return .red
        }
        return .clear
    }
    
    var statusIcon: String? {
        if !hasSubmitted { return nil }
        
        if isCorrect {
            return "checkmark.circle.fill"
        } else if isSelected {
            return "xmark.circle.fill"
        }
        return nil
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Selection indicator
                Image(systemName: isSelected ? "circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title3)
                
                // Option text
                Text(option.text)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Status icon (after submission)
                if let icon = statusIcon {
                    Image(systemName: icon)
                        .foregroundColor(isCorrect ? .green : .red)
                        .font(.title3)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(hasSubmitted)
        .scaleEffect(isSelected && !hasSubmitted ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Challenge Content
struct ChallengeContentView: View {
    let content: ChallengeContent
    let onContentChanged: (Bool) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Challenge prompt
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                    Text("Creative Challenge")
                        .font(.headline)
                        .foregroundColor(.orange)
                    Spacer()
                }
                
                Text(content.prompt)
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [.orange.opacity(0.1), .pink.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            
            // Drawing area
            PerfectDrawingCanvas(onDrawingChanged: onContentChanged)
                .frame(height: 240)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        }
    }
}

// MARK: - Enhanced ViewModel (FORGIVING + SMART)
@MainActor
final class LessonPlayerViewModel: ObservableObject {
    let lesson: Lesson
    
    @Published var currentStepIndex = 0
    @Published var progress: Double = 0
    @Published var canProceed = false
    @Published var showSuccessOverlay = false
    @Published var showLessonComplete = false
    @Published var selectedAnswers: Set<String> = []
    @Published var shouldDismiss = false
    @Published var hasSubmittedAnswer = false
    @Published var heartsRemaining = 3
    @Published var canShowHint = false
    @Published var lastAnswerCorrect = true
    @Published var currentExplanation = ""
    @Published var hasLeveledUp = false
    
    private var stepXPEarnedValues: [Int] = []
    private var attemptCounts: [String: Int] = [:]
    private let progressService: ProgressServiceProtocol
    
    var currentStep: LessonStep? {
        guard currentStepIndex < lesson.steps.count else { return nil }
        return lesson.steps[currentStepIndex]
    }
    
    var mainActionTitle: String {
        if hasSubmittedAnswer && needsValidation(currentStep) {
            return "Continue"
        } else if currentStepIndex == lesson.steps.count - 1 {
            return "Complete Lesson"
        } else {
            return needsValidation(currentStep) ? "Check Answer" : "Continue"
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
        updateProgress()
    }
    
    // MARK: - Main Action (FORGIVING DUOLINGO STYLE)
    func handleMainAction() {
        guard let step = currentStep else { return }
        
        // Theory questions: submit answer first, then continue
        if needsValidation(step) && !hasSubmittedAnswer {
            submitTheoryAnswer(step)
            return
        }
        
        // All other cases: proceed to next step
        proceedWithStep(step)
    }
    
    private func submitTheoryAnswer(_ step: LessonStep) {
        hasSubmittedAnswer = true
        lastAnswerCorrect = validateStep(step)
        
        // Set explanation
        if case .theory(let content) = step.content {
            currentExplanation = content.explanation
        }
        
        // Award XP (full for correct, partial for incorrect)
        let xpToAward = lastAnswerCorrect ? step.xpValue : max(step.xpValue / 2, 10)
        stepXPEarnedValues.append(xpToAward)
        
        // Lose heart for wrong answer (but still progress!)
        if !lastAnswerCorrect {
            heartsRemaining = max(0, heartsRemaining - 1)
        }
        
        // Show feedback overlay
        withAnimation(.spring(response: 0.4)) {
            showSuccessOverlay = true
        }
    }
    
    func proceedAfterFeedback() {
        withAnimation(.spring(response: 0.3)) {
            showSuccessOverlay = false
        }
        
        // Short delay then proceed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if self.currentStepIndex == self.lesson.steps.count - 1 {
                self.completeLesson()
            } else {
                self.proceedToNext()
            }
        }
    }
    
    private func proceedWithStep(_ step: LessonStep) {
        // For non-theory steps, award full XP
        if !needsValidation(step) {
            stepXPEarnedValues.append(step.xpValue)
        }
        
        // Save progress
        Task {
            do {
                try await progressService.updateLessonProgress(
                    lessonId: lesson.id,
                    stepId: step.id,
                    score: lastAnswerCorrect ? 1.0 : 0.7,
                    timeSpent: 15.0
                )
            } catch {
                print("❌ Failed to save step progress: \(error)")
            }
        }
        
        // Proceed immediately for non-theory steps
        if currentStepIndex == lesson.steps.count - 1 {
            completeLesson()
        } else {
            proceedToNext()
        }
    }
    
    private func completeLesson() {
        Task {
            do {
                try await progressService.completeLesson(lesson.id)
                print("✅ Lesson completed with \(totalXPEarned) XP!")
                
                await MainActor.run {
                    withAnimation(.spring(response: 0.5)) {
                        showLessonComplete = true
                    }
                }
            } catch {
                print("❌ Failed to complete lesson: \(error)")
                shouldDismiss = true
            }
        }
    }
    
    func completeLessonFlow() {
        shouldDismiss = true
    }
    
    private func proceedToNext() {
        currentStepIndex += 1
        resetStepState()
        updateProgress()
    }
    
    func selectAnswer(_ answerId: String) {
        guard !hasSubmittedAnswer else { return }
        selectedAnswers = [answerId]
        setCanProceed(true)
        
        // Track attempts for hint system
        let stepId = currentStep?.id ?? ""
        attemptCounts[stepId, default: 0] += 1
        canShowHint = attemptCounts[stepId, default: 0] >= 2
    }
    
    func setCanProceed(_ canProceed: Bool) {
        self.canProceed = canProceed
    }
    
    func showHint() {
        // Show hint logic here
        canShowHint = false
    }
    
    private func needsValidation(_ step: LessonStep?) -> Bool {
        guard let step = step else { return false }
        switch step.content {
        case .theory: return true
        default: return false
        }
    }
    
    private func validateStep(_ step: LessonStep) -> Bool {
        switch step.content {
        case .theory(let content):
            return Set(content.correctAnswers) == selectedAnswers
        default:
            return true
        }
    }
    
    private func resetStepState() {
        canProceed = false
        selectedAnswers.removeAll()
        hasSubmittedAnswer = false
        canShowHint = false
    }
    
    private func updateProgress() {
        let totalSteps = max(lesson.steps.count, 1)
        withAnimation(.spring(response: 0.5)) {
            progress = Double(currentStepIndex + 1) / Double(totalSteps)
        }
    }
}

// MARK: - Success Feedback Overlay
struct SuccessFeedbackOverlay: View {
    let xpGained: Int
    let isCorrect: Bool
    let explanation: String
    let onContinue: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture(perform: onContinue)
            
            VStack(spacing: 24) {
                // Icon and feedback
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(isCorrect ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .scaleEffect(isAnimating ? 1.1 : 0.9)
                        
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "lightbulb.fill")
                            .font(.system(size: 40))
                            .foregroundColor(isCorrect ? .green : .orange)
                    }
                    
                    Text(isCorrect ? "Perfect!" : "Keep Learning!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(isCorrect ? "Great job! You're making excellent progress." : "That's not quite right, but you're still learning!")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                
                // XP gained
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("+\(xpGained) XP")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.3))
                .cornerRadius(20)
                
                // Continue button
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(LinearGradient(colors: [.green, .blue], startPoint: .leading, endPoint: .trailing))
                        )
                }
                .padding(.horizontal, 40)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(.horizontal, 40)
            .scaleEffect(isAnimating ? 1.0 : 0.8)
            .opacity(isAnimating ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Lesson Complete Celebration
struct LessonCompleteCelebration: View {
    let lesson: Lesson
    let totalXP: Int
    let newLevel: Bool
    let onDismiss: () -> Void
    
    @State private var isAnimating = false
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Celebration animation
                ZStack {
                    // Confetti
                    if showConfetti {
                        ForEach(0..<20, id: \.self) { _ in
                            ConfettiPiece()
                        }
                    }
                    
                    // Main celebration
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [.yellow.opacity(0.8), .orange.opacity(0.4), .clear],
                                        center: .center,
                                        startRadius: 30,
                                        endRadius: 100
                                    )
                                )
                                .frame(width: 150, height: 150)
                                .scaleEffect(isAnimating ? 1.2 : 0.8)
                            
                            Image(systemName: "star.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.yellow)
                                .rotationEffect(.degrees(isAnimating ? 0 : -20))
                        }
                        
                        Text("Lesson Complete!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("+\(totalXP) XP Earned")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.yellow)
                        
                        if newLevel {
                            Text("🎉 Level Up! 🎉")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        
                        Text("Outstanding work! You're becoming a skilled artist.")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Continue button
                Button(action: onDismiss) {
                    Text("Continue Learning")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(LinearGradient(colors: [.green, .blue], startPoint: .leading, endPoint: .trailing))
                        )
                        .shadow(color: .green.opacity(0.5), radius: 10, y: 5)
                }
                .padding(.horizontal, 60)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                isAnimating = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showConfetti = true
            }
        }
    }
}

// MARK: - Confetti Piece
struct ConfettiPiece: View {
    @State private var position = CGPoint.zero
    @State private var rotation = 0.0
    
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(colors.randomElement()!)
            .frame(width: 8, height: 8)
            .rotationEffect(.degrees(rotation))
            .position(position)
            .onAppear {
                let angle = Double.random(in: 0...(2 * .pi))
                let distance = CGFloat.random(in: 100...200)
                
                withAnimation(.easeOut(duration: 2.0)) {
                    position = CGPoint(
                        x: cos(angle) * distance,
                        y: sin(angle) * distance - 100
                    )
                    rotation = Double.random(in: -360...360)
                }
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
