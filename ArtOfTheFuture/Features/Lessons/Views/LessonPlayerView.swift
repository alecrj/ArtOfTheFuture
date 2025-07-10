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
        NavigationView {
            ZStack {
                // Background gradient like Duolingo
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    lessonHeader
                    
                    // Content
                    if let currentStep = viewModel.currentStep {
                        ScrollView {
                            VStack(spacing: 24) {
                                StepContentView(
                                    step: currentStep,
                                    viewModel: viewModel
                                )
                                .padding()
                            }
                        }
                    }
                    
                    // Bottom controls - Always visible like Duolingo
                    bottomControls
                        .background(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 5, y: -2)
                }
            }
            
            // Success celebration overlay
            if viewModel.showSuccess {
                SuccessOverlay(
                    title: viewModel.isLessonComplete ? "Lesson Complete!" : "Excellent!",
                    xpEarned: viewModel.stepXPEarned,
                    onContinue: {
                        viewModel.handleSuccessContinue()
                        if viewModel.isLessonComplete {
                            dismiss()
                        }
                    }
                )
                .zIndex(2)
            }
            
            // Feedback overlay for incorrect answers
            if viewModel.showFeedback && !viewModel.isCorrect {
                FeedbackOverlay(
                    isCorrect: false,
                    message: viewModel.feedbackMessage,
                    onTryAgain: {
                        viewModel.hideFeeback()
                    }
                )
                .zIndex(1)
            }
        }
        .navigationBarHidden(true)
        .alert("Exit Lesson?", isPresented: $showingExitAlert) {
            Button("Exit", role: .destructive) {
                dismiss()
            }
            Button("Continue", role: .cancel) { }
        } message: {
            Text("Your progress will be saved")
        }
    }
    
    // MARK: - Header
    private var lessonHeader: some View {
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
            
            // Progress bar - Duolingo style
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(lesson.category.categoryColor)
                        .frame(width: geometry.size.width * viewModel.progress, height: 8)
                        .animation(.spring(response: 0.6), value: viewModel.progress)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("Step \(viewModel.currentStepIndex + 1) of \(lesson.steps.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let xpValue = viewModel.currentStep?.xpValue {
                    Text("+\(xpValue) XP")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // MARK: - Bottom Controls (Duolingo Style - No Hints)
    private var bottomControls: some View {
        VStack(spacing: 0) {
            // Main action button area
            HStack(spacing: 16) {
                // Main action button - Duolingo style
                Button(action: viewModel.handleMainAction) {
                    Text(viewModel.mainActionTitle)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            Group {
                                if viewModel.canProceed {
                                    lesson.category.categoryColor
                                } else {
                                    Color(.systemGray4)
                                }
                            }
                        )
                        .cornerRadius(16)
                }
                .disabled(!viewModel.canProceed)
                .animation(.easeInOut(duration: 0.2), value: viewModel.canProceed)
            }
            .padding()
        }
    }
}

// MARK: - Step Content View (Simplified - No Hints)
struct StepContentView: View {
    let step: LessonStep
    @ObservedObject var viewModel: LessonPlayerViewModel
    
    var body: some View {
        VStack(spacing: 24) {
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
                    .lineLimit(nil)
            }
            
            // Content based on step type
            stepContentView
        }
    }
    
    @ViewBuilder
    private var stepContentView: some View {
        switch step.content {
        case .introduction(let content):
            IntroductionView(content: content, viewModel: viewModel)
            
        case .drawing(let content):
            DrawingExerciseView(
                content: content,
                viewModel: viewModel
            )
            
        case .theory(let content):
            TheoryExerciseView(
                content: content,
                viewModel: viewModel
            )
            
        case .challenge(let content):
            ChallengeExerciseView(
                content: content,
                viewModel: viewModel
            )
        }
    }
}

// MARK: - Content Views (Simplified - No Hints)
struct IntroductionView: View {
    let content: IntroContent
    @ObservedObject var viewModel: LessonPlayerViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Hero visual
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.8), .purple.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 200)
                
                VStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text("Let's Learn!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            // Key points - Clear and instructional
            if !content.bulletPoints.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
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
                .cornerRadius(16)
            }
        }
        .onAppear {
            // Introduction steps can proceed immediately
            viewModel.setCanProceed(true)
        }
    }
}

struct DrawingExerciseView: View {
    let content: DrawingContent
    @ObservedObject var viewModel: LessonPlayerViewModel
    @StateObject private var canvasController = CanvasController()
    
