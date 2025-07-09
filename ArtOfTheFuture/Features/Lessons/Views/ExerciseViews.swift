// MARK: - Exercise Type Views
// File: ArtOfTheFuture/Features/Lessons/Views/ExerciseViews.swift

import SwiftUI
import PencilKit

// MARK: - Drawing Exercise View
struct DrawingExerciseView: View {
    let exercise: DrawingExercise
    @ObservedObject var viewModel: DuolingoLessonViewModel
    @State private var canvasView = PKCanvasView()
    @State private var currentTool: DrawingTool = .pen
    @State private var currentColor = Color.black
    @State private var currentWidth: CGFloat = 3.0
    @State private var showGuidelines = true
    
    var body: some View {
        VStack(spacing: 16) {
            // Reference image or animation
            if let referenceImage = exercise.referenceImage {
                Image(referenceImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 150)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            }
            
            // Drawing canvas
            ZStack {
                // Canvas background
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: exercise.canvas.backgroundColor) ?? .white)
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                
                // Grid overlay
                if exercise.canvas.gridEnabled {
                    GridOverlay(
                        gridSize: exercise.canvas.gridSize ?? 20,
                        canvasSize: CGSize(
                            width: exercise.canvas.width,
                            height: exercise.canvas.height
                        )
                    )
                }
                
                // Guidelines
                if showGuidelines, let guidelines = exercise.guidelines {
                    GuidelinesLayer(
                        guidelines: guidelines,
                        canvasSize: CGSize(
                            width: exercise.canvas.width,
                            height: exercise.canvas.height
                        )
                    )
                }
                
                // Canvas view
                CanvasViewBridge(
                    canvasView: $canvasView,
                    drawing: $viewModel.userDrawing,
                    currentTool: currentTool,
                    currentColor: currentColor,
                    currentWidth: currentWidth,
                    onChange: {
                        viewModel.updateCanContinue()
                    }
                )
            }
            .frame(
                width: min(exercise.canvas.width, UIScreen.main.bounds.width - 40),
                height: exercise.canvas.height
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            // Drawing tools
            DrawingToolBar(
                currentTool: $currentTool,
                currentColor: $currentColor,
                currentWidth: $currentWidth,
                showGuidelines: $showGuidelines,
                allowedTools: exercise.toolsAllowed,
                onClear: {
                    canvasView.drawing = PKDrawing()
                    viewModel.userDrawing = PKDrawing()
                },
                onUndo: {
                    canvasView.undoManager?.undo()
                }
            )
            
            // Time limit indicator
            if let timeLimit = exercise.timeLimit {
                TimeLimitIndicator(
                    timeLimit: timeLimit,
                    onTimeUp: {
                        viewModel.checkAnswer()
                    }
                )
            }
        }
    }
}

// MARK: - Theory Exercise View
struct TheoryExerciseView: View {
    let exercise: TheoryExercise
    @ObservedObject var viewModel: DuolingoLessonViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Visual aid
            if let visualAid = exercise.visualAid {
                Image(visualAid)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
            }
            
            // Question
            Text(exercise.question)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Interaction area
            switch exercise.interactionType {
            case .multipleChoice:
                MultipleChoiceView(
                    options: exercise.options,
                    selectedOptions: $viewModel.selectedOptions,
                    correctAnswer: exercise.correctAnswer,
                    showFeedback: viewModel.showFeedback
                )
                
            case .tapAreas:
                TapAreasView(
                    visualAid: exercise.visualAid ?? "",
                    options: exercise.options,
                    selectedOptions: $viewModel.selectedOptions,
                    showFeedback: viewModel.showFeedback
                )
                
            case .dragToMatch:
                DragToMatchView(
                    options: exercise.options,
                    draggedItems: $viewModel.draggedItems,
                    showFeedback: viewModel.showFeedback
                )
                
            case .orderSequence:
                OrderSequenceView(
                    options: exercise.options,
                    draggedItems: $viewModel.draggedItems,
                    showFeedback: viewModel.showFeedback
                )
                
            case .slider:
                SliderInteractionView(
                    options: exercise.options,
                    correctAnswer: exercise.correctAnswer,
                    showFeedback: viewModel.showFeedback
                )
            }
        }
        .onChange(of: viewModel.selectedOptions) { _ in
            viewModel.updateCanContinue()
        }
        .onChange(of: viewModel.draggedItems) { _ in
            viewModel.updateCanContinue()
        }
    }
}

// MARK: - Challenge Exercise View
struct ChallengeExerciseView: View {
    let exercise: ChallengeExercise
    @ObservedObject var viewModel: DuolingoLessonViewModel
    @State private var canvasView = PKCanvasView()
    @State private var showResources = true
    
