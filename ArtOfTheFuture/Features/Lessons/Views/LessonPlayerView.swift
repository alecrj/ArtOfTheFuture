// MARK: - Enhanced Lesson Player View (PRODUCTION READY)
// File: ArtOfTheFuture/Features/Lessons/Views/LessonPlayerView.swift

import SwiftUI
import PencilKit
import Foundation

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
                            .foregroundColor(index < viewModel.heartsRemaining ? .red : .gray)
                            .scaleEffect(index < viewModel.heartsRemaining ? 1.0 : 0.8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.heartsRemaining)
                    }
                }
            }
            
            // Enhanced progress indicator
            progressIndicatorView
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Progress Indicator (FIXED COMPLEX EXPRESSION)
    private var progressIndicatorView: some View {
        let currentStepIndex = viewModel.currentStepIndex
        let totalSteps = lesson.steps.count
        let progress = totalSteps > 0 ? Double(currentStepIndex + 1) / Double(totalSteps) : 0.0
        
        return VStack(spacing: 8) {
            // Step counter
            HStack {
                Text("Step \(currentStepIndex + 1) of \(totalSteps)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // XP indicator
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    
                    Text("\(viewModel.totalXPEarned) XP")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                }
            }
            
            // Visual progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track - FIXED: Using Rectangle instead of Rect
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    // Progress fill with gradient - FIXED: Using Rectangle instead of Rect
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                        .cornerRadius(4)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 8)
        }
    }
    
    // MARK: - Step Content View (PERFORMANCE OPTIMIZED)
    @ViewBuilder
    private func stepContentView(_ step: LessonStep, geometry: GeometryProxy) -> some View {
        VStack(spacing: 24) {
            switch step.content {
            case .introduction(let content):
                EnhancedIntroductionView(
                    step: step,
                    content: content,
                    onReady: { viewModel.markStepComplete() }
                )
                
            case .drawing(let content):
                EnhancedDrawingView(
                    step: step,
                    content: content,
                    geometry: geometry,
                    onDrawingChanged: { hasDrawn in
                        if hasDrawn {
                            viewModel.enableContinue()
                        }
                    }
                )
                
            case .theory(let content):
                EnhancedTheoryView(
                    step: step,
                    content: content,
                    onAnswerSelected: { isCorrect in
                        viewModel.handleAnswer(isCorrect: isCorrect)
                    }
                )
                
            case .challenge(let content):
                EnhancedChallengeView(
                    step: step,
                    content: content,
                    geometry: geometry,
                    onChallengeComplete: { score in
                        viewModel.handleChallengeCompletion(score: score)
                    }
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Bottom Controls (SIMPLIFIED FOR PERFORMANCE)
    private var bottomControlsView: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 16) {
                // Previous button
                previousButton
                
                Spacer()
                
                // Continue button
                continueButton
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial)
        }
    }
    
    // MARK: - Button Components (EXTRACTED FOR READABILITY)
    private var previousButton: some View {
        Button(action: { viewModel.previousStep() }) {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                    .font(.caption)
                Text("Previous")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(.secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .disabled(!viewModel.canGoPrevious)
        .opacity(viewModel.canGoPrevious ? 1.0 : 0.5)
    }
    
    private var continueButton: some View {
        Button(action: { viewModel.nextStep() }) {
            HStack(spacing: 8) {
                Text(viewModel.isLastStep ? "Complete" : "Continue")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if !viewModel.isLastStep {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(viewModel.canContinue ? Color.blue : Color.gray)
            .cornerRadius(8)
        }
        .disabled(!viewModel.canContinue)
        .animation(.easeInOut(duration: 0.2), value: viewModel.canContinue)
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
                    // FIXED: Using RoundedRectangle instead of Rect
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
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animateContent)
            }
            
            // Learning points with animations
            if !content.bulletPoints.isEmpty {
                VStack(spacing: 12) {
                    ForEach(Array(content.bulletPoints.enumerated()), id: \.offset) { index, point in
                        LearningPointCard(
                            point: point,
                            index: index,
                            animated: animateContent
                        )
                    }
                }
            }
            
            // Ready button
            Button(action: {
                onReady()
            }) {
                Text("I'm Ready!")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .scaleEffect(animateContent ? 1.0 : 0.95)
            .opacity(animateContent ? 1.0 : 0.0)
            .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.8), value: animateContent)
        }
        .onAppear {
            withAnimation {
                animateContent = true
            }
        }
    }
}

