// MARK: - Interactive Lesson Player View
// File: ArtOfTheFuture/Features/Lessons/LessonPlayerView.swift

import SwiftUI
import PencilKit

struct LessonPlayerView: View {
    @StateObject private var viewModel: LessonPlayerViewModel
    @State private var showingExitAlert = false
    @State private var showingHints = false
    @Environment(\.dismiss) private var dismiss
    
    init(lesson: InteractiveLesson) {
        _viewModel = StateObject(wrappedValue: LessonPlayerViewModel(lesson: lesson))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with progress
                    lessonHeader
                    
                    // Main content area
                    switch viewModel.currentStep?.type {
                    case .introduction:
                        IntroductionStepView(step: viewModel.currentStep!, viewModel: viewModel)
                    case .demonstration:
                        DemonstrationStepView(step: viewModel.currentStep!, viewModel: viewModel)
                    case .guidedPractice, .freePractice:
                        DrawingStepView(step: viewModel.currentStep!, viewModel: viewModel)
                    case .assessment:
                        AssessmentStepView(step: viewModel.currentStep!, viewModel: viewModel)
                    case .none:
                        EmptyView()
                    }
                    
                    // Bottom controls
                    lessonControls
                }
                
                // Floating elements
                if showingHints {
                    HintsOverlay(step: viewModel.currentStep!) {
                        showingHints = false
                    }
                }
                