    var body: some View {
        VStack(spacing: 16) {
            // Challenge prompt
            Text(exercise.prompt)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            
            // Resources (if any)
            if showResources && !exercise.resources.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(exercise.resources, id: \.self) { resource in
                            ResourceCard(resourceName: resource)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Challenge-specific content
            switch exercise.challengeType {
            case .completeHalfDrawing:
                CompleteHalfDrawingView(
                    resources: exercise.resources,
                    canvasView: $canvasView,
                    drawing: $viewModel.challengeDrawing
                )
                
            case .transformShape:
                TransformShapeView(
                    canvasView: $canvasView,
                    drawing: $viewModel.challengeDrawing
                )
                
            case .speedSketch:
                SpeedSketchView(
                    prompt: exercise.prompt,
                    timeLimit: exercise.constraints.timeLimit ?? 60,
                    canvasView: $canvasView,
                    drawing: $viewModel.challengeDrawing
                )
                
            case .memoryRecreation:
                MemoryRecreationView(
                    resources: exercise.resources,
                    canvasView: $canvasView,
                    drawing: $viewModel.challengeDrawing
                )
                
            case .styleMimic:
                StyleMimicView(
                    resources: exercise.resources,
                    canvasView: $canvasView,
                    drawing: $viewModel.challengeDrawing
                )
                
            case .findMistakes:
                FindMistakesView(
                    resources: exercise.resources,
                    viewModel: viewModel
                )
                
            case .composition:
                CompositionChallengeView(
                    prompt: exercise.prompt,
                    canvasView: $canvasView,
                    drawing: $viewModel.challengeDrawing
                )
            }
            
            // Constraints indicator
            ConstraintsIndicator(constraints: exercise.constraints)
        }
        .onChange(of: viewModel.challengeDrawing) { _ in
            viewModel.updateCanContinue()
        }
    }
}

// MARK: - Supporting Components

struct GridOverlay: View {
    let gridSize: CGFloat
    let canvasSize: CGSize
    
    var body: some View {
        Canvas { context, size in
            let columns = Int(canvasSize.width / gridSize)
            let rows = Int(canvasSize.height / gridSize)
            
            // Vertical lines
            for i in 0...columns {
                let x = CGFloat(i) * gridSize
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: canvasSize.height))
                    },
                    with: .color(.gray.opacity(0.2)),
                    lineWidth: 0.5
                )
            }
            
            // Horizontal lines
            for i in 0...rows {
                let y = CGFloat(i) * gridSize
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: canvasSize.width, y: y))
                    },
                    with: .color(.gray.opacity(0.2)),
                    lineWidth: 0.5
                )
            }
        }
    }
}

struct GuidelinesLayer: View {
    let guidelines: [DrawingGuideline]
    let canvasSize: CGSize
    @State private var animationProgress: CGFloat = 0
    
    var body: some View {
        Canvas { context, size in
            for guideline in guidelines {
                drawGuideline(guideline, in: context, progress: animationProgress)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: true)) {
                animationProgress = 1.0
            }
        }
    }
    
    private func drawGuideline(_ guideline: DrawingGuideline, in context: GraphicsContext, progress: CGFloat) {
        let color = Color(hex: guideline.style.color) ?? .blue
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
                let radius = guideline.path[0].distance(to: guideline.path[1])
                path.addEllipse(in: CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: radius * 2,
                    height: radius * 2
                ))
            }
            
        case .curve:
            if !guideline.path.isEmpty {
                path.move(to: guideline.path[0])
                for i in 1..<guideline.path.count {
                    path.addLine(to: guideline.path[i])
                }
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
            
        default:
            break
        }
        
        var strokeStyle = StrokeStyle(
            lineWidth: guideline.style.width,
            dash: guideline.style.dashPattern ?? []
        )
        
        if guideline.style.animated {
            strokeStyle.dashPhase = -20 * progress
        }
        
        context.stroke(
            path,
            with: .color(color.opacity(guideline.style.opacity)),
            style: strokeStyle
        )
    }
}

struct CanvasViewBridge: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var drawing: PKDrawing
    let currentTool: DrawingTool
    let currentColor: Color
    let currentWidth: CGFloat
    let onChange: () -> Void
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.delegate = context.coordinator
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        updateTool()
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        updateTool()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func updateTool() {
        let tool = currentTool.pkTool(
            color: UIColor(currentColor),
            width: currentWidth
        )
        canvasView.tool = tool
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        let parent: CanvasViewBridge
        
        init(_ parent: CanvasViewBridge) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
            parent.onChange()
        }
    }
}