    var body: some View {
        VStack(spacing: 20) {
            // Canvas with guidelines
            ZStack {
                // White background for visibility
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
                
                // Guidelines overlay (if any)
                if let guidelines = content.guidelines {
                    GuidelinesOverlay(guidelines: guidelines)
                        .allowsHitTesting(false)
                }
                
                // Drawing canvas
                CanvasViewWrapper(controller: canvasController)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .onChange(of: canvasController.pkCanvasView.drawing) { oldValue, newValue in
                        viewModel.updateDrawing(newValue)
                    }
            }
            .frame(
                width: min(content.canvasSize.width, 350),
                height: min(content.canvasSize.height, 250)
            )
            
            // Drawing tools - Simple and clean
            HStack(spacing: 16) {
                ForEach(content.toolsAllowed, id: \.self) { tool in
                    LessonToolButton(
                        tool: tool,
                        isSelected: canvasController.activeTool == tool.toDrawingTool(),
                        action: {
                            canvasController.chooseTool(tool.toDrawingTool())
                        }
                    )
                }
                
                Spacer()
                
                // Clear button with encouraging icon
                Button(action: {
                    canvasController.clearAction()
                    viewModel.updateDrawing(PKDrawing())
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.orange)
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
    @ObservedObject var viewModel: LessonPlayerViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Question - More prominent and clear
            Text(content.question)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
            
            // Answer options - Clean and clear
            VStack(spacing: 12) {
                ForEach(content.options) { option in
                    AnswerOptionView(
                        option: option,
                        isSelected: viewModel.selectedAnswers.contains(option.id),
                        allowsMultiple: content.answerType == .multipleChoice,
                        action: {
                            viewModel.selectAnswer(option.id, allowsMultiple: content.answerType == .multipleChoice)
                        }
                    )
                }
            }
        }
    }
}

struct ChallengeExerciseView: View {
    let content: ChallengeContent
    @ObservedObject var viewModel: LessonPlayerViewModel
    @StateObject private var canvasController = CanvasController()
    
    var body: some View {
        VStack(spacing: 20) {
            // Challenge prompt - Exciting and motivating
            Text(content.prompt)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.orange.opacity(0.2), .pink.opacity(0.2)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
            
            // Drawing canvas
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
                
                CanvasViewWrapper(controller: canvasController)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .onChange(of: canvasController.pkCanvasView.drawing) { oldValue, newValue in
                        viewModel.updateDrawing(newValue)
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
                    .scaleEffect(index < lives ? 1.0 : 0.8)
                    .animation(.spring(response: 0.3), value: lives)
            }
        }
    }
}

struct SuccessOverlay: View {
    let title: String
    let xpEarned: Int
    let onContinue: () -> Void
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .opacity(opacity)
            
            VStack(spacing: 30) {
                // Success animation
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .scaleEffect(scale)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                        .scaleEffect(scale)
                }
                
                VStack(spacing: 16) {
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .scaleEffect(scale)
                    
                    Text("+\(xpEarned) XP")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)
                        .scaleEffect(scale)
                }
                
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(25)
                }
                .scaleEffect(scale)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 1.0
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                scale = 1.0
            }
            Task {
                await HapticManager.shared.notification(.success)
            }
        }
    }
}

struct FeedbackOverlay: View {
    let isCorrect: Bool
    let message: String
    let onTryAgain: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                Text("Not quite right")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if !message.isEmpty {
                    Text(message)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Button(action: onTryAgain) {
                    Text("Try Again")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(25)
                }
            }
            .padding()
        }
        .onAppear {
            Task {
                await HapticManager.shared.notification(.error)
            }
        }
    }
}

// MARK: - Enhanced ViewModel (Duolingo-style - No Hints)
@MainActor
final class LessonPlayerViewModel: ObservableObject {
    let lesson: Lesson
    
    @Published var currentStepIndex = 0
    @Published var lives = 3
    @Published var progress: Double = 0
    @Published var showSuccess = false
    @Published var showFeedback = false
    @Published var isCorrect = false
    @Published var feedbackMessage = ""
    @Published var canProceed = false
    
    // Exercise state
    @Published var selectedAnswers: Set<String> = []
    @Published var currentDrawing: PKDrawing = PKDrawing()
    
    private var totalXPEarned = 0
    
    var currentStep: LessonStep? {
        guard currentStepIndex < lesson.steps.count else { return nil }
        return lesson.steps[currentStepIndex]
    }
    
