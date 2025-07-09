// MARK: - -Style Lesson Player
// File: ArtOfTheFuture/Features/Lessons/Views/LessonPlayer.swift

import SwiftUI
import PencilKit
import Combine

struct LessonPlayer: View {
    @StateObject private var viewModel: LessonViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingQuitAlert = false
    @State private var screenSize: CGSize = .zero
    
    init(lesson: Lesson) {
        _viewModel = StateObject(wrappedValue: LessonViewModel(lesson: lesson))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dynamic background based on lesson type
                dynamicBackground
                
                VStack(spacing: 0) {
                    // Header
                    lessonHeader
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    // Main content
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Current exercise
                            exerciseContent
                                .padding(.horizontal)
                            
                            // Feedback area
                            if viewModel.showFeedback {
                                feedbackView
                                    .transition(.asymmetric(
                                        insertion: .scale.combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }
                        }
                        .padding(.vertical, 20)
                    }
                    
                    // Bottom action area
                    bottomActionBar
                        .background(.ultraThinMaterial)
                }
                
                // Overlays
                if viewModel.showCelebration {
                    celebrationOverlay
                }
                
                if viewModel.showHeartLoss {
                    heartLossAnimation
                }
            }
            .onAppear { screenSize = geometry.size }
        }
        .navigationBarHidden(true)
        .alert("Quit lesson?", isPresented: $showingQuitAlert) {
            Button("Quit", role: .destructive) {
                viewModel.quitLesson()
                dismiss()
            }
            Button("Keep learning", role: .cancel) { }
        } message: {
            Text("You'll lose your progress in this lesson")
        }
        .onReceive(viewModel.$lessonComplete) { complete in
            if complete {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - Dynamic Background
    private var dynamicBackground: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated shapes
            ForEach(0..<3) { index in
                FloatingShape(
                    color: viewModel.lesson.type.color.opacity(0.1),
                    delay: Double(index) * 2
                )
            }
        }
    }
    
    private var backgroundColors: [Color] {
        switch viewModel.lesson.type {
        case .drawingPractice:
            return [Color.blue.opacity(0.05), Color.cyan.opacity(0.05)]
        case .theoryFundamentals:
            return [Color.purple.opacity(0.05), Color.indigo.opacity(0.05)]
        case .creativeChallenge:
            return [Color.orange.opacity(0.05), Color.pink.opacity(0.05)]
        }
    }
    
    // MARK: - Header
    private var lessonHeader: some View {
        VStack(spacing: 12) {
            // Top bar
            HStack {
                // Close button
                Button(action: { showingQuitAlert = true }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .frame(width: 36, height: 36)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                // Hearts (lives)
                HeartsDisplay(
                    totalHearts: viewModel.totalHearts,
                    currentHearts: viewModel.currentHearts
                )
                
                Spacer()
                
                // XP display
                XPBadge(xp: viewModel.currentExercise?.xpValue ?? 0)
            }
            
            // Progress bar
            VStack(spacing: 4) {
                // Exercise progress
                ExerciseProgressBar(
                    current: viewModel.currentExerciseIndex + 1,
                    total: viewModel.lesson.exercises.count,
                    progress: viewModel.overallProgress
                )
                
                // Lesson info
                HStack {
                    Label(viewModel.lesson.title, systemImage: viewModel.lesson.type.icon)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(viewModel.currentExerciseIndex + 1)/\(viewModel.lesson.exercises.count)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Exercise Content
    @ViewBuilder
    private var exerciseContent: some View {
        if let exercise = viewModel.currentExercise {
            VStack(spacing: 20) {
                // Exercise instruction
                ExerciseInstruction(
                    instruction: exercise.instruction,
                    hints: exercise.hints,
                    showHint: viewModel.showHint
                )
                
                // Exercise-specific content
                switch exercise.content {
                case .drawing(let drawingExercise):
                    SimpleDrawingExerciseView(
                        exercise: drawingExercise,
                        viewModel: viewModel
                    )
                    
                case .theory(let theoryExercise):
                    SimpleTheoryExerciseView(
                        exercise: theoryExercise,
                        viewModel: viewModel
                    )
                    
                case .challenge(let challengeExercise):
                    SimpleChallengeExerciseView(
                        exercise: challengeExercise,
                        viewModel: viewModel
                    )
                }
            }
        }
    }
    
    // MARK: - Feedback View
    private var feedbackView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: viewModel.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(viewModel.isCorrect ? .green : .red)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.feedbackTitle)
                        .font(.headline)
                    
                    if !viewModel.feedbackMessage.isEmpty {
                        Text(viewModel.feedbackMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(viewModel.isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
            )
            
            if !viewModel.isCorrect && viewModel.currentHearts > 0 {
                Button(action: viewModel.tryAgain) {
                    Text("Try Again")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Bottom Action Bar
    private var bottomActionBar: some View {
        VStack(spacing: 16) {
            // Main action button
            Button(action: viewModel.handleMainAction) {
                HStack {
                    Text(viewModel.mainActionTitle)
                        .fontWeight(.semibold)
                    
                    if viewModel.canContinue {
                        Image(systemName: "arrow.right")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(viewModel.canContinue ? Color.green : Color(.systemGray4))
                .foregroundColor(viewModel.canContinue ? .white : .secondary)
                .cornerRadius(16)
            }
            .disabled(!viewModel.canContinue && !viewModel.showFeedback)
            
            // Secondary actions
            HStack(spacing: 20) {
                // Hint button
                if viewModel.hintsAvailable {
                    Button(action: viewModel.useHint) {
                        Label("Hint", systemImage: "lightbulb")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                }
                
                // Skip button (if allowed)
                if viewModel.canSkip {
                    Button(action: viewModel.skipExercise) {
                        Text("Skip")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Report problem
                Button(action: viewModel.reportProblem) {
                    Image(systemName: "flag")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
    
    // MARK: - Celebration Overlay
    private var celebrationOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Animated trophy
                TrophyAnimation()
                
                // Success message
                VStack(spacing: 16) {
                    Text("Excellent!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("+\(viewModel.totalXPEarned) XP")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)
                    
                    if viewModel.perfectScore {
                        HStack {
                            Image(systemName: "star.fill")
                            Text("Perfect Score!")
                            Image(systemName: "star.fill")
                        }
                        .font(.headline)
                        .foregroundColor(.yellow)
                    }
                }
                
                // Continue button
                Button(action: {
                    viewModel.showCelebration = false
                    dismiss()
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(25)
                }
            }
            
            // Confetti
            ConfettiView()
        }
    }
    
    // MARK: - Heart Loss Animation
    private var heartLossAnimation: some View {
        HeartLossAnimation()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    viewModel.showHeartLoss = false
                }
            }
    }
}

// MARK: - Supporting Views

struct HeartsDisplay: View {
    let totalHearts: Int
    let currentHearts: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<totalHearts, id: \.self) { index in
                Image(systemName: index < currentHearts ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundColor(index < currentHearts ? .red : .gray)
                    .scaleEffect(index < currentHearts ? 1.0 : 0.8)
                    .animation(.spring(response: 0.3), value: currentHearts)
            }
        }
    }
}

struct XPBadge: View {
    let xp: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.caption)
                .foregroundColor(.yellow)
            
            Text("+\(xp)")
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.yellow.opacity(0.2))
        .cornerRadius(12)
    }
}

struct ExerciseProgressBar: View {
    let current: Int
    let total: Int
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.systemGray5))
                
                // Progress
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [.green, .green.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress)
                
                // Milestone dots
                HStack(spacing: 0) {
                    ForEach(0..<total, id: \.self) { index in
                        if index > 0 {
                            Spacer()
                        }
                        
                        Circle()
                            .fill(index < current ? Color.white : Color(.systemGray3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index < current ? 1.0 : 0.7)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .frame(height: 12)
    }
}

struct ExerciseInstruction: View {
    let instruction: String
    let hints: [String]
    let showHint: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Text(instruction)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            if showHint && !hints.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.orange)
                        Text("Hint")
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                    
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
    }
}

// MARK: - Floating Shape Animation
struct FloatingShape: View {
    let color: Color
    let delay: Double
    
    @State private var offset = CGSize.zero
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: CGFloat.random(in: 100...200))
            .offset(offset)
            .scaleEffect(scale)
            .blur(radius: 20)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 10...15))
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    offset = CGSize(
                        width: CGFloat.random(in: -100...100),
                        height: CGFloat.random(in: -100...100)
                    )
                    scale = CGFloat.random(in: 0.8...1.2)
                }
            }
    }
}

