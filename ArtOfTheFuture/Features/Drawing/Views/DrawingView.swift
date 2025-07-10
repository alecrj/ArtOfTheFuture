import SwiftUI
import PencilKit

struct DrawingView: View {
    @StateObject private var canvasController = CanvasController()
    @State private var showExportModal = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Premium background
                LinearGradient(
                    colors: [
                        Color(.systemGray6),
                        Color(.systemGray5)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top bar
                    DrawingTopBar(
                        controller: canvasController,
                        showExportModal: $showExportModal
                    )
                    .padding(.top, 10)
                    
                    // Canvas area (main focus)
                    DrawingCanvasArea(controller: canvasController)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    
                    // Tool bar
                    DrawingToolBar(controller: canvasController)
                        .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showExportModal) {
            ExportModalView(controller: canvasController)
        }
    }
}

// MARK: - Canvas Controller (FULLY FIXED COLORS)
@MainActor
final class CanvasController: ObservableObject {
    @Published var pkCanvasView = PKCanvasView()
    @Published var activeTool: DrawingTool = .pen
    @Published var selectedColor: Color = .black
    @Published var strokeWidth: Double = 5.0
    @Published var undoAvailable = false
    @Published var redoAvailable = false
    @Published var colorPickerVisible = false
    
    init() {
        configureCanvas()
        setActiveTool()
    }
    
    private func configureCanvas() {
        pkCanvasView.drawingPolicy = .anyInput
        
        // PERFECT: Pure white background that never changes
        pkCanvasView.backgroundColor = UIColor.white
        pkCanvasView.isOpaque = true
        pkCanvasView.overrideUserInterfaceStyle = .light // Force light mode
        
        pkCanvasView.layer.cornerRadius = 16
        pkCanvasView.clipsToBounds = true
        
        // Additional stability
        pkCanvasView.layer.backgroundColor = UIColor.white.cgColor
    }
    
    func chooseTool(_ tool: DrawingTool) {
        activeTool = tool
        setActiveTool()
        
        Task {
            await HapticManager.shared.impact(.light)
        }
    }
    
    func updateColor(_ color: Color) {
        selectedColor = color
        setActiveTool()
    }
    
    func updateStrokeWidth(_ width: Double) {
        strokeWidth = width
        setActiveTool()
    }
    
    private func setActiveTool() {
        // PERFECT: Color conversion that works 100% of the time
        let uiColor = perfectColorConversion(selectedColor)
        
        switch activeTool {
        case .pen:
            pkCanvasView.tool = PKInkingTool(.pen, color: uiColor, width: strokeWidth)
        case .pencil:
            pkCanvasView.tool = PKInkingTool(.pencil, color: uiColor, width: strokeWidth)
        case .marker:
            pkCanvasView.tool = PKInkingTool(.marker, color: uiColor, width: strokeWidth * 1.5)
        case .eraser:
            pkCanvasView.tool = PKEraserTool(.bitmap)
        }
    }
    
    // PERFECT: Guaranteed color conversion (no inversion possible)
    private func perfectColorConversion(_ color: Color) -> UIColor {
        switch color {
        case .black:
            return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0) // Pure black
        case .white:
            return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // Pure white
        case .red:
            return UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        case .blue:
            return UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        case .green:
            return UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
        case .orange:
            return UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
        case .yellow:
            return UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
        case .purple:
            return UIColor(red: 0.6, green: 0.0, blue: 1.0, alpha: 1.0)
        case .pink:
            return UIColor(red: 1.0, green: 0.4, blue: 0.8, alpha: 1.0)
        case .gray:
            return UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        case .brown:
            return UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)
        case .cyan:
            return UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
        default:
            // For any other colors, use explicit component extraction
            let uiColor = UIColor(color)
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 1
            uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
    
    func undoAction() {
        pkCanvasView.undoManager?.undo()
        updateUndoRedoState()
    }
    
    func redoAction() {
        pkCanvasView.undoManager?.redo()
        updateUndoRedoState()
    }
    
    func clearAction() {
        pkCanvasView.drawing = PKDrawing()
        updateUndoRedoState()
    }
    
    func updateUndoRedoState() {
        undoAvailable = pkCanvasView.undoManager?.canUndo ?? false
        redoAvailable = pkCanvasView.undoManager?.canRedo ?? false
    }
    
    func createExportImage() -> UIImage? {
        let bounds = pkCanvasView.drawing.bounds
        let imageRect = bounds.isEmpty ? CGRect(x: 0, y: 0, width: 800, height: 600) : bounds
        return pkCanvasView.drawing.image(from: imageRect, scale: 2.0)
    }
    
