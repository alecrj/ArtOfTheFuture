// MARK: - Enhanced Lesson Player View
// File: ArtOfTheFuture/Features/Lessons/Views/LessonPlayerView.swift

import SwiftUI
import PencilKit

struct LessonPlayerView: View {
    let lesson: Lesson
    @StateObject private var viewModel: LessonPlayerViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(lesson: Lesson) {
        self.lesson = lesson
        self._viewModel = StateObject(wrappedValue: LessonPlayerViewModel(lesson: lesson))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Enhanced Header
                    headerView
                    
                    // Main Content Area
                    ScrollView {
                        VStack(spacing: 0) {
                            if let currentStep = viewModel.currentStep {
                                stepContentView(currentStep, geometry: geometry)
                            }
                        }
                    }
                    
                    // Enhanced Bottom Controls
                    bottomControlsView
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.startLesson()
        }
        .sheet(isPresented: $viewModel.showLessonComplete) {
            SimpleLessonCompleteView(
                lesson: lesson,
                totalXP: viewModel.totalXPEarned,
                onDismiss: { viewModel.completeLessonFlow() }
            )
        }
    }
    
    // MARK: - Enhanced Header
    private var headerView: some View {
        VStack(spacing: 16) {
            // Top bar with close and hearts
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Hearts/Lives
                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: index < viewModel.heartsRemaining ? "heart.fill" : "heart")
                            .foregroundColor(index < viewModel.heartsRemaining ? .red : .gray.opacity(0.3))
                            .font(.title3)
                    }
                }
            }
            
            // Enhanced Progress Bar
            EnhancedProgressBarView(
                progress: viewModel.progress,
                currentStep: viewModel.currentStepIndex + 1,
                totalSteps: lesson.steps.count,
                stepTitle: viewModel.currentStep?.title ?? ""
            )
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 16)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Enhanced Step Content
    @ViewBuilder
    private func stepContentView(_ step: LessonStep, geometry: GeometryProxy) -> some View {
        VStack(spacing: 24) {
            // Content based on type with enhanced presentations
            switch step.content {
            case .introduction(let content):
                EnhancedIntroductionView(
                    step: step,
                    content: content,
                    onReady: { viewModel.setCanProceed(true) }
                )
                
            case .drawing(let content):
                EnhancedDrawingView(
                    step: step,
                    content: content,
                    geometry: geometry,
                    onDrawingChanged: { hasDrawing in
                        viewModel.setCanProceed(hasDrawing)
                    }
                )
                
            case .theory(let content):
                EnhancedTheoryView(
                    step: step,
                    content: content,
                    selectedAnswers: $viewModel.selectedAnswers,
                    hasSubmittedAnswer: viewModel.hasSubmittedAnswer,
                    onAnswerSelected: { answerId in
                        viewModel.selectAnswer(answerId)
                    }
                )
                
            case .challenge(let content):
                EnhancedChallengeView(
                    step: step,
                    content: content,
                    onChallengeCompleted: { hasContent in
                        viewModel.setCanProceed(hasContent)
                    }
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
    
    // MARK: - Enhanced Bottom Controls
    private var bottomControlsView: some View {
        VStack(spacing: 16) {
            // Educational hint system (when struggling)
            if viewModel.showInstructionalHelp {
                InstructionalHelpView(
                    currentStep: viewModel.currentStep,
                    onDismiss: { viewModel.dismissInstructionalHelp() }
                )
            }
            
            // Main action button with enhanced states
            Button(action: { viewModel.handlePrimaryAction() }) {
                HStack {
                    if viewModel.isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    
                    Text(viewModel.primaryActionText)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    Group {
                        if viewModel.canProceed {
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            Color(.systemGray4)
                        }
                    }
                )
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: viewModel.canProceed ? .blue.opacity(0.3) : .clear, radius: 8, y: 4)
            }
            .disabled(!viewModel.canProceed || viewModel.isProcessing)
            .scaleEffect(viewModel.canProceed ? 1.0 : 0.96)
            .animation(.spring(response: 0.3), value: viewModel.canProceed)
            
            // Secondary help button
            if viewModel.canShowInstructionalHelp {
                Button(action: { viewModel.showInstructionalHelp.toggle() }) {
                    HStack {
                        Image(systemName: "questionmark.circle")
                        Text("Need guidance?")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Enhanced Progress Bar
struct EnhancedProgressBarView: View {
    let progress: Double
    let currentStep: Int
    let totalSteps: Int
    let stepTitle: String
    
    var body: some View {
        VStack(spacing: 12) {
            // Step info
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Step \(currentStep) of \(totalSteps)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(stepTitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            // Visual progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                        .frame(height: 8)
                    
                    // Progress fill with gradient
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Enhanced Introduction View
struct EnhancedIntroductionView: View {
    let step: LessonStep
    let content: IntroContent
    let onReady: () -> Void
    
    @State private var animateContent = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Lesson objective card
            LessonObjectiveCard(
                title: step.title,
                instruction: step.instruction,
                animated: animateContent
            )
            
            // Visual content
            if let imageName = content.displayImage {
                AsyncImage(url: URL(string: imageName)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                        .frame(height: 200)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        )
                }
                .frame(maxHeight: 300)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                .scaleEffect(animateContent ? 1.0 : 0.9)
                .opacity(animateContent ? 1.0 : 0.0)
            }
            
            // Key learning points
            LazyVStack(spacing: 12) {
                ForEach(Array(content.bulletPoints.enumerated()), id: \.offset) { index, point in
                    LearningPointCard(
                        point: point,
                        index: index,
                        animated: animateContent
                    )
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3)) {
                animateContent = true
            }
            
            // Auto-enable continue after content loads
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                onReady()
            }
        }
    }
}

// MARK: - Enhanced Drawing View
struct EnhancedDrawingView: View {
    let step: LessonStep
    let content: DrawingContent
    let geometry: GeometryProxy
    let onDrawingChanged: (Bool) -> Void
    
    @State private var canvasView = PKCanvasView()
    @State private var showDrawingTools = false
    @State private var currentTool: PKInkingTool = PKInkingTool(.pen, color: .black, width: 3)
    @State private var hasDrawnStrokes = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Drawing instruction card
            DrawingInstructionCard(
                title: step.title,
                instruction: step.instruction,
                tips: extractDrawingTips(from: step.instruction)
            )
            
            // Reference image if provided
            if let referenceImage = content.referenceImage {
                ReferenceImageView(imageName: referenceImage)
            }
            
            // Enhanced drawing canvas section
            VStack(spacing: 16) {
                // Canvas title
                HStack {
                    Text("Drawing Canvas")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    if hasDrawnStrokes {
                        HStack(spacing: 12) {
                            Button(action: undoLastStroke) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.uturn.backward")
                                    Text("Undo")
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            }
                            .disabled(canvasView.drawing.strokes.isEmpty)
                            
                            Button(action: clearCanvas) {
                                HStack(spacing: 4) {
                                    Image(systemName: "trash")
                                    Text("Clear")
                                }
                                .font(.subheadline)
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                // Main drawing canvas with fixed dimensions
                VStack {
                    DrawingCanvasView(
                        canvasView: canvasView,
                        canvasSize: content.canvasSize,
                        backgroundColor: content.backgroundColor,
                        guidelines: content.guidelines,
                        onStrokeAdded: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                hasDrawnStrokes = true
                            }
                            onDrawingChanged(true)
                        }
                    )
                }
                .frame(width: min(content.canvasSize.width, geometry.size.width - 48),
                       height: min(content.canvasSize.height, 300))
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 2)
                )
                
                // Drawing tools toggle
                Button(action: { showDrawingTools.toggle() }) {
                    HStack {
                        Image(systemName: showDrawingTools ? "paintbrush.fill" : "paintbrush")
                        Text(showDrawingTools ? "Hide Tools" : "Show Tools")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Drawing tools panel
                if showDrawingTools {
                    DrawingToolsPanel(
                        currentTool: $currentTool,
                        onToolChanged: { tool in
                            canvasView.tool = tool
                        }
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            
            // Encouraging feedback
            if hasDrawnStrokes {
                DrawingFeedbackCard(hasContent: hasDrawnStrokes)
                    .transition(.move(edge: .top).combined(with: .opacity))
            } else {
                // Gentle encouragement to start
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "hand.point.up")
                            .foregroundColor(.blue)
                        Text("Touch the canvas above to start drawing")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(8)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: hasDrawnStrokes)
        .animation(.easeInOut(duration: 0.3), value: showDrawingTools)
    }
    
    private func clearCanvas() {
        withAnimation(.easeInOut(duration: 0.2)) {
            canvasView.drawing = PKDrawing()
            hasDrawnStrokes = false
        }
        onDrawingChanged(false)
    }
    
    private func undoLastStroke() {
        if !canvasView.drawing.strokes.isEmpty {
            var strokes = canvasView.drawing.strokes
            strokes.removeLast()
            canvasView.drawing = PKDrawing(strokes: strokes)
            
            withAnimation(.easeInOut(duration: 0.2)) {
                hasDrawnStrokes = !strokes.isEmpty
            }
            onDrawingChanged(hasDrawnStrokes)
        }
    }
    
    private func extractDrawingTips(from instruction: String) -> [String] {
        // Dynamic tips based on lesson content
        if instruction.lowercased().contains("first") || instruction.lowercased().contains("marks") {
            return [
                "There's no wrong way to start - just begin!",
                "Light, relaxed movements work best",
                "Don't worry about making it perfect"
            ]
        } else if instruction.lowercased().contains("pressure") {
            return [
                "Try pressing lightly, then gradually harder",
                "Notice how the line thickness changes",
                "Practice different pressure levels"
            ]
        } else if instruction.lowercased().contains("circle") {
            return [
                "Start with loose, flowing movements",
                "Don't worry about closing the circle perfectly",
                "Your personal style makes it unique"
            ]
        } else {
            return [
                "Take your time and enjoy the process",
                "Every stroke is practice",
                "Focus on the motion, not just the result"
            ]
        }
    }
}

// MARK: - Enhanced Theory View
struct EnhancedTheoryView: View {
    let step: LessonStep
    let content: TheoryContent
    @Binding var selectedAnswers: Set<String>
    let hasSubmittedAnswer: Bool
    let onAnswerSelected: (String) -> Void
    
    @State private var animateOptions = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Theory explanation card
            TheoryExplanationCard(
                title: step.title,
                instruction: step.instruction,
                explanation: content.explanation
            )
            
            // Visual aid if provided
            if let visualAid = content.visualAid {
                AsyncImage(url: URL(string: visualAid)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .frame(height: 150)
                        .overlay(ProgressView())
                }
                .frame(maxHeight: 200)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
            }
            
            // Interactive question
            VStack(alignment: .leading, spacing: 16) {
                Text("Check Your Understanding")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(content.question)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(nil)
                
                // Answer options
                LazyVStack(spacing: 12) {
                    ForEach(Array(content.options.enumerated()), id: \.offset) { index, option in
                        TheoryAnswerOption(
                            option: option,
                            isSelected: selectedAnswers.contains(option.id),
                            hasSubmitted: hasSubmittedAnswer,
                            isCorrect: content.correctAnswers.contains(option.id),
                            animationDelay: Double(index) * 0.1,
                            animated: animateOptions,
                            onTap: {
                                if !hasSubmittedAnswer {
                                    onAnswerSelected(option.id)
                                }
                            }
                        )
                    }
                }
            }
            
            // Explanation after answer
            if hasSubmittedAnswer {
                AnswerExplanationCard(
                    explanation: content.explanation,
                    isCorrect: Set(content.correctAnswers) == selectedAnswers
                )
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5)) {
                animateOptions = true
            }
        }
    }
}

// MARK: - Enhanced Challenge View
struct EnhancedChallengeView: View {
    let step: LessonStep
    let content: ChallengeContent
    let onChallengeCompleted: (Bool) -> Void
    
    @State private var challengeProgress: Double = 0
    @State private var hasStartedChallenge = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Challenge briefing
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.title2)
                    
                    Text("Challenge Time!")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)
                    
                    Spacer()
                }
                
                Text(step.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(content.prompt)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(nil)
                
                // Challenge type info
                HStack {
                    Label(content.challengeType.rawValue.capitalized, systemImage: "target")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if let timeLimit = content.constraints?["time_limit"],
                       let time = Int(timeLimit) {
                        Label("\(time)s", systemImage: "clock")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding(20)
            .background(Color.yellow.opacity(0.05))
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
            )
            
            // Challenge action area
            VStack(spacing: 16) {
                if !hasStartedChallenge {
                    Button(action: {
                        hasStartedChallenge = true
                        challengeProgress = 0.3 // Simulate progress
                        onChallengeCompleted(true)
                    }) {
                        Text("Start Challenge")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.yellow)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                } else {
                    VStack(spacing: 12) {
                        Text("Challenge in progress...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ProgressView(value: challengeProgress)
                            .progressViewStyle(LinearProgressViewStyle())
                            .tint(.yellow)
                        
                        Button(action: {
                            challengeProgress = 1.0
                            onChallengeCompleted(true)
                        }) {
                            Text("Complete Challenge")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                }
                
                // Resources
                if !content.resources.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Available Resources:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        ForEach(content.resources, id: \.self) { resource in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                
                                Text(resource)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
    }
}

// MARK: - Supporting View Components
struct LessonObjectiveCard: View {
    let title: String
    let instruction: String
    let animated: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text("Learning Objective")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                Spacer()
            }
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(instruction)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(nil)
        }
        .padding(20)
        .background(Color.blue.opacity(0.05))
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
        .scaleEffect(animated ? 1.0 : 0.95)
        .opacity(animated ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animated)
    }
}

struct LearningPointCard: View {
    let point: String
    let index: Int
    let animated: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Animated checkmark
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 24, height: 24)
                
                Image(systemName: "checkmark")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .scaleEffect(animated ? 1.0 : 0.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(Double(index) * 0.1), value: animated)
            }
            
            Text(point)
                .font(.body)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
            
            Spacer()
        }
        .padding(16)
        .background(.regularMaterial)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        .offset(x: animated ? 0 : 50)
        .opacity(animated ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.15), value: animated)
    }
}

struct DrawingInstructionCard: View {
    let title: String
    let instruction: String
    let tips: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "hand.draw")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text("Drawing Exercise")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                
                Spacer()
            }
            
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(instruction)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(nil)
            
            if !tips.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("💡 Pro Tips:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                    
                    ForEach(tips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .foregroundColor(.orange)
                            Text(tip)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.orange.opacity(0.05))
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
        )
    }
}