// MARK: - Trophy Animation
struct TrophyAnimation: View {
    @State private var scale: CGFloat = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        Image(systemName: "trophy.fill")
            .font(.system(size: 100))
            .foregroundStyle(
                LinearGradient(
                    colors: [.yellow, .orange],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    scale = 1.0
                }
                
                withAnimation(.easeInOut(duration: 0.5).delay(0.3)) {
                    rotation = 360
                }
            }
    }
}

// MARK: - Heart Loss Animation
struct HeartLossAnimation: View {
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    @State private var offset: CGFloat = 0
    
    var body: some View {
        Image(systemName: "heart.slash.fill")
            .font(.system(size: 60))
            .foregroundColor(.red)
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(y: offset)
            .onAppear {
                withAnimation(.easeOut(duration: 0.3)) {
                    scale = 1.5
                }
                
                withAnimation(.easeIn(duration: 0.5).delay(0.3)) {
                    opacity = 0
                    offset = -50
                }
            }
    }
}

// MARK: -  Confetti View (Renamed to avoid conflicts)
struct ConfettiView: View {
    var body: some View {
        ZStack {
            ForEach(0..<30) { _ in
                ConfettiPiece()
            }
        }
    }
}

struct ConfettiPiece: View {
    @State private var position = CGPoint(x: UIScreen.main.bounds.width / 2, y: -20)
    @State private var opacity: Double = 1
    