struct DrawingToolBar: View {
    @Binding var currentTool: DrawingTool
    @Binding var currentColor: Color
    @Binding var currentWidth: CGFloat
    @Binding var showGuidelines: Bool
    let allowedTools: [DrawingTool]
    let onClear: () -> Void
    let onUndo: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Tools
            HStack(spacing: 12) {
                ForEach(allowedTools, id: \.self) { tool in
                    ToolButton(
                        tool: tool,
                        isSelected: currentTool == tool,
                        action: {
                            currentTool = tool
                            HapticManager.shared.selection()
                        }
                    )
                }
                
                Spacer()
                
                // Actions
                Button(action: onUndo) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.title3)
                        .frame(width: 36, height: 36)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
                
                Button(action: onClear) {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundColor(.red)
                        .frame(width: 36, height: 36)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
            }
            
            // Color and width controls
            HStack(spacing: 16) {
                // Color picker
                ColorPicker("", selection: $currentColor)
                    .labelsHidden()
                    .frame(width: 36, height: 36)
                
                // Width slider
                HStack {
                    Image(systemName: "pencil.tip")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Slider(value: $currentWidth, in: 1...20)
                        .tint(.primary)
                    
                    Text("\(Int(currentWidth))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 25)
                }
                
                // Guidelines toggle
                Button(action: { showGuidelines.toggle() }) {
                    Image(systemName: showGuidelines ? "eye.fill" : "eye.slash")
                        .font(.title3)
                        .foregroundColor(showGuidelines ? .blue : .gray)
                        .frame(width: 36, height: 36)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

struct ToolButton: View {
    let tool: DrawingTool
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
            .frame(width: 50, height: 50)
            .background(isSelected ? Color.blue : Color(.systemGray5))
            .cornerRadius(12)
        }
    }
}

// MARK: - Theory Exercise Components

struct MultipleChoiceView: View {
    let options: [TheoryExercise.TheoryOption]
    @Binding var selectedOptions: Set<String>
    let correctAnswer: TheoryExercise.CorrectAnswer
    let showFeedback: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(options) { option in
                MultipleChoiceOption(
                    option: option,
                    isSelected: selectedOptions.contains(option.id),
                    isCorrect: isCorrectOption(option.id),
                    showFeedback: showFeedback,
                    allowsMultiple: allowsMultipleSelection,
                    action: {
                        toggleOption(option.id)
                    }
                )
            }
        }
        .padding(.horizontal)
    }
    
    private var allowsMultipleSelection: Bool {
        if case .multiple(_) = correctAnswer {
            return true
        }
        return false
    }
    
    private func toggleOption(_ id: String) {
        if allowsMultipleSelection {
            if selectedOptions.contains(id) {
                selectedOptions.remove(id)
            } else {
                selectedOptions.insert(id)
            }
        } else {
            selectedOptions = [id]
        }
        HapticManager.shared.selection()
    }
    
    private func isCorrectOption(_ id: String) -> Bool {
        switch correctAnswer {
        case .single(let correctId):
            return id == correctId
        case .multiple(let correctIds):
            return correctIds.contains(id)
        default:
            return false
        }
    }
}

struct MultipleChoiceOption: View {
    let option: TheoryExercise.TheoryOption
    let isSelected: Bool
    let isCorrect: Bool
    let showFeedback: Bool
    let allowsMultiple: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                // Selection indicator
                Image(systemName: selectionIcon)
                    .font(.title3)
                    .foregroundColor(iconColor)
                
                // Content
                switch option.content {
                case .text(let text):
                    Text(text)
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                case .image(let imageName):
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 60)
                    
                case .colorSwatch(let hex):
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: hex) ?? .gray)
                        .frame(width: 60, height: 40)
                    
                case .diagram(let data):
                    // Custom diagram view
                    Text("Diagram")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Feedback icon
                if showFeedback {
                    Image(systemName: feedbackIcon)
                        .font(.title3)
                        .foregroundColor(feedbackColor)
                }
            }
            .padding()
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: 2)
            )
            .cornerRadius(16)
        }
        .disabled(showFeedback)
    }
    
    private var selectionIcon: String {
        if allowsMultiple {
            return isSelected ? "checkmark.square.fill" : "square"
        } else {
            return isSelected ? "circle.fill" : "circle"
        }
    }
    
    private var iconColor: Color {
        if showFeedback {
            return isSelected && isCorrect ? .green : (isSelected ? .red : .gray)
        }
        return isSelected ? .blue : .gray
    }
    
    private var backgroundColor: Color {
        if showFeedback {
            if isSelected && !isCorrect {
                return Color.red.opacity(0.1)
            } else if isCorrect {
                return Color.green.opacity(0.1)
            }
        }
        return isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6)
    }
    
    private var borderColor: Color {
        if showFeedback {
            if isSelected && !isCorrect {
                return .red
            } else if isCorrect {
                return .green
            }
        }
        return isSelected ? .blue : Color.clear
    }
    
    private var feedbackIcon: String {
        if isCorrect {
            return "checkmark.circle.fill"
        } else if isSelected {
            return "xmark.circle.fill"
        }
        return ""
    }
    
    private var feedbackColor: Color {
        isCorrect ? .green : .red
    }
}