// MARK: - Lesson Player View Model
@MainActor
class LessonPlayerViewModel: ObservableObject {
    @Published var currentStepIndex = 0
    @Published var progress: Double = 0
    @Published var canContinue = false
    @Published var canGoPrevious = false
    @Published var selectedAnswers: Set<String> = []
    @Published var hasSubmittedAnswer = false
    @Published var showLessonComplete = false
    @Published var shouldDismiss = false
    @Published var heartsRemaining = 5
    @Published var totalXPEarned = 0
    @Published var isProcessing = false
    
    private let lesson: Lesson
    private let progressService = ProgressService.shared
    private var attemptCounts: [String: Int] = [:]
    
    init(lesson: Lesson) {
        self.lesson = lesson
        updateProgress()
        updateNavigationState()
    }
    
    var currentStep: LessonStep? {
        guard currentStepIndex < lesson.steps.count else { return nil }
        return lesson.steps[currentStepIndex]
    }
    
    var isLastStep: Bool {
        currentStepIndex >= lesson.steps.count - 1
    }
    
    // MARK: - Navigation
    func startLesson() {
        currentStepIndex = 0
        updateProgress()
        updateNavigationState()
    }
    
    func nextStep() {
        guard canContinue else { return }
        
        if isLastStep {
            completeLesson()
        } else {
            currentStepIndex += 1
            canContinue = false
            updateProgress()
            updateNavigationState()
        }
    }
    
    func previousStep() {
        guard canGoPrevious else { return }
        currentStepIndex -= 1
        updateProgress()
        updateNavigationState()
    }
    
    func enableContinue() {
        canContinue = true
    }
    
    func markStepComplete() {
        canContinue = true
    }
    
    // MARK: - Answer Handling
    func handleAnswer(isCorrect: Bool) {
        if isCorrect {
            totalXPEarned += currentStep?.xpValue ?? 0
            canContinue = true
        } else {
            heartsRemaining = max(0, heartsRemaining - 1)
            if heartsRemaining > 0 {
                // Allow retry
                hasSubmittedAnswer = false
                selectedAnswers.removeAll()
            } else {
                // End lesson
                completeLesson()
            }
        }
    }
    
    func handleChallengeCompletion(score: Double) {
        let xpMultiplier = max(0.5, score) // Minimum 50% XP
        let earnedXP = Int(Double(currentStep?.xpValue ?? 0) * xpMultiplier)
        totalXPEarned += earnedXP
        canContinue = true
    }
    
    // MARK: - Completion
    func completeLesson() {
        showLessonComplete = true
    }
    
    func completeLessonFlow() {
        shouldDismiss = true
        
        // Save progress
        Task {
            try await progressService.completeLesson(lesson.id)
        }
    }
    
    // MARK: - Private Helpers
    private func updateProgress() {
        let totalSteps = lesson.steps.count
        progress = totalSteps > 0 ? Double(currentStepIndex + 1) / Double(totalSteps) : 0.0
    }
    
    private func updateNavigationState() {
        canGoPrevious = currentStepIndex > 0
        // canContinue is managed by individual step completion
    }
}

// MARK: - Enhanced Drawing View
struct EnhancedDrawingView: View {
    let step: LessonStep
    let content: DrawingContent
    let geometry: GeometryProxy
    let onDrawingChanged: (Bool) -> Void
    
    @State private var canvasView = PKCanvasView()
    @State private var hasDrawnStrokes = false
    @State private var showDrawingTools = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Drawing instruction card
            DrawingInstructionCard(
                title: step.title,
                instruction: step.instruction,
                tips: [
                    "Take your time with each stroke",
                    "Don't worry about perfection",
                    "Use light strokes to start"
                ]
            )
            
            // Reference image if provided
            if let referenceImage = content.referenceImage {
                ReferenceImageView(imageName: referenceImage)
            }
            