    let color = [Color.red, .orange, .yellow, .green, .blue, .purple].randomElement()!
    let size = CGFloat.random(in: 10...20)
    let endX = CGFloat.random(in: 0...UIScreen.main.bounds.width)
    let duration = Double.random(in: 2...4)
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: size, height: size * 0.6)
            .rotationEffect(.degrees(Double.random(in: 0...360)))
            .position(position)
            .opacity(opacity)
            .onAppear {
                withAnimation(.linear(duration: duration)) {
                    position = CGPoint(x: endX, y: UIScreen.main.bounds.height + 50)
                }
                
                withAnimation(.linear(duration: duration * 0.8).delay(duration * 0.2)) {
                    opacity = 0
                }
            }
    }
}

// MARK: - Simple Exercise Views
struct SimpleDrawingExerciseView: View {
    let exercise: DrawingExercise
    @ObservedObject var viewModel: LessonViewModel
    @State private var canvasView = PKCanvasView()
    
    var body: some View {
        VStack(spacing: 16) {
            // Drawing canvas
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(radius: 4)
                
                CanvasView(
                    canvasView: $canvasView,
                    currentTool: .constant(.pen),
                    currentColor: .constant(.black),
                    currentWidth: .constant(3.0)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .onChange(of: canvasView.drawing) { _ in
                    viewModel.userDrawing = canvasView.drawing
                    viewModel.updateCanContinue()
                }
            }
            .frame(height: 300)
        }
    }
}