struct ReferenceImageView: View {
    let imageName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reference Image")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            AsyncImage(url: URL(string: imageName)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(height: 150)
                    .overlay(
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Text("Loading reference...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
            }
            .frame(maxHeight: 200)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
        }
    }
}

// MARK: - Drawing Canvas and Tools
struct DrawingCanvasView: UIViewRepresentable {
    let canvasView: PKCanvasView
    let canvasSize: CGSize
    let backgroundColor: String
    let guidelines: [DrawingContent.Guideline]?
    let onStrokeAdded: () -> Void
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.delegate = context.coordinator
        canvasView.backgroundColor = UIColor.systemBackground
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 3)
        
        // Set canvas size constraints
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update background color if needed
        if backgroundColor == "#FFFFFF" || backgroundColor == "white" {
            uiView.backgroundColor = UIColor.systemBackground
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onStrokeAdded: onStrokeAdded)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        let onStrokeAdded: () -> Void
        
        init(onStrokeAdded: @escaping () -> Void) {
            self.onStrokeAdded = onStrokeAdded
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            onStrokeAdded()
        }
    }
}

struct DrawingToolsPanel: View {
    @Binding var currentTool: PKInkingTool
    let onToolChanged: (PKInkingTool) -> Void
    
    private let tools: [(String, String, PKInkingTool.InkType, Color)] = [
        ("Pencil", "pencil", .pencil, .gray),
        ("Pen", "pen", .pen, .blue),
        ("Marker", "highlighter", .marker, .green)
    ]
    