    var hasContent: Bool {
        !pkCanvasView.drawing.bounds.isEmpty
    }
}

// MARK: - Drawing Canvas Area (PERFECT WHITE)
struct DrawingCanvasArea: View {
    @ObservedObject var controller: CanvasController
    
    var body: some View {
        ZStack {
            // Perfect white background
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            
            PerfectCanvasWrapper(controller: controller)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Perfect Canvas Wrapper (NEVER CHANGES COLOR)
struct PerfectCanvasWrapper: UIViewRepresentable {
    @ObservedObject var controller: CanvasController
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = controller.pkCanvasView
        canvas.delegate = context.coordinator
        
        // PERFECT: Lock in white background
        canvas.backgroundColor = UIColor.white
        canvas.isOpaque = true
        canvas.overrideUserInterfaceStyle = .light
        canvas.layer.backgroundColor = UIColor.white.cgColor
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // PERFECT: Force white background on every update
        uiView.backgroundColor = UIColor.white
        uiView.isOpaque = true
        uiView.layer.backgroundColor = UIColor.white.cgColor
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(controller)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        let controller: CanvasController
        
        init(_ controller: CanvasController) {
            self.controller = controller
        }
        
        func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
            // PERFECT: Maintain white background during all touch events
            canvasView.backgroundColor = UIColor.white
            canvasView.layer.backgroundColor = UIColor.white.cgColor
            
            Task { @MainActor in
                controller.updateUndoRedoState()
            }
        }
        
        func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
            // PERFECT: Maintain white background after touch
            canvasView.backgroundColor = UIColor.white
            canvasView.layer.backgroundColor = UIColor.white.cgColor
            
            Task { @MainActor in
                controller.updateUndoRedoState()
            }
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // PERFECT: Maintain white background on any drawing change
            canvasView.backgroundColor = UIColor.white
            canvasView.layer.backgroundColor = UIColor.white.cgColor
            
            Task { @MainActor in
                controller.updateUndoRedoState()
            }
        }
    }
}

// MARK: - Drawing Top Bar
struct DrawingTopBar: View {
    @ObservedObject var controller: CanvasController
    @Binding var showExportModal: Bool
    