struct SimpleTheoryExerciseView: View {
    let exercise: TheoryExercise
    @ObservedObject var viewModel: LessonViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text(exercise.question)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                ForEach(exercise.options) { option in
                    Button(action: {
                        if viewModel.selectedOptions.contains(option.id) {
                            viewModel.selectedOptions.remove(option.id)
                        } else {
                            viewModel.selectedOptions.insert(option.id)
                        }
                        viewModel.updateCanContinue()
                    }) {
                        HStack {
                            switch option.content {
                            case .text(let text):
                                Text(text)
                                    .font(.body)
                                    .foregroundColor(.primary)
                            case .image(let imageName):
                                Image(imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 60)
                            case .colorSwatch(let hex):
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: hex) ?? .gray)
                                    .frame(width: 60, height: 40)
                            case .diagram(_):
                                Text("Diagram")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: viewModel.selectedOptions.contains(option.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(viewModel.selectedOptions.contains(option.id) ? .blue : .gray)
                        }
                        .padding()
                        .background(viewModel.selectedOptions.contains(option.id) ? Color.blue.opacity(0.1) : Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
}

struct SimpleChallengeExerciseView: View {
    let exercise: ChallengeExercise
    @ObservedObject var viewModel: LessonViewModel
    @State private var canvasView = PKCanvasView()
    
    var body: some View {
        VStack(spacing: 16) {
            Text(exercise.prompt)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(radius: 4)
                
                CanvasView(
                    canvasView: $canvasView,
                    currentTool: .constant(.pen),
                    currentColor: .constant(.black),
                    currentWidth: .constant(3.0)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .onChange(of: canvasView.drawing) { _ in
                    viewModel.challengeDrawing = canvasView.drawing
                    viewModel.updateCanContinue()
                }
            }
            .frame(height: 300)
        }
    }
}

// MARK: - View Model
@MainActor
final class LessonViewModel: ObservableObject {
    // Lesson data
    let lesson: Lesson
    @Published var currentExerciseIndex = 0
    
    // Progress tracking
    @Published var overallProgress: Double = 0
    @Published var exerciseProgress: Double = 0
    @Published var totalXPEarned = 0
    
    // Lives system
    @Published var totalHearts = 3
    @Published var currentHearts = 3
    
    // UI State
    @Published var showFeedback = false
    @Published var isCorrect = false
    @Published var feedbackTitle = ""
    @Published var feedbackMessage = ""
    @Published var canContinue = false
    @Published var showHint = false
    @Published var showCelebration = false
    @Published var showHeartLoss = false
    @Published var lessonComplete = false
    
    // Exercise state
    @Published var userAnswer: Any?
    @Published var attempts = 0
    
    // Drawing specific
    @Published var userDrawing = PKDrawing()
    
    // Theory specific
    @Published var selectedOptions: Set<String> = []
    @Published var draggedItems: [String: String] = [:]
    
    // Challenge specific
    @Published var challengeStartTime: Date?
    @Published var challengeDrawing = PKDrawing()
    
    var currentExercise: LessonExercise? {
        guard currentExerciseIndex < lesson.exercises.count else { return nil }
        return lesson.exercises[currentExerciseIndex]
    }
    
    var mainActionTitle: String {
        if showFeedback {
            return isCorrect ? "Continue" : "Got it"
        } else if canContinue {
            return "Check"
        } else {
            return "Continue"
        }
    }
    
    var hintsAvailable: Bool {
        guard let exercise = currentExercise else { return false }
        return !exercise.hints.isEmpty && attempts > 0
    }
    
    var canSkip: Bool {
        currentHearts < totalHearts && currentExerciseIndex < lesson.exercises.count - 1
    }
    
    var perfectScore: Bool {
        currentHearts == totalHearts
    }
    
    init(lesson: Lesson) {
        self.lesson = lesson
        self.totalHearts = lesson.hearts
        self.currentHearts = lesson.hearts
        startExercise()
    }
    
    // MARK: - Actions
    func handleMainAction() {
        if showFeedback {
            if isCorrect || currentHearts == 0 {
                nextExercise()
            } else {
                resetForRetry()
            }
        } else if canContinue {
            checkAnswer()
        }
    }
    
    func checkAnswer() {
        guard let exercise = currentExercise else { return }
        
        let result = validateAnswer(for: exercise)
        isCorrect = result.isCorrect
        feedbackTitle = result.title
        feedbackMessage = result.message
        
        withAnimation(.spring(response: 0.5)) {
            showFeedback = true
        }
        
        if isCorrect {
            totalXPEarned += exercise.xpValue
            Task {
                await HapticManager.shared.notification(.success)
            }
            
            exerciseProgress = 1.0
            updateOverallProgress()
        } else {
            attempts += 1
            if attempts >= exercise.validation.maxAttempts {
                loseHeart()
            }
            Task {
                await HapticManager.shared.notification(.error)
            }
        }
    }
    
    func tryAgain() {
        resetForRetry()
    }
    
    func useHint() {
        withAnimation {
            showHint = true
        }
    }
    
    func skipExercise() {
        loseHeart()
        if currentHearts > 0 {
            nextExercise()
        }
    }
    
    func reportProblem() {
        // Implementation for reporting issues
    }
    
    func quitLesson() {
        // Save progress
    }
    
    func updateCanContinue() {
        guard let exercise = currentExercise else {
            canContinue = false
            return
        }
        
        switch exercise.content {
        case .drawing(_):
            canContinue = !userDrawing.strokes.isEmpty
        case .theory(_):
            canContinue = !selectedOptions.isEmpty
        case .challenge(_):
            canContinue = !challengeDrawing.strokes.isEmpty
        }
    }
    
    // MARK: - Private Methods
    private func startExercise() {
        guard let exercise = currentExercise else { return }
        
        showFeedback = false
        isCorrect = false
        showHint = false
        attempts = 0
        exerciseProgress = 0
        userAnswer = nil
        selectedOptions.removeAll()
        draggedItems.removeAll()
        userDrawing = PKDrawing()
        challengeDrawing = PKDrawing()
        
        switch exercise.content {
        case .challenge(_):
            challengeStartTime = Date()
        default:
            break
        }
        
        updateCanContinue()
    }
    
    private func nextExercise() {
        if currentExerciseIndex < lesson.exercises.count - 1 {
            currentExerciseIndex += 1
            startExercise()
        } else {
            completeLesson()
        }
    }
    
    private func resetForRetry() {
        withAnimation {
            showFeedback = false
            canContinue = false
            showHint = false
        }
    }
    
    private func loseHeart() {
        currentHearts -= 1
        showHeartLoss = true
        Task {
            await HapticManager.shared.notification(.warning)
        }
        
        if currentHearts == 0 {
            feedbackTitle = "Out of hearts!"
            feedbackMessage = "Practice makes perfect. Try this lesson again!"
            showFeedback = true
        }
    }
    
    private func completeLesson() {
        showCelebration = true
        lessonComplete = true
        Task {
            await HapticManager.shared.notification(.success)
        }
    }
    
    private func updateOverallProgress() {
        let completedExercises = Double(currentExerciseIndex) + (isCorrect ? 1.0 : 0.0)
        overallProgress = completedExercises / Double(lesson.exercises.count)
    }
    
    private func validateAnswer(for exercise: LessonExercise) -> (isCorrect: Bool, title: String, message: String) {
        switch exercise.content {
        case .drawing(_):
            let strokeCount = userDrawing.strokes.count
            let hasContent = strokeCount > 0
            
            if hasContent {
                let score = min(1.0, Double(strokeCount) / 10.0)
                if score >= exercise.validation.minScore {
                    return (true, "Great job!", "Your drawing looks fantastic!")
                } else {
                    return (false, "Keep trying!", "Add more detail to your drawing")
                }
            }
            
            return (false, "Draw something!", "Use your finger or Apple Pencil to draw")
            
        case .theory(let theoryExercise):
            switch theoryExercise.correctAnswer {
            case .single(let correctId):
                let isCorrect = selectedOptions.contains(correctId)
                return (
                    isCorrect,
                    isCorrect ? "Correct!" : "Not quite",
                    theoryExercise.explanation
                )
                
            case .multiple(let correctIds):
                let correctSet = Set(correctIds)
                let isCorrect = selectedOptions == correctSet
                return (
                    isCorrect,
                    isCorrect ? "Perfect!" : "Almost there",
                    theoryExercise.explanation
                )
                
            case .sequence(_):
                return (true, "Good!", theoryExercise.explanation)
                
            case .range(_, _):
                return (true, "Good!", theoryExercise.explanation)
            }
            
        case .challenge(_):
            let hasDrawing = !challengeDrawing.strokes.isEmpty
            
            if hasDrawing {
                return (true, "Creative work!", "You nailed the challenge!")
            }
            
            return (false, "Complete the challenge!", "Follow the instructions to finish")
        }
    }
}

// Extension for Color hex initialization
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
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