    private let strokeWidths: [CGFloat] = [2, 4, 6, 8]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Drawing Tools")
                .font(.headline)
                .fontWeight(.medium)
            
            // Tool selection with better visual feedback
            HStack(spacing: 20) {
                ForEach(tools, id: \.0) { name, icon, inkType, color in
                    Button(action: {
                        let newTool = PKInkingTool(inkType, color: UIColor.label, width: currentTool.width)
                        currentTool = newTool
                        onToolChanged(newTool)
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: icon)
                                .font(.title2)
                                .foregroundColor(currentTool.inkType == inkType ? .blue : .secondary)
                            
                            Text(name)
                                .font(.caption)
                                .fontWeight(currentTool.inkType == inkType ? .semibold : .regular)
                                .foregroundColor(currentTool.inkType == inkType ? .blue : .secondary)
                        }
                        .frame(width: 60, height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(currentTool.inkType == inkType ? Color.blue.opacity(0.1) : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(currentTool.inkType == inkType ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Stroke width selection
            VStack(spacing: 8) {
                Text("Line Width")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 16) {
                    ForEach(strokeWidths, id: \.self) { width in
                        Button(action: {
                            let newTool = PKInkingTool(currentTool.inkType, color: currentTool.color, width: width)
                            currentTool = newTool
                            onToolChanged(newTool)
                        }) {
                            Circle()
                                .fill(currentTool.width == width ? Color.blue : Color.gray)
                                .frame(width: width * 3 + 8, height: width * 3 + 8)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: currentTool.width == width ? 2 : 0)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(20)
        .background(.regularMaterial)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

struct DrawingFeedbackCard: View {
    let hasContent: Bool
    
    var body: some View {
        if hasContent {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Great work!")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    Text("You're making progress with every stroke.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(12)
            .background(Color.green.opacity(0.08))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.green.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// MARK: - Theory Components
struct TheoryExplanationCard: View {
    let title: String
    let instruction: String
    let explanation: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "book")
                    .foregroundColor(.purple)
                    .font(.title2)
                
                Text("Art Theory")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
                
                Spacer()
            }
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(explanation)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(nil)
        }
        .padding(20)
        .background(Color.purple.opacity(0.05))
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
    }
}

struct TheoryAnswerOption: View {
    let option: TheoryContent.AnswerOption
    let isSelected: Bool
    let hasSubmitted: Bool
    let isCorrect: Bool
    let animationDelay: Double
    let animated: Bool
    let onTap: () -> Void
    
    var backgroundColor: Color {
        if hasSubmitted {
            return isCorrect ? .green.opacity(0.1) : isSelected ? .red.opacity(0.1) : .clear
        } else {
            return isSelected ? .blue.opacity(0.1) : .clear
        }
    }
    
    var borderColor: Color {
        if hasSubmitted {
            return isCorrect ? .green : isSelected ? .red : .gray.opacity(0.3)
        } else {
            return isSelected ? .blue : .gray.opacity(0.3)
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(borderColor, lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    if isSelected {
                        Circle()
                            .fill(borderColor)
                            .frame(width: 12, height: 12)
                    }
                    
                    if hasSubmitted && isCorrect {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                
                Text(option.text)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(16)
            .background(backgroundColor)
            .background(.regularMaterial)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: isSelected || hasSubmitted ? 2 : 1)
            )
        }
        .disabled(hasSubmitted)
        .scaleEffect(animated ? 1.0 : 0.9)
        .opacity(animated ? 1.0 : 0.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(animationDelay), value: animated)
    }
}

struct AnswerExplanationCard: View {
    let explanation: String
    let isCorrect: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "info.circle.fill")
                    .foregroundColor(isCorrect ? .green : .blue)
                
                Text(isCorrect ? "Correct!" : "Learning Moment")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isCorrect ? .green : .blue)
                
                Spacer()
            }
            
            Text(explanation)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(nil)
        }
        .padding(16)
        .background((isCorrect ? Color.green : Color.blue).opacity(0.05))
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke((isCorrect ? Color.green : Color.blue).opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Simple Lesson Complete View
struct SimpleLessonCompleteView: View {
    let lesson: Lesson
    let totalXP: Int
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Success icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
            }
            
            // Completion message
            VStack(spacing: 8) {
                Text("Lesson Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Great job on completing \"\(lesson.title)\"")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // XP earned
            VStack(spacing: 4) {
                Text("+\(totalXP) XP")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("Experience Points Earned")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            
            Spacer()
            
            // Continue button
            Button(action: onDismiss) {
                Text("Continue Learning")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
    }
}

// MARK: - Enhanced View Model
@MainActor
class LessonPlayerViewModel: ObservableObject {
    @Published var currentStepIndex = 0
    @Published var progress: Double = 0
    @Published var canProceed = false
    @Published var selectedAnswers: Set<String> = []
    @Published var hasSubmittedAnswer = false
    @Published var showLessonComplete = false
    @Published var shouldDismiss = false
    @Published var heartsRemaining = 5
    @Published var totalXPEarned = 0
    @Published var isProcessing = false
    @Published var showInstructionalHelp = false
    @Published var canShowInstructionalHelp = false
    
    private let lesson: Lesson
    private let progressService = ProgressService.shared
    private var attemptCounts: [String: Int] = [:]
    
    init(lesson: Lesson) {
        self.lesson = lesson
    }
    
    var currentStep: LessonStep? {
        guard currentStepIndex < lesson.steps.count else { return nil }
        return lesson.steps[currentStepIndex]
    }
    
    var primaryActionText: String {
        if isProcessing { return "Processing..." }
        if hasSubmittedAnswer { return "Continue" }
        if currentStepIndex == lesson.steps.count - 1 { return "Complete Lesson" }
        return "Continue"
    }
    
    func startLesson() {
        updateProgress()
        checkCanShowInstructionalHelp()
    }
    
    func handlePrimaryAction() {
        guard !isProcessing else { return }
        
        isProcessing = true
        
        // Add small delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isProcessing = false
            
            if let step = self.currentStep, self.needsValidation(step) && !self.hasSubmittedAnswer {
                self.submitAnswer()
            } else {
                self.proceedToNextStep()
            }
        }
    }
    
    private func submitAnswer() {
        guard let step = currentStep else { return }
        
        hasSubmittedAnswer = true
        let isCorrect = validateStep(step)
        
        if !isCorrect {
            heartsRemaining = max(0, heartsRemaining - 1)
        }
        
        totalXPEarned += step.xpValue
        
        // Track step completion
        saveStepProgress(step, isCorrect: isCorrect)
        
        // Enable continue after showing feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.canProceed = true
        }
    }
    
    private func proceedToNextStep() {
        if currentStepIndex == lesson.steps.count - 1 {
            completeLesson()
        } else {
            currentStepIndex += 1
            resetStepState()
            updateProgress()
            checkCanShowInstructionalHelp()
        }
    }
    
    private func saveStepProgress(_ step: LessonStep, isCorrect: Bool) {
        Task {
            do {
                try await progressService.updateLessonProgress(
                    lessonId: lesson.id,
                    stepId: step.id,
                    score: isCorrect ? 1.0 : 0.7,
                    timeSpent: 15.0
                )
            } catch {
                print("❌ Failed to save step progress: \(error)")
            }
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
    
    func selectAnswer(_ answerId: String) {
        guard !hasSubmittedAnswer else { return }
        selectedAnswers = [answerId]
        setCanProceed(true)
        
        // Track attempts for instructional help system
        let stepId = currentStep?.id ?? ""
        attemptCounts[stepId, default: 0] += 1
        checkCanShowInstructionalHelp()
    }
    
    func setCanProceed(_ canProceed: Bool) {
        self.canProceed = canProceed
    }
    
    func dismissInstructionalHelp() {
        showInstructionalHelp = false
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
        showInstructionalHelp = false
    }
    
    private func updateProgress() {
        let totalSteps = max(lesson.steps.count, 1)
        withAnimation(.spring(response: 0.5)) {
            progress = Double(currentStepIndex + 1) / Double(totalSteps)
        }
    }
    
    private func checkCanShowInstructionalHelp() {
        guard let step = currentStep else { return }
        let stepId = step.id
        canShowInstructionalHelp = attemptCounts[stepId, default: 0] >= 1
    }
}

// MARK: - Instructional Help View
struct InstructionalHelpView: View {
    let currentStep: LessonStep?
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "lightbulb")
                    .foregroundColor(.orange)
                
                Text("Need some guidance?")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                }
            }
            
            Text(getInstructionalHint())
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(nil)
        }
        .padding(16)
        .background(Color.orange.opacity(0.05))
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func getInstructionalHint() -> String {
        guard let step = currentStep else {
            return "Take your time and think about what you've learned so far."
        }
        
        switch step.content {
        case .drawing:
            return "Remember to start with basic shapes and build up your drawing gradually. Don't worry about perfection!"
        case .theory:
            return "Think about the concepts we've covered. Re-read the explanation above if you need to refresh your memory."
        case .challenge:
            return "Apply what you've learned in the previous steps. You've got the skills to handle this!"
        case .introduction:
            return "Take your time to read through each learning point carefully."
        }
    }
}