                // Validation feedback
                if !viewModel.mistakes.isEmpty {
                    ValidationFeedbackView(errors: viewModel.mistakes)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.startLesson()
        }
        .alert("Exit Lesson?", isPresented: $showingExitAlert) {
            Button("Exit", role: .destructive) { dismiss() }
            Button("Continue", role: .cancel) { }
        } message: {
            Text("Your progress will be saved, but you'll need to restart this step.")
        }
    }
    
    // MARK: - Header
    private var lessonHeader: some View {
        VStack(spacing: 12) {
            // Top bar with exit and settings
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
                
                // Lesson title
                Text(viewModel.currentLesson.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { showingHints.toggle() }) {
                    Image(systemName: "lightbulb")
                        .font(.title2)
                        .foregroundColor(.yellow)
                        .frame(width: 44, height: 44)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            
            // Progress bar
            VStack(spacing: 8) {
                HStack {
                    Text("Step \(viewModel.currentStepIndex + 1) of \(viewModel.currentLesson.steps.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if let step = viewModel.currentStep {
                        Label("\(Int(step.duration/60))m", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Overall progress
                ProgressView(value: viewModel.overallProgress)
                    .progressViewStyle(LessonProgressStyle())
                
                // Step progress (if in practice mode)
                if viewModel.currentStep?.type == .guidedPractice || viewModel.currentStep?.type == .freePractice {
                    HStack {
                        Text("Step Progress")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(viewModel.stepProgress * 100))%")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                    
                    ProgressView(value: viewModel.stepProgress)
                        .progressViewStyle(StepProgressStyle())
                        .animation(.easeInOut(duration: 0.3), value: viewModel.stepProgress)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Controls
    private var lessonControls: some View {
        VStack(spacing: 16) {
            // Current step info
            if let step = viewModel.currentStep {
                VStack(spacing: 8) {
                    Text(step.title)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    
                    Text(step.instruction)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
                .padding(.horizontal)
            }
            
            // Action buttons
            HStack(spacing: 16) {
                if viewModel.currentStepIndex > 0 {
                    Button(action: viewModel.previousStep) {
                        Label("Previous", systemImage: "chevron.left")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
                
                Button(action: {
                    if viewModel.isLastStep {
                        // Complete lesson
                        dismiss()
                    } else {
                        viewModel.nextStep()
                    }
                }) {
                    HStack {
                        Text(viewModel.isLastStep ? "Complete" : "Continue")
                        if !viewModel.isLastStep {
                            Image(systemName: "chevron.right")
                        } else {
                            Image(systemName: "checkmark")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canProceed ? Color.accentColor : Color(.systemGray4))
                    .foregroundColor(canProceed ? .white : .secondary)
                    .cornerRadius(12)
                }
                .disabled(!canProceed)
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(.ultraThinMaterial)
    }
    
    private var canProceed: Bool {
        guard let step = viewModel.currentStep else { return false }
        
        switch step.type {
        case .introduction, .demonstration:
            return true
        case .guidedPractice, .freePractice:
            return viewModel.stepProgress >= step.successCriteria.minimumScore
        case .assessment:
            return viewModel.currentScore >= step.successCriteria.minimumScore
        }
    }
}

// MARK: - Step Views
struct IntroductionStepView: View {
    let step: LessonStep
    @ObservedObject var viewModel: LessonPlayerViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hero image or animation
                if let imageName = step.referenceImage {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .cornerRadius(16)
                        .shadow(radius: 4)
                } else {
                    Image(systemName: "paintbrush.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .frame(height: 200)
                }
                
                // Instruction text
                VStack(spacing: 16) {
                    Text(step.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(step.instruction)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                
                // Learning objectives
                if !viewModel.currentLesson.learningObjectives.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What you'll learn:")
                            .font(.headline)
                        
                        ForEach(viewModel.currentLesson.learningObjectives, id: \.self) { objective in
                            HStack(spacing: 12) {
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
            .padding()
        }
    }
}

struct DemonstrationStepView: View {
    let step: LessonStep
    @ObservedObject var viewModel: LessonPlayerViewModel
    @State private var isPlaying = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Demo area
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(radius: 4)
                
                if let animationName = step.animatedDemo {
                    // Lottie animation would go here
                    VStack {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        Text("Tap to play demo")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .onTapGesture {
                        isPlaying.toggle()
                    }
                } else if let imageName = step.referenceImage {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                }
            }
            .frame(height: 300)
            
            // Instructions
            Text(step.instruction)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }
}

struct DrawingStepView: View {
    let step: LessonStep
    @ObservedObject var viewModel: LessonPlayerViewModel
    @State private var canvasView = PKCanvasView()
    
    var body: some View {
        VStack(spacing: 16) {
            // Drawing canvas with guidelines
            ZStack {
                // Canvas background
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(radius: 4)
                
                // Guidelines overlay
                if viewModel.showGuidelines, let guidelines = step.guideLines {
                    GuidelinesOverlay(guidelines: guidelines)
                }
                
                // Drawing canvas
                CanvasView(
                    canvasView: $canvasView,
                    currentTool: .constant(.pen),
                    currentColor: .constant(.black),
                    currentWidth: .constant(3.0)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .onChange(of: canvasView.drawing) { _ in
                    viewModel.userDrawing = canvasView.drawing
                    viewModel.validateDrawing()
                }
            }
            .frame(minHeight: 300)
            
            // Drawing tools
            HStack(spacing: 16) {
                Button(action: {
                    canvasView.drawing = PKDrawing()
                    viewModel.resetCurrentStep()
                }) {
                    Image(systemName: "trash")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
                
                Button(action: {
                    canvasView.undoManager?.undo()
                }) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.showGuidelines.toggle()
                }) {
                    Image(systemName: viewModel.showGuidelines ? "eye.fill" : "eye.slash")
                        .font(.title2)
                        .foregroundColor(viewModel.showGuidelines ? .blue : .gray)
                        .frame(width: 44, height: 44)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct AssessmentStepView: View {
    let step: LessonStep
    @ObservedObject var viewModel: LessonPlayerViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Assessment content
            Text("Assessment Step")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(step.instruction)
                .font(.body)
                .multilineTextAlignment(.center)
            
            // Score display
            VStack(spacing: 8) {
                Text("Current Score")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(Int(viewModel.currentScore * 100))%")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(scoreColor(viewModel.currentScore))
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding()
    }
    
    private func scoreColor(_ score: Double) -> Color {
        switch score {
        case 0.8...: return .green
        case 0.6...: return .orange
        default: return .red
        }
    }
}

// MARK: - Supporting Views
struct GuidelinesOverlay: View {
    let guidelines: [GuideLine]
    
    var body: some View {
        Canvas { context, size in
            for guideline in guidelines {
                drawGuideline(guideline, in: context, size: size)
            }
        }
    }
    
    private func drawGuideline(_ guideline: GuideLine, in context: GraphicsContext, size: CGSize) {
        let color = Color(hex: guideline.style.color) ?? .blue
        let path = createPath(for: guideline, in: size)
        
        context.stroke(
            path,
            with: .color(color.opacity(guideline.style.opacity)),
            style: StrokeStyle(
                lineWidth: guideline.style.width,
                dash: guideline.style.dashPattern ?? []
            )
        )
    }
    
    private func createPath(for guideline: GuideLine, in size: CGSize) -> Path {
        var path = Path()
        
        switch guideline.type {
        case .line:
            if guideline.points.count >= 2 {
                path.move(to: guideline.points[0])
                path.addLine(to: guideline.points[1])
            }
        case .circle:
            if guideline.points.count >= 2 {
                let center = guideline.points[0]
                let radius = center.distance(to: guideline.points[1])
                path.addEllipse(in: CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: radius * 2,
                    height: radius * 2
                ))
            }
        case .curve, .freeform:
            if !guideline.points.isEmpty {
                path.move(to: guideline.points[0])
                for point in guideline.points.dropFirst() {
                    path.addLine(to: point)
                }
            }
        case .rectangle:
            if guideline.points.count >= 2 {
                let rect = CGRect(
                    x: min(guideline.points[0].x, guideline.points[1].x),
                    y: min(guideline.points[0].y, guideline.points[1].y),
                    width: abs(guideline.points[1].x - guideline.points[0].x),
                    height: abs(guideline.points[1].y - guideline.points[0].y)
                )
                path.addRect(rect)
            }
        }
        
        return path
    }
}

struct ValidationFeedbackView: View {
    let errors: [ValidationError]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(errors) { error in
                HStack {
                    Image(systemName: iconForError(error))
                        .foregroundColor(colorForError(error))
                    
                    Text(error.message)
                        .font(.caption)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(backgroundForError(error))
                .cornerRadius(8)
            }
        }
        .padding()
    }
    
    private func iconForError(_ error: ValidationError) -> String {
        switch error.severity {
        case .info: return "info.circle"
        case .warning: return "exclamationmark.triangle"
        case .error: return "xmark.circle"
        }
    }
    
    private func colorForError(_ error: ValidationError) -> Color {
        switch error.severity {
        case .info: return .blue
        case .warning: return .orange
        case .error: return .red
        }
    }
    
    private func backgroundForError(_ error: ValidationError) -> Color {
        switch error.severity {
        case .info: return .blue.opacity(0.1)
        case .warning: return .orange.opacity(0.1)
        case .error: return .red.opacity(0.1)
        }
    }
}

struct HintsOverlay: View {
    let step: LessonStep
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)
            
            VStack(spacing: 20) {
                Text("💡 Hints")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Try drawing slowly and follow the guidelines closely.")
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Button("Got it!", action: onDismiss)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .padding()
        }
    }
}

// MARK: - Progress Styles
struct LessonProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: geometry.size.width * (configuration.fractionCompleted ?? 0), height: 8)
                    .animation(.easeInOut(duration: 0.5), value: configuration.fractionCompleted)
            }
        }
        .frame(height: 8)
    }
}

struct StepProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(.systemGray6))
                    .frame(height: 4)
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.blue)
                    .frame(width: geometry.size.width * (configuration.fractionCompleted ?? 0), height: 4)
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Extensions
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

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
}
