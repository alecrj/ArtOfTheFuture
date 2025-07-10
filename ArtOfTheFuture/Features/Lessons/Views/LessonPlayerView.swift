// MARK: - Fixed Lesson Player View
// File: ArtOfTheFuture/Features/Lessons/Views/LessonPlayerView.swift

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
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [lesson.category.categoryColor.opacity(0.05), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                playerHeader
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Current step content
                        if let currentStep = viewModel.currentStep {
                            StepContentView(
                                step: currentStep,
                                viewModel: viewModel
                            )
                            .padding()
                        } else {
                            // Fallback content
                            VStack(spacing: 20) {
                                Image(systemName: "book.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(lesson.category.categoryColor)
                                
                                Text("Loading lesson...")
                                    .font(.headline)
                                
                                Text(lesson.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                        }
                        
                        // Feedback
                        if viewModel.showFeedback {
                            feedbackView
                                .padding(.horizontal)
                        }
                    }
                }
                
                // Controls
                playerControls
            }
            
            // Success overlay
            if viewModel.showSuccess {
                SuccessOverlay(
                    xpEarned: viewModel.xpEarned,
                    onContinue: {
                        viewModel.showSuccess = false
                        if viewModel.isComplete {
                            dismiss()
                        } else {
                            viewModel.nextStep()
                        }
                    }
                )
            }
        }
        .navigationBarHidden(true)
        .alert("Exit Lesson?", isPresented: $showingExitAlert) {
            Button("Exit", role: .destructive) {
                Task {
                    await viewModel.saveProgress()
                    dismiss()
                }
            }
            Button("Continue", role: .cancel) { }
        } message: {
            Text("Your progress will be saved")
        }
        .task {
            await viewModel.loadProgress()
        }
    }
    
    // MARK: - Header
    private var playerHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: { showingExitAlert = true }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text(lesson.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                // Lives display
                HeartsView(lives: viewModel.lives, maxLives: 3)
            }
            
            // Progress
            ProgressView(value: viewModel.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: lesson.category.categoryColor))
            
            HStack {
                Text("Step \(viewModel.currentStepIndex + 1) of \(max(lesson.steps.count, 1))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("+\(viewModel.currentStep?.xpValue ?? 0) XP")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Feedback
    private var feedbackView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: viewModel.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(viewModel.isCorrect ? .green : .red)
                
                VStack(alignment: .leading) {
                    Text(viewModel.isCorrect ? "Excellent!" : "Not quite")
                        .font(.headline)
                    
                    if !viewModel.feedbackMessage.isEmpty {
                        Text(viewModel.feedbackMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            if !viewModel.isCorrect && viewModel.lives > 0 {
                Button("Try Again") {
                    viewModel.tryAgain()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(viewModel.isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
        )
    }
    
    // MARK: - Controls
    private var playerControls: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                if viewModel.currentStepIndex > 0 {
                    Button(action: viewModel.previousStep) {
                        Label("Previous", systemImage: "chevron.left")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                    }
                }
                
                Button(action: viewModel.handleMainAction) {
                    HStack {
                        Text(viewModel.mainActionTitle)
                        if viewModel.canContinue {
                            Image(systemName: "arrow.right")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.canContinue ? lesson.category.categoryColor : Color(.systemGray4))
                    .foregroundColor(viewModel.canContinue ? .white : .secondary)
                    .cornerRadius(12)
                }
                .disabled(!viewModel.canContinue && !viewModel.showFeedback)
            }
            
            // Hints
            if !(viewModel.currentStep?.hints.isEmpty ?? true) {
                Button(action: viewModel.showHint) {
                    Label("Hint", systemImage: "lightbulb")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

// MARK: - Step Content View
struct StepContentView: View {
    let step: LessonStep
    @ObservedObject var viewModel: LessonPlayerViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Title and instruction
            VStack(spacing: 8) {
                Text(step.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(step.instruction)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Content based on step type
            stepContentView
            
            // Hints
            if viewModel.showingHint && !step.hints.isEmpty {
                HintView(hints: step.hints)
            }
        }
    }
    
    @ViewBuilder
    private var stepContentView: some View {
        switch step.content {
        case .introduction(let content):
            IntroductionView(content: content)
            
        case .drawing(let content):
            DrawingExerciseView(
                content: content,
                onDrawingChanged: { drawing in
                    viewModel.updateDrawing(drawing)
                }
            )
            
        case .theory(let content):
            TheoryExerciseView(
                content: content,
                selectedAnswers: $viewModel.selectedAnswers
            )
            
        case .challenge(let content):
            ChallengeExerciseView(
                content: content,
                onDrawingChanged: { drawing in
                    viewModel.updateDrawing(drawing)
                }
            )
        }
    }
}

// MARK: - Content Type Views
struct IntroductionView: View {
    let content: IntroContent
    
    var body: some View {
        VStack(spacing: 20) {
            // Main visual - use SF Symbols instead of missing images
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 200)
                
                VStack(spacing: 12) {
                    Image(systemName: "paintbrush.pointed.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text("Let's Learn!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            // Bullet points
            if !content.bulletPoints.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(content.bulletPoints, id: \.self) { point in
                        HStack(alignment: .top) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title3)
                            Text(point)
                                .font(.subheadline)
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
}

struct DrawingExerciseView: View {
    let content: DrawingContent
    let onDrawingChanged: (PKDrawing) -> Void
    @State private var canvasView = PKCanvasView()
    @State private var currentTool: DrawingTool = .pen
    @State private var showGuidelines = true
    
    var body: some View {
        VStack(spacing: 16) {
            // Canvas
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                
                // Guidelines overlay
                if showGuidelines && content.guidelines != nil {
                    GuidelinesOverlay(guidelines: content.guidelines ?? [])
                }
                
                // Canvas
                CanvasView(
                    canvasView: $canvasView,
                    currentTool: $currentTool,
                    currentColor: .constant(.black),
                    currentWidth: .constant(3.0)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .onChange(of: canvasView.drawing) { _ in
                    onDrawingChanged(canvasView.drawing)
                }
            }
            .frame(width: content.canvasSize.width, height: content.canvasSize.height)
            
            // Tools
            HStack(spacing: 20) {
                ForEach(content.toolsAllowed, id: \.self) { tool in
                    LessonToolButton(
                        tool: tool,
                        isSelected: currentTool == tool.toDrawingTool(),
                        action: { currentTool = tool.toDrawingTool() }
                    )
                }
                
                Spacer()
                
                Button(action: {
                    canvasView.drawing = PKDrawing()
                    onDrawingChanged(PKDrawing())
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .frame(width: 44, height: 44)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
                
                Button(action: { showGuidelines.toggle() }) {
                    Image(systemName: showGuidelines ? "eye.fill" : "eye.slash")
                        .foregroundColor(.blue)
                        .frame(width: 44, height: 44)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct TheoryExerciseView: View {
    let content: TheoryContent
    @Binding var selectedAnswers: Set<String>
    
    var body: some View {
        VStack(spacing: 20) {
            // Visual aid placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(height: 150)
                
                VStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("Theory")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(content.question)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                ForEach(content.options) { option in
                    AnswerOptionView(
                        option: option,
                        isSelected: selectedAnswers.contains(option.id),
                        allowsMultiple: content.answerType == .multipleChoice,
                        action: {
                            if content.answerType == .singleChoice {
                                selectedAnswers = [option.id]
                            } else {
                                if selectedAnswers.contains(option.id) {
                                    selectedAnswers.remove(option.id)
                                } else {
                                    selectedAnswers.insert(option.id)
                                }
                            }
                        }
                    )
                }
            }
        }
    }
}

struct ChallengeExerciseView: View {
    let content: ChallengeContent
    let onDrawingChanged: (PKDrawing) -> Void
    @State private var canvasView = PKCanvasView()
    
    var body: some View {
        VStack(spacing: 16) {
            Text(content.prompt)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            
            // Drawing canvas
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                
                CanvasView(
                    canvasView: $canvasView,
                    currentTool: .constant(.pen),
                    currentColor: .constant(.black),
                    currentWidth: .constant(3.0)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .onChange(of: canvasView.drawing) { _ in
                    onDrawingChanged(canvasView.drawing)
                }
            }
            .frame(height: 300)
        }
    }
}

// MARK: - Supporting Views
struct HeartsView: View {
    let lives: Int
    let maxLives: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<maxLives, id: \.self) { index in
                Image(systemName: index < lives ? "heart.fill" : "heart")
                    .foregroundColor(index < lives ? .red : .gray)
                    .font(.title3)
            }
        }
    }
}

struct HintView: View {
    let hints: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.orange)
                Text("Hints")
                    .fontWeight(.medium)
            }
            
            ForEach(hints, id: \.self) { hint in
                Text("• \(hint)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SuccessOverlay: View {
    let xpEarned: Int
    let onContinue: () -> Void
    @State private var scale: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Image(systemName: "star.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                    .scaleEffect(scale)
                
                Text("Excellent!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("+\(xpEarned) XP")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.yellow)
                
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(25)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6)) {
                scale = 1.0
            }
            Task {
                await HapticManager.shared.notification(.success)
            }
        }
    }
}

struct GuidelinesOverlay: View {
    let guidelines: [DrawingContent.Guideline]
    
    var body: some View {
        Canvas { context, size in
            for guideline in guidelines {
                drawGuideline(guideline, in: context, size: size)
            }
        }
    }
    
    private func drawGuideline(_ guideline: DrawingContent.Guideline, in context: GraphicsContext, size: CGSize) {
        let color = Color.blue.opacity(0.5)
        var path = Path()
        
        switch guideline.type {
        case .line:
            if guideline.path.count >= 2 {
                path.move(to: guideline.path[0])
                path.addLine(to: guideline.path[1])
            }
        case .circle:
            if guideline.path.count >= 2 {
                let center = guideline.path[0]
                let radius = distance(from: center, to: guideline.path[1])
                path.addEllipse(in: CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: radius * 2,
                    height: radius * 2
                ))
            }
        case .rectangle:
            if guideline.path.count >= 2 {
                let rect = CGRect(
                    x: min(guideline.path[0].x, guideline.path[1].x),
                    y: min(guideline.path[0].y, guideline.path[1].y),
                    width: abs(guideline.path[1].x - guideline.path[0].x),
                    height: abs(guideline.path[1].y - guideline.path[0].y)
                )
                path.addRect(rect)
            }
        case .curve:
            if !guideline.path.isEmpty {
                path.move(to: guideline.path[0])
                for point in guideline.path.dropFirst() {
                    path.addLine(to: point)
                }
            }
        }
        
        context.stroke(
            path,
            with: .color(color),
            style: StrokeStyle(
                lineWidth: 2,
                dash: [8, 4]
            )
        )
    }
    
    private func distance(from p1: CGPoint, to p2: CGPoint) -> CGFloat {
        sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2))
    }
}

struct AnswerOptionView: View {
    let option: TheoryContent.AnswerOption
    let isSelected: Bool
    let allowsMultiple: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ?
                    (allowsMultiple ? "checkmark.square.fill" : "circle.fill") :
                    (allowsMultiple ? "square" : "circle"))
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Text(option.text)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct LessonToolButton: View {
    let tool: LessonDrawingTool
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tool.icon)
                    .font(.title3)
                Text(tool.rawValue)
                    .font(.caption2)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .frame(width: 50, height: 50)
            .background(isSelected ? Color.blue : Color(.systemGray5))
            .cornerRadius(12)
        }
    }
}

// MARK: - View Model
@MainActor
final class LessonPlayerViewModel: ObservableObject {
    let lesson: Lesson
    private let progressService = ProgressService.shared
    
    @Published var currentStepIndex = 0
    @Published var lives = 3
    @Published var progress: Double = 0
    @Published var showFeedback = false
    @Published var isCorrect = false
    @Published var feedbackMessage = ""
    @Published var canContinue = false
    @Published var showingHint = false
    @Published var showSuccess = false
    @Published var isComplete = false
    @Published var xpEarned = 0
    
    // Exercise state
    @Published var selectedAnswers: Set<String> = []
    @Published var currentDrawing: PKDrawing?
    
    var currentStep: LessonStep? {
        guard currentStepIndex < lesson.steps.count else { return nil }
        return lesson.steps[currentStepIndex]
    }
    
    var mainActionTitle: String {
        if showFeedback {
            return isCorrect ? "Continue" : "Got it"
        } else if canContinue {
            return "Check"
        } else {
            switch currentStep?.content {
            case .introduction:
                return "Continue"
            default:
                return "Submit"
            }
        }
    }
    
    init(lesson: Lesson) {
        self.lesson = lesson
        updateCanContinue()
        updateProgress()
    }
    
    // MARK: - Progress Management
    func loadProgress() async {
        // For now, start from beginning
        currentStepIndex = 0
        updateProgress()
        updateCanContinue()
    }
    
    func saveProgress() async {
        // Progress saving implementation
    }
    
    // MARK: - Actions
    func handleMainAction() {
        if showFeedback {
            if isCorrect {
                completeStep()
            } else {
                tryAgain()
            }
        } else {
            checkAnswer()
        }
    }
    
    func checkAnswer() {
        guard let step = currentStep else { return }
        
        let result = validateAnswer(for: step)
        isCorrect = result.isCorrect
        feedbackMessage = result.message
        
        showFeedback = true
        
        if !isCorrect {
            lives -= 1
            if lives == 0 {
                feedbackMessage = "Out of attempts. Let's move on!"
                isCorrect = true // Force progression
            }
        }
        
        Task {
            await HapticManager.shared.notification(isCorrect ? .success : .error)
        }
    }
    
    func completeStep() {
        guard let step = currentStep else { return }
        
        // Award XP
        if isCorrect {
            xpEarned += step.xpValue
        }
        
        // Check if lesson complete
        if currentStepIndex == lesson.steps.count - 1 {
            isComplete = true
            showSuccess = true
        } else {
            nextStep()
        }
    }
    
    func nextStep() {
        currentStepIndex = min(currentStepIndex + 1, lesson.steps.count - 1)
        resetStepState()
        updateProgress()
    }
    
    func previousStep() {
        currentStepIndex = max(currentStepIndex - 1, 0)
        resetStepState()
        updateProgress()
    }
    
    func tryAgain() {
        showFeedback = false
        resetStepState()
    }
    
    func showHint() {
        showingHint = true
    }
    
    func updateDrawing(_ drawing: PKDrawing) {
        currentDrawing = drawing
        updateCanContinue()
    }
    
    // MARK: - Private
    private func updateProgress() {
        let totalSteps = max(lesson.steps.count, 1)
        progress = Double(currentStepIndex + 1) / Double(totalSteps)
    }
    
    private func updateCanContinue() {
        guard let step = currentStep else {
            canContinue = true
            return
        }
        
        switch step.content {
        case .introduction:
            canContinue = true
        case .drawing:
            canContinue = currentDrawing?.strokes.isEmpty == false
        case .theory:
            canContinue = !selectedAnswers.isEmpty
        case .challenge:
            canContinue = currentDrawing?.strokes.isEmpty == false
        }
    }
    
    private func resetStepState() {
        showFeedback = false
        isCorrect = false
        feedbackMessage = ""
        showingHint = false
        selectedAnswers.removeAll()
        currentDrawing = nil
        updateCanContinue()
    }
    
    private func validateAnswer(for step: LessonStep) -> (isCorrect: Bool, message: String) {
        switch step.content {
        case .introduction:
            return (true, "")
            
        case .drawing:
            let hasDrawing = currentDrawing?.strokes.isEmpty == false
            return (hasDrawing, hasDrawing ? "Great drawing!" : "Please draw something")
            
        case .theory(let content):
            let correct = Set(content.correctAnswers)
            let isCorrect = selectedAnswers == correct
            return (isCorrect, isCorrect ? "Correct!" : content.explanation)
            
        case .challenge:
            let hasDrawing = currentDrawing?.strokes.isEmpty == false
            return (hasDrawing, hasDrawing ? "Creative work!" : "Give it a try!")
        }
    }
}

// MARK: - Tool Conversion Extension
extension LessonDrawingTool {
    func toDrawingTool() -> DrawingTool {
        switch self {
        case .pen: return .pen
        case .pencil: return .pencil
        case .marker: return .marker
        case .eraser: return .eraser
        }
    }
}