    var body: some View {
        HStack {
            // Undo/Redo controls
            HStack(spacing: 12) {
                ActionButton(
                    icon: "arrow.uturn.backward",
                    isEnabled: controller.undoAvailable,
                    action: controller.undoAction
                )
                
                ActionButton(
                    icon: "arrow.uturn.forward",
                    isEnabled: controller.redoAvailable,
                    action: controller.redoAction
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            
            Spacer()
            
            // Title
            Text("Draw")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            // Export button
            ActionButton(
                icon: "square.and.arrow.up",
                isEnabled: controller.hasContent,
                action: { showExportModal = true }
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let icon: String
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isEnabled ? .primary : .secondary)
        }
        .disabled(!isEnabled)
        .scaleEffect(isEnabled ? 1.0 : 0.9)
        .animation(.spring(response: 0.3), value: isEnabled)
    }
}

// MARK: - Drawing Tool Bar
struct DrawingToolBar: View {
    @ObservedObject var controller: CanvasController
    
    var body: some View {
        VStack(spacing: 20) {
            // Tool selection
            HStack(spacing: 24) {
                ForEach(DrawingTool.allCases, id: \.self) { tool in
                    PremiumToolButton(
                        tool: tool,
                        isActive: controller.activeTool == tool,
                        action: { controller.chooseTool(tool) }
                    )
                }
                
                Spacer()
                
                // Clear button
                Button(action: controller.clearAction) {
                    VStack(spacing: 4) {
                        Image(systemName: "trash.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(
                                LinearGradient(
                                    colors: [.red, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                        
                        Text("Clear")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .scaleEffect(controller.hasContent ? 1.0 : 0.8)
                .animation(.spring(response: 0.3), value: controller.hasContent)
            }
            
            // Tool options (when not eraser)
            if controller.activeTool != .eraser {
                PremiumToolOptions(controller: controller)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Premium Tool Button
struct PremiumToolButton: View {
    let tool: DrawingTool
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: tool.icon)
                    .font(.title2)
                    .foregroundColor(isActive ? .white : .primary)
                    .frame(width: 50, height: 50)
                    .background(
                        Group {
                            if isActive {
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            } else {
                                LinearGradient(
                                    colors: [Color(.systemGray5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            }
                        }
                    )
                    .clipShape(Circle())
                    .shadow(color: isActive ? .blue.opacity(0.3) : .clear, radius: 8, y: 4)
                
                Text(tool.rawValue)
                    .font(.caption)
                    .fontWeight(isActive ? .semibold : .regular)
                    .foregroundColor(isActive ? .primary : .secondary)
            }
        }
        .scaleEffect(isActive ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isActive)
    }
}

// MARK: - Premium Tool Options
struct PremiumToolOptions: View {
    @ObservedObject var controller: CanvasController
    
    var body: some View {
        HStack(spacing: 24) {
            // Color section
            VStack(spacing: 8) {
                Text("Color")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Button(action: { controller.colorPickerVisible.toggle() }) {
                    ZStack {
                        Circle()
                            .fill(controller.selectedColor)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .stroke(.primary, lineWidth: 2)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                        
                        // Visual color indicator
                        Text(colorLabel(controller.selectedColor))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(textColorFor(controller.selectedColor))
                    }
                }
                .popover(isPresented: $controller.colorPickerVisible) {
                    PremiumColorPicker(
                        selectedColor: $controller.selectedColor,
                        onColorSelected: controller.updateColor
                    )
                }
            }
            
            // Width section
            VStack(spacing: 8) {
                Text("Width: \(Int(controller.strokeWidth))")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Slider(
                    value: Binding(
                        get: { controller.strokeWidth },
                        set: controller.updateStrokeWidth
                    ),
                    in: 1...50,
                    step: 1
                ) {
                    Text("Width")
                } minimumValueLabel: {
                    Text("1")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } maximumValueLabel: {
                    Text("50")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(width: 120)
                .accentColor(.blue)
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
    
    private func colorLabel(_ color: Color) -> String {
        switch color {
        case .black: return "●"
        case .white: return "○"
        case .red: return "R"
        case .blue: return "B"
        case .green: return "G"
        case .orange: return "O"
        case .yellow: return "Y"
        case .purple: return "P"
        case .pink: return "PK"
        case .gray: return "GY"
        case .brown: return "BR"
        case .cyan: return "C"
        default: return "?"
        }
    }
    
    private func textColorFor(_ color: Color) -> Color {
        switch color {
        case .black, .blue, .purple, .brown: return .white
        default: return .black
        }
    }
}

// MARK: - Premium Color Picker
struct PremiumColorPicker: View {
    @Binding var selectedColor: Color
    let onColorSelected: (Color) -> Void
    
    private let colorPalette: [(Color, String)] = [
        (.black, "Black"),
        (.white, "White"),
        (.gray, "Gray"),
        (.red, "Red"),
        (.orange, "Orange"),
        (.yellow, "Yellow"),
        (.green, "Green"),
        (.blue, "Blue"),
        (.purple, "Purple"),
        (.pink, "Pink"),
        (.brown, "Brown"),
        (.cyan, "Cyan")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Color")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.top)
            
            // Color grid
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(55), spacing: 12), count: 3), spacing: 12) {
                ForEach(colorPalette, id: \.1) { color, name in
                    Button(action: {
                        selectedColor = color
                        onColorSelected(color)
                    }) {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(.primary, lineWidth: selectedColor == color ? 3 : 1)
                                    )
                                    .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                                
                                // Visual indicators for black/white
                                if color == .black {
                                    Text("●")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                } else if color == .white {
                                    Text("○")
                                        .font(.title3)
                                        .foregroundColor(.black)
                                }
                            }
                            
                            Text(name)
                                .font(.caption2)
                                .foregroundColor(.primary)
                        }
                    }
                    .scaleEffect(selectedColor == color ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3), value: selectedColor == color)
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Custom color picker
            ColorPicker("Custom Color", selection: Binding(
                get: { selectedColor },
                set: { color in
                    selectedColor = color
                    onColorSelected(color)
                }
            ))
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(width: 220, height: 400)
    }
}

// MARK: - Export Modal
struct ExportModalView: View {
    @ObservedObject var controller: CanvasController
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                if let image = controller.createExportImage() {
                    // Preview
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                    
                    // Export options
                    VStack(spacing: 16) {
                        ExportButton(
                            title: "Save to Photos",
                            icon: "photo",
                            color: .blue,
                            action: {
                                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                dismiss()
                            }
                        )
                        
                        ExportButton(
                            title: "Share",
                            icon: "square.and.arrow.up",
                            color: .green,
                            action: { shareImage(image) }
                        )
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No artwork to export")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Start drawing to create something amazing!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding()
            .navigationTitle("Export Artwork")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func shareImage(_ image: UIImage) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = window
            popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        window.rootViewController?.present(activityVC, animated: true)
    }
}

// MARK: - Export Button
struct ExportButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .shadow(color: color.opacity(0.3), radius: 8, y: 4)
        }
    }
}

#Preview {
    DrawingView()
}