    var mainActionTitle: String {
        if canProceed {
            return currentStepIndex == lesson.steps.count - 1 ? "Complete" : "Continue"
        } else {
            switch currentStep?.content {
            case .introduction:
                return "Continue"
            case .drawing, .challenge:
                return "Submit Drawing"
            case .theory:
                return "Submit Answer"
            default:
                return "Continue"
            }
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
        checkInitialState()
    }
    
    // MARK: - Public Methods
    func handleMainAction() {
        guard let step = currentStep else { return }
        
        if canProceed {
            // Proceed to next step or complete
            if isCorrect || step.content.isIntroduction {
                // Award XP and show success
                totalXPEarned += step.xpValue
                showSuccessAndProceed()
            } else {
                proceedToNextStep()
            }
        } else {
            // Validate current answer
            validateCurrentAnswer()
        }
    }
    
    func selectAnswer(_ answerId: String, allowsMultiple: Bool) {
        if allowsMultiple {
            if selectedAnswers.contains(answerId) {
                selectedAnswers.remove(answerId)
            } else {
                selectedAnswers.insert(answerId)
            }
        } else {
            selectedAnswers = [answerId]
        }
        updateCanProceed()
    }
    
    func updateDrawing(_ drawing: PKDrawing) {
        currentDrawing = drawing
        updateCanProceed()
    }
    
    func setCanProceed(_ canProceed: Bool) {
        self.canProceed = canProceed
    }
    
    func hideFeeback() {
        withAnimation(.spring(response: 0.3)) {
            showFeedback = false
        }
        resetStepState()
    }
    
    func handleSuccessContinue() {
        withAnimation(.spring(response: 0.3)) {
            showSuccess = false
        }
        
        if !isLessonComplete {
            proceedToNextStep()
        }
    }
    
    // MARK: - Private Methods
    private func checkInitialState() {
        guard let step = currentStep else { return }
        
        // Introduction steps can proceed immediately
        if case .introduction = step.content {
            canProceed = true
        }
    }
    
    private func validateCurrentAnswer() {
        guard let step = currentStep else { return }
        
        let result = validateStep(step)
        isCorrect = result.isCorrect
        feedbackMessage = result.message
        
        if isCorrect {
            // Immediate success feedback
            setCanProceed(true)
            Task {
                await HapticManager.shared.notification(.success)
            }
        } else {
            // Show error feedback
            lives -= 1
            withAnimation(.spring(response: 0.3)) {
                showFeedback = true
            }
            Task {
                await HapticManager.shared.notification(.error)
            }
            
            // If out of lives, allow progression anyway
            if lives <= 0 {
                isCorrect = true
                setCanProceed(true)
            }
        }
    }
    
    private func validateStep(_ step: LessonStep) -> (isCorrect: Bool, message: String) {
        switch step.content {
        case .introduction:
            return (true, "")
            
        case .drawing:
            let hasDrawing = !currentDrawing.strokes.isEmpty
            return (hasDrawing, hasDrawing ? "Great work!" : "Try drawing something!")
            
        case .theory(let content):
            let correct = Set(content.correctAnswers)
            let isCorrect = selectedAnswers == correct
            return (isCorrect, isCorrect ? "Correct!" : content.explanation)
            
        case .challenge:
            let hasDrawing = !currentDrawing.strokes.isEmpty
            return (hasDrawing, hasDrawing ? "Creative solution!" : "Show us your creativity!")
        }
    }
    
    private func updateCanProceed() {
        guard let step = currentStep else { return }
        
        switch step.content {
        case .introduction:
            canProceed = true
        case .drawing, .challenge:
            canProceed = !currentDrawing.strokes.isEmpty
        case .theory:
            canProceed = !selectedAnswers.isEmpty
        }
    }
    
    private func showSuccessAndProceed() {
        withAnimation(.spring(response: 0.5)) {
            showSuccess = true
        }
    }
    
    private func proceedToNextStep() {
        if currentStepIndex < lesson.steps.count - 1 {
            currentStepIndex += 1
            resetStepState()
            updateProgress()
            checkInitialState()
        }
    }
    
    private func resetStepState() {
        selectedAnswers.removeAll()
        currentDrawing = PKDrawing()
        isCorrect = false
        feedbackMessage = ""
        canProceed = false
    }
    
    private func updateProgress() {
        let totalSteps = max(lesson.steps.count, 1)
        withAnimation(.spring(response: 0.6)) {
            progress = Double(currentStepIndex + 1) / Double(totalSteps)
        }
    }
}

// MARK: - Extensions
extension StepContent {
    var isIntroduction: Bool {
        if case .introduction = self {
            return true
        }
        return false
    }
}

// Supporting views continued...
struct AnswerOptionView: View {
    let option: TheoryContent.AnswerOption
    let isSelected: Bool
    let allowsMultiple: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ?
                    (allowsMultiple ? "checkmark.square.fill" : "circle.fill") :
                    (allowsMultiple ? "square" : "circle"))
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title3)
                
                Text(option.text)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
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
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(tool.rawValue)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white : .secondary)
            }
            .frame(width: 60, height: 60)
            .background(isSelected ? Color.blue : Color(.systemGray5))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// Add guidelines overlay and other supporting views...
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
        let color = Color(hex: guideline.color) ?? .blue
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
            with: .color(color.opacity(0.5)),
            style: StrokeStyle(
                lineWidth: guideline.width,
                dash: guideline.dashed ? [8, 4] : []
            )
        )
    }
    
    private func distance(from p1: CGPoint, to p2: CGPoint) -> CGFloat {
        sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2))
    }
}

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

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

#Preview {
    if let lesson = Curriculum.allLessons.first {
        LessonPlayerView(lesson: lesson)
    } else {
        Text("No lessons available")
    }
}