// MARK: - Challenge Components

struct CompleteHalfDrawingView: View {
    let resources: [String]
    @Binding var canvasView: PKCanvasView
    @Binding var drawing: PKDrawing
    
    var body: some View {
        ZStack {
            // Half drawing template
            if let templateName = resources.first {
                Image(templateName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.3)
            }
            
            // User's drawing
            CanvasViewBridge(
                canvasView: $canvasView,
                drawing: $drawing,
                currentTool: .pen,
                currentColor: .black,
                currentWidth: 3,
                onChange: { }
            )
        }
        .frame(height: 300)
        .background(Color.white)
        .cornerRadius(16)
    }
}

struct SpeedSketchView: View {
    let prompt: String
    let timeLimit: TimeInterval
    @Binding var canvasView: PKCanvasView
    @Binding var drawing: PKDrawing
    @State private var timeRemaining: TimeInterval
    @State private var timer: Timer?
    
    init(prompt: String, timeLimit: TimeInterval, canvasView: Binding<PKCanvasView>, drawing: Binding<PKDrawing>) {
        self.prompt = prompt
        self.timeLimit = timeLimit
        self._canvasView = canvasView
        self._drawing = drawing
        self._timeRemaining = State(initialValue: timeLimit)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Timer display
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(timeRemaining < 10 ? .red : .primary)
                
                Text(String(format: "%02d:%02d", Int(timeRemaining) / 60, Int(timeRemaining) % 60))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(timeRemaining < 10 ? .red : .primary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Canvas
            CanvasViewBridge(
                canvasView: $canvasView,
                drawing: $drawing,
                currentTool: .pen,
                currentColor: .black,
                currentWidth: 3,
                onChange: { }
            )
            .frame(height: 300)
            .background(Color.white)
            .cornerRadius(16)
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                
                if timeRemaining == 10 {
                    HapticManager.shared.notification(.warning)
                } else if timeRemaining == 0 {
                    HapticManager.shared.notification(.error)
                    timer?.invalidate()
                }
            }
        }
    }
}

// MARK: - Helper Components

struct TimeLimitIndicator: View {
    let timeLimit: TimeInterval
    let onTimeUp: () -> Void
    @State private var timeRemaining: TimeInterval
    @State private var timer: Timer?
    
    init(timeLimit: TimeInterval, onTimeUp: @escaping () -> Void) {
        self.timeLimit = timeLimit
        self.onTimeUp = onTimeUp
        self._timeRemaining = State(initialValue: timeLimit)
    }
    
    var body: some View {
        HStack {
            Image(systemName: "clock")
                .foregroundColor(timeRemaining < 10 ? .red : .secondary)
            
            Text("Time: \(Int(timeRemaining))s")
                .font(.caption)
                .foregroundColor(timeRemaining < 10 ? .red : .secondary)
            
            Spacer()
        }
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timer?.invalidate()
                    onTimeUp()
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
}

struct ConstraintsIndicator: View {
    let constraints: ChallengeExercise.ChallengeConstraints
    
    var body: some View {
        HStack(spacing: 16) {
            if let timeLimit = constraints.timeLimit {
                Label("\(Int(timeLimit))s", systemImage: "timer")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let strokeLimit = constraints.strokeLimit {
                Label("\(strokeLimit) strokes", systemImage: "scribble")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let palette = constraints.colorPalette, !palette.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "paintpalette")
                        .font(.caption)
                    
                    ForEach(palette.prefix(5), id: \.self) { hex in
                        Circle()
                            .fill(Color(hex: hex) ?? .gray)
                            .frame(width: 12, height: 12)
                    }
                }
                .foregroundColor(.secondary)
            }
        }
    }
}

struct ResourceCard: View {
    let resourceName: String
    
    var body: some View {
        Image(resourceName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 100, height: 100)
            .clipped()
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}

// Additional exercise type views would go here...
// (TapAreasView, DragToMatchView, OrderSequenceView, etc.)

// MARK: - Color Extension
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

// MARK: - CGPoint Extension
extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
}