            // Warning indicator if no strokes
            if !hasDrawnStrokes {
                HStack {
                    Image(systemName: "hand.draw")
                        .foregroundColor(.orange)
                    Text("Start drawing to continue")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
                .transition(.scale.combined(with: .opacity))
            }
            
            // Main drawing canvas with fixed dimensions
            VStack {
                DrawingCanvasView(
                    canvasView: $canvasView,
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
            .frame(
                width: min(content.canvasSize.width, geometry.size.width - 48),
                height: min(content.canvasSize.height, 300)
            )
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
                .fontWeight(.medium)
                .foregroundColor(.blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Expanded drawing tools
            if showDrawingTools {
                DrawingToolsPanel(canvasView: $canvasView)
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showDrawingTools)
    }
}

// MARK: - Enhanced Theory View
struct EnhancedTheoryView: View {
    let step: LessonStep
    let content: TheoryContent
    let onAnswerSelected: (Bool) -> Void
    
    @State private var selectedAnswers: Set<String> = []
    @State private var showExplanation = false
    @State private var isCorrect = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Question card
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(.purple)
                        .font(.title2)
                    
                    Text("Knowledge Check")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                    
                    Spacer()
                }
                
                Text(step.title)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(content.question)
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
            
            // Answer options
            VStack(spacing: 12) {
                ForEach(content.options) { option in
                    AnswerOptionView(
                        option: option,
                        isSelected: selectedAnswers.contains(option.id),
                        showResult: showExplanation,
                        isCorrect: content.correctAnswers.contains(option.id)
                    ) {
                        handleAnswerSelection(option.id)
                    }
                }
            }
            
            // Submit button
            if !selectedAnswers.isEmpty && !showExplanation {
                Button(action: submitAnswer) {
                    Text("Submit Answer")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.purple)
                        .cornerRadius(12)
                }
            }
            
            // Explanation
            if showExplanation {
                ExplanationCard(
                    explanation: content.explanation,
                    isCorrect: isCorrect
                )
            }
        }
    }
    
    private func handleAnswerSelection(_ optionId: String) {
        if content.answerType == .singleChoice {
            selectedAnswers = [optionId]
        } else {
            if selectedAnswers.contains(optionId) {
                selectedAnswers.remove(optionId)
            } else {
                selectedAnswers.insert(optionId)
            }
        }
    }
    
    private func submitAnswer() {
        isCorrect = Set(content.correctAnswers) == selectedAnswers
        showExplanation = true
        onAnswerSelected(isCorrect)
    }
}

// MARK: - Enhanced Challenge View
struct EnhancedChallengeView: View {
    let step: LessonStep
    let content: ChallengeContent
    let geometry: GeometryProxy
    let onChallengeComplete: (Double) -> Void
    
