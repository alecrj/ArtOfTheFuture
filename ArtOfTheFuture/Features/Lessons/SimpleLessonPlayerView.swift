// MARK: - Enhanced Simple Lesson Player (Building on existing file)
// File: ArtOfTheFuture/Features/Lessons/SimpleLessonPlayerView.swift
// REPLACE your existing SimpleLessonPlayerView.swift with this enhanced version

import SwiftUI
import PencilKit

struct SimpleLessonPlayerView: View {
    let lesson: Lesson // Now takes actual lesson data
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = EnhancedLessonViewModel()
    @State private var canvasView = PKCanvasView()
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(.systemBackground), Color.blue.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header (enhanced from your existing)
                    headerSection
                    
                    Spacer()
                    
                    // Main content area (enhanced from your existing)
                    mainContent
                    
                    // Canvas area (enhanced from your existing)
                    if viewModel.currentStep.needsDrawing {
                        drawingCanvas
                    }
                    
                    Spacer()
                    
                    // Controls (enhanced from your existing)
                    controlButtons
                }
                .padding()
                
                // Success overlay (enhanced from your existing)
                if showSuccess {
                    successOverlay
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.startLesson(lesson)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Header Section (Enhanced)
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Top bar
            HStack {
                Button("✕") {
                    dismiss()
                }
                .font(.title2)
                .padding()
                
                Spacer()
                
                // Lives/Hearts (NEW)
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Image(systemName: "heart.fill")
                            .foregroundColor(index < viewModel.lives ? .red : .gray)
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                // XP Display (NEW)
                Text("+\(viewModel.currentStep.xpReward) XP")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
            }
            
            // Lesson title
            Text(lesson.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Progress (enhanced from your existing)
            VStack(spacing: 8) {
                ProgressView(value: viewModel.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
                    .frame(height: 8)
                
                Text("Step \(viewModel.currentStepIndex + 1) of \(viewModel.totalSteps)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    // MARK: - Main Content (Enhanced)
    private var mainContent: some View {
        VStack(spacing: 30) {
            // Step icon (enhanced from your existing)
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                    .scaleEffect(viewModel.isActive ? 1.0 : 0.9)
                    .animation(.spring(response: 0.6), value: viewModel.isActive)
                
                Image(systemName: viewModel.currentStep.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            // Step text (enhanced from your existing)
            VStack(spacing: 16) {
                Text(viewModel.currentStep.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(viewModel.currentStep.instruction)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            
            // Objectives (NEW - only for intro steps)
            if viewModel.currentStep.type == .introduction && !viewModel.currentStep.objectives.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("You'll learn:")
                        .font(.headline)
                    
                    ForEach(viewModel.currentStep.objectives, id: \.self) { objective in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(objective)
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
    
    // MARK: - Drawing Canvas (Enhanced from your existing)
    private var drawingCanvas: some View {
        VStack(spacing: 16) {
            Text("Draw here:")
                .font(.headline)
            
            ZStack {
                // Canvas background
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .frame(height: 300)
                    .shadow(radius: 4)
                
                // Guidelines (NEW)
                if viewModel.showGuidelines {
                    GuidelineOverlay(step: viewModel.currentStep)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                // Drawing area - Enhanced from your simple version
                if viewModel.currentStep.isInteractive {
                    CanvasView(
                        canvasView: $canvasView,
                        currentTool: .constant(.pen),
                        currentColor: .constant(.black),
                        currentWidth: .constant(4.0)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .onChange(of: canvasView.drawing) { _ in
                        viewModel.validateDrawing(canvasView.drawing)
                    }
                } else {
                    // Simple tap-to-complete (like your original)
                    VStack {
                        Image(systemName: viewModel.currentStep.targetShape == "circle" ? "circle.dashed" : "square.dashed")
                            .font(.system(size: 80))
                            .foregroundColor(.blue.opacity(0.3))
                        
                        Text("Tap and drag to draw")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .onTapGesture {
                        handleSimpleDrawingComplete()
                    }
                }
            }
            
            // Drawing tools (NEW)
            if viewModel.currentStep.isInteractive {
                HStack(spacing: 20) {
                    Button(action: {
                        canvasView.undoManager?.undo()
                    }) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.title2)
                            .frame(width: 44, height: 44)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        canvasView.drawing = PKDrawing()
                        viewModel.resetDrawing()
                    }) {
                        Image(systemName: "trash")
                            .font(.title2)
                            .frame(width: 44, height: 44)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.toggleGuidelines()
                    }) {
                        Text(viewModel.showGuidelines ? "Hide Guide" : "Show Guide")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(viewModel.showGuidelines ? Color.blue : Color(.systemGray5))
                            .foregroundColor(viewModel.showGuidelines ? .white : .primary)
                            .cornerRadius(16)
                    }
                }
            }
        }
    }
    
    // MARK: - Control Buttons (Enhanced from your existing)
    private var controlButtons: some View {
        VStack(spacing: 12) {
            // Feedback area (NEW)
            if !viewModel.feedback.isEmpty {
                HStack {
                    Image(systemName: viewModel.feedbackIcon)
                        .foregroundColor(viewModel.feedbackColor)
                    Text(viewModel.feedback)
                        .font(.subheadline)
                        .foregroundColor(viewModel.feedbackColor)
                    Spacer()
                }
                .padding()
                .background(viewModel.feedbackColor.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Navigation buttons (enhanced from your existing)
            HStack(spacing: 16) {
                // Back button
                if viewModel.currentStepIndex > 0 {
                    Button(action: previousStep) {
                        Label("Previous", systemImage: "chevron.left")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                    }
                }
                
                // Continue button (enhanced from your existing)
                Button(action: handleContinue) {
                    HStack {
                        Text(viewModel.continueButtonText)
                        Image(systemName: viewModel.isLastStep ? "checkmark" : "chevron.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.canContinue ? Color.green : Color(.systemGray4))
                    .foregroundColor(viewModel.canContinue ? .white : .secondary)
                    .cornerRadius(12)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.canContinue)
                }
                .disabled(!viewModel.canContinue)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Success Overlay (Enhanced from your existing)
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Celebration animation (enhanced)
                ZStack {
                    ForEach(0..<6) { index in
                        Circle()
                            .fill(Color.random)
                            .frame(width: 16, height: 16)
                            .offset(
                                x: showSuccess ? CGFloat.random(in: -80...80) : 0,
                                y: showSuccess ? CGFloat.random(in: -80...80) : 0
                            )
                            .opacity(showSuccess ? 0 : 1)
                            .animation(
                                .easeOut(duration: 1.5).delay(Double(index) * 0.1),
                                value: showSuccess
                            )
                    }
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)
                        .scaleEffect(showSuccess ? 1.2 : 0.8)
                        .animation(.spring(response: 0.6), value: showSuccess)
                }
                
                VStack(spacing: 16) {
                    Text("🎉 Excellent!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(viewModel.successMessage)
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    Text("+\(viewModel.currentStep.xpReward) XP")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(20)
                }
                
                Button(action: {
                    showSuccess = false
                    nextStep()
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
            }
        }
        .onAppear {
            HapticManager.shared.notification(.success)
        }
    }
    
    // MARK: - Actions (Enhanced)
    private func handleContinue() {
        if viewModel.isLastStep {
            // Complete lesson
            dismiss()
        } else if viewModel.shouldCelebrate {
            showSuccess = true
        } else {
            nextStep()
        }
    }
    
    private func handleSimpleDrawingComplete() {
        // Simulate drawing completion (like your original)
        withAnimation(.spring()) {
            showSuccess = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showSuccess = false
            nextStep()
        }
    }
    
    private func nextStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            viewModel.nextStep()
        }
        
        HapticManager.shared.impact(.light)
    }
    
    private func previousStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            viewModel.previousStep()
        }
    }
}

// MARK: - Enhanced View Model
@MainActor
final class EnhancedLessonViewModel: ObservableObject {
    @Published var currentStepIndex = 0
    @Published var progress: Double = 0.0
    @Published var lives = 3
    @Published var isActive = false
    @Published var showGuidelines = true
    @Published var feedback = ""
    @Published var canContinue = false
    @Published var currentScore: Double = 0.0
    
    private var lesson: Lesson?
    private var steps: [EnhancedLessonStep] = []
    
    var totalSteps: Int { steps.count }
    var currentStep: EnhancedLessonStep {
        steps.isEmpty ? .placeholder : steps[min(currentStepIndex, steps.count - 1)]
    }
    var isLastStep: Bool { currentStepIndex >= steps.count - 1 }
    var shouldCelebrate: Bool { currentStep.needsDrawing && currentScore >= 0.7 }
    
    var continueButtonText: String {
        if isLastStep { return "Complete!" }
        else if currentStep.type == .introduction { return "Let's Go!" }
        else if currentStep.needsDrawing { return canContinue ? "Perfect!" : "Keep Drawing..." }
        else { return "Continue" }
    }
    
    var feedbackIcon: String {
        if currentScore >= 0.8 { return "checkmark.circle.fill" }
        else if currentScore >= 0.5 { return "exclamationmark.circle.fill" }
        else { return "info.circle.fill" }
    }
    
    var feedbackColor: Color {
        if currentScore >= 0.8 { return .green }
        else if currentScore >= 0.5 { return .orange }
        else { return .blue }
    }
    
    var successMessage: String {
        switch currentStep.targetShape {
        case "circle": return "You drew a perfect circle!"
        case "line": return "Excellent line control!"
        case "square": return "Great square technique!"
        default: return "Wonderful work!"
        }
    }
    
    func startLesson(_ lesson: Lesson) {
        self.lesson = lesson
        self.steps = generateSteps(for: lesson)
        self.currentStepIndex = 0
        updateProgress()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isActive = true
            if self.currentStep.type == .introduction {
                self.canContinue = true
            }
        }
    }
    
    func nextStep() {
        isActive = false
        currentStepIndex = min(currentStepIndex + 1, steps.count - 1)
        updateProgress()
        resetStepState()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isActive = true
            if self.currentStep.type == .introduction || self.currentStep.type == .demonstration {
                self.canContinue = true
            }
        }
    }
    
    func previousStep() {
        isActive = false
        currentStepIndex = max(currentStepIndex - 1, 0)
        updateProgress()
        resetStepState()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isActive = true
        }
    }
    
    func validateDrawing(_ drawing: PKDrawing) {
        let strokeCount = drawing.strokes.count
        let hasContent = strokeCount > 0
        
        if hasContent {
            let targetStrokes = currentStep.targetStrokeCount
            let score = min(1.0, Double(strokeCount) / Double(max(1, targetStrokes)))
            
            currentScore = score
            canContinue = score >= 0.3
            
            if score >= 0.8 {
                feedback = "Excellent! Perfect technique!"
            } else if score >= 0.5 {
                feedback = "Good! Keep refining."
            } else {
                feedback = "Nice start! Keep going."
            }
        } else {
            resetDrawing()
        }
    }
    
    func resetDrawing() {
        currentScore = 0.0
        canContinue = false
        feedback = ""
    }
    
    func toggleGuidelines() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showGuidelines.toggle()
        }
    }
    
    private func updateProgress() {
        progress = Double(currentStepIndex + 1) / Double(totalSteps)
    }
    
    private func resetStepState() {
        currentScore = 0.0
        feedback = ""
        canContinue = false
    }
    
    private func generateSteps(for lesson: Lesson) -> [EnhancedLessonStep] {
        switch lesson.category {
        case .basics:
            return [
                EnhancedLessonStep(
                    type: .introduction,
                    title: "Welcome to \(lesson.title)!",
                    instruction: "Let's learn the fundamentals of drawing.",
                    icon: "hand.wave.fill",
                    objectives: [
                        "Master basic shape drawing",
                        "Improve hand-eye coordination",
                        "Build drawing confidence"
                    ],
                    xpReward: 25
                ),
                EnhancedLessonStep(
                    type: .practice,
                    title: "Draw a Perfect Circle",
                    instruction: "Use smooth, confident strokes to draw a circle.",
                    icon: "circle",
                    needsDrawing: true,
                    isInteractive: true,
                    targetShape: "circle",
                    targetStrokeCount: 3,
                    xpReward: 50
                ),
                EnhancedLessonStep(
                    type: .assessment,
                    title: "Great Job!",
                    instruction: "You've completed the lesson. Keep practicing!",
                    icon: "checkmark.circle.fill",
                    xpReward: 25
                )
            ]
        default:
            return [
                EnhancedLessonStep(
                    type: .introduction,
                    title: lesson.title,
                    instruction: lesson.description,
                    icon: "pencil",
                    xpReward: lesson.xpReward
                )
            ]
        }
    }
}

// MARK: - Enhanced Lesson Step
struct EnhancedLessonStep {
    let type: StepType
    let title: String
    let instruction: String
    let icon: String
    let objectives: [String]
    let needsDrawing: Bool
    let isInteractive: Bool
    let targetShape: String
    let targetStrokeCount: Int
    let xpReward: Int
    
    enum StepType {
        case introduction, demonstration, practice, assessment
    }
    
    init(
        type: StepType,
        title: String,
        instruction: String,
        icon: String,
        objectives: [String] = [],
        needsDrawing: Bool = false,
        isInteractive: Bool = false,
        targetShape: String = "",
        targetStrokeCount: Int = 1,
        xpReward: Int = 25
    ) {
        self.type = type
        self.title = title
        self.instruction = instruction
        self.icon = icon
        self.objectives = objectives
        self.needsDrawing = needsDrawing
        self.isInteractive = isInteractive
        self.targetShape = targetShape
        self.targetStrokeCount = targetStrokeCount
        self.xpReward = xpReward
    }
    
    static let placeholder = EnhancedLessonStep(
        type: .introduction,
        title: "Loading...",
        instruction: "Please wait",
        icon: "circle"
    )
}

// MARK: - Guideline Overlay
struct GuidelineOverlay: View {
    let step: EnhancedLessonStep
    
    var body: some View {
        Canvas { context, size in
            switch step.targetShape {
            case "circle":
                drawCircleGuide(context: context, size: size)
            case "line":
                drawLineGuide(context: context, size: size)
            case "square":
                drawSquareGuide(context: context, size: size)
            default:
                break
            }
        }
    }
    
    private func drawCircleGuide(context: GraphicsContext, size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) / 3
        
        let path = Path { path in
            path.addEllipse(in: CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            ))
        }
        
        context.stroke(
            path,
            with: .color(.blue.opacity(0.4)),
            style: StrokeStyle(lineWidth: 2, dash: [8, 4])
        )
    }
    
    private func drawLineGuide(context: GraphicsContext, size: CGSize) {
        let path = Path { path in
            path.move(to: CGPoint(x: size.width * 0.2, y: size.height / 2))
            path.addLine(to: CGPoint(x: size.width * 0.8, y: size.height / 2))
        }
        
        context.stroke(
            path,
            with: .color(.blue.opacity(0.4)),
            style: StrokeStyle(lineWidth: 2, dash: [8, 4])
        )
    }
    
    private func drawSquareGuide(context: GraphicsContext, size: CGSize) {
        let sideLength = min(size.width, size.height) * 0.6
        let rect = CGRect(
            x: (size.width - sideLength) / 2,
            y: (size.height - sideLength) / 2,
            width: sideLength,
            height: sideLength
        )
        
        let path = Path { path in
            path.addRect(rect)
        }
        
        context.stroke(
            path,
            with: .color(.blue.opacity(0.4)),
            style: StrokeStyle(lineWidth: 2, dash: [8, 4])
        )
    }
}

// MARK: - Extension
extension Color {
    static var random: Color {
        Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}

#Preview {
    SimpleLessonPlayerView(lesson: MockDataService.shared.getMockLessons().first!)
}