    @State private var challengeStarted = false
    @State private var challengeCompleted = false
    @State private var timeElapsed: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 24) {
            // Challenge header
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "target")
                        .foregroundColor(.red)
                        .font(.title2)
                    
                    Text("Challenge Mode")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    
                    Spacer()
                    
                    // Timer
                    if challengeStarted && !challengeCompleted {
                        Text(String(format: "%.1fs", timeElapsed))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                
                Text(step.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(content.prompt)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(nil)
            }
            .padding(20)
            .background(Color.red.opacity(0.05))
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.red.opacity(0.2), lineWidth: 1)
            )
            
            // Challenge content based on type
            challengeContentView
            
            // Start/Complete button
            challengeActionButton
        }
    }
    
    @ViewBuilder
    private var challengeContentView: some View {
        switch content.challengeType {
        case .speedDraw:
            TimedChallengeView(
                challengeStarted: challengeStarted,
                onComplete: { score in
                    completeChallenge(score: score)
                }
            )
        case .precision:
            AccuracyChallengeView(
                challengeStarted: challengeStarted,
                onComplete: { score in
                    completeChallenge(score: score)
                }
            )
        case .freestyle:
            CreativeChallengeView(
                challengeStarted: challengeStarted,
                geometry: geometry,
                onComplete: { score in
                    completeChallenge(score: score)
                }
            )
        case .copyWork:
            CopyWorkChallengeView(
                challengeStarted: challengeStarted,
                geometry: geometry,
                onComplete: { score in
                    completeChallenge(score: score)
                }
            )
        }
    }
    
    private var challengeActionButton: some View {
        Button(action: {
            if !challengeStarted {
                startChallenge()
            } else if challengeCompleted {
                // Challenge already completed
            }
        }) {
            Text(challengeStarted ? (challengeCompleted ? "Challenge Complete!" : "In Progress...") : "Start Challenge")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(challengeStarted ? (challengeCompleted ? .green : .orange) : .red)
                .cornerRadius(12)
        }
        .disabled(challengeStarted && !challengeCompleted)
    }
    
    private func startChallenge() {
        challengeStarted = true
        timeElapsed = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            timeElapsed += 0.1
        }
    }
    
    private func completeChallenge(score: Double) {
        challengeCompleted = true
        timer?.invalidate()
        timer = nil
        onChallengeComplete(score)
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
    @Binding var canvasView: PKCanvasView
    let canvasSize: CGSize
    let backgroundColor: String
    let guidelines: [DrawingContent.Guideline]?
    let onStrokeAdded: () -> Void
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.delegate = context.coordinator
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = UIColor(named: backgroundColor) ?? .white
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update canvas properties if needed
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
    @Binding var canvasView: PKCanvasView
    
    var body: some View {
        HStack(spacing: 16) {
            // Brush size
            VStack {
                Text("Size")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                HStack {
                    Button("S") { /* Small brush */ }
                        .buttonStyle(.bordered)
                    Button("M") { /* Medium brush */ }
                        .buttonStyle(.bordered)
                    Button("L") { /* Large brush */ }
                        .buttonStyle(.bordered)
                }
            }
            
            Divider()
                .frame(height: 30)
            
            // Colors
            VStack {
                Text("Color")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                HStack {
                    ForEach([Color.black, Color.blue, Color.red, Color.green], id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 24, height: 24)
                            .onTapGesture {
                                // Set color
                            }
                    }
                }
            }
            
            Divider()
                .frame(height: 30)
            
            // Clear button
            Button("Clear") {
                canvasView.drawing = PKDrawing()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Answer Option View
struct AnswerOptionView: View {
    let option: TheoryContent.AnswerOption
    let isSelected: Bool
    let showResult: Bool
    let isCorrect: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
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
                }
                
                Text(option.text)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Result indicator
                if showResult && isSelected {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isCorrect ? .green : .red)
                }
            }
            .padding(16)
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        .disabled(showResult)
    }
    
    private var borderColor: Color {
        if showResult && isSelected {
            return isCorrect ? .green : .red
        }
        return isSelected ? .blue : .gray
    }
    
    private var backgroundColor: Color {
        if showResult && isSelected {
            return isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1)
        }
        return isSelected ? Color.blue.opacity(0.1) : Color.clear
    }
}

// MARK: - Explanation Card
struct ExplanationCard: View {
    let explanation: String
    let isCorrect: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "lightbulb.fill")
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
                
                Text("You earned \(totalXP) XP!")
                    .font(.headline)
                    .foregroundColor(.orange)
            }
            
            // Stats
            VStack(spacing: 12) {
                HStack {
                    Text("Lesson:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(lesson.title)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Experience:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(totalXP) XP")
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            
            Spacer()
            
            // Continue button
            Button(action: onDismiss) {
                Text("Continue Learning")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}

// MARK: - Challenge Content Views
struct TimedChallengeView: View {
    let challengeStarted: Bool
    let onComplete: (Double) -> Void
    
    var body: some View {
        VStack {
            Text("Timed Challenge Placeholder")
            if challengeStarted {
                Button("Complete") {
                    onComplete(1.0)
                }
            }
        }
    }
}

struct AccuracyChallengeView: View {
    let challengeStarted: Bool
    let onComplete: (Double) -> Void
    
    var body: some View {
        VStack {
            Text("Accuracy Challenge Placeholder")
            if challengeStarted {
                Button("Complete") {
                    onComplete(1.0)
                }
            }
        }
    }
}

struct CreativeChallengeView: View {
    let challengeStarted: Bool
    let geometry: GeometryProxy
    let onComplete: (Double) -> Void
    
    var body: some View {
        VStack {
            Text("Creative Challenge Placeholder")
            if challengeStarted {
                Button("Complete") {
                    onComplete(1.0)
                }
            }
        }
    }
}

struct CopyWorkChallengeView: View {
    let challengeStarted: Bool
    let geometry: GeometryProxy
    let onComplete: (Double) -> Void
    
    var body: some View {
        VStack {
            Text("Copy Work Challenge Placeholder")
            if challengeStarted {
                Button("Complete") {
                    onComplete(1.0)
                }
            }
        }
    }
}
