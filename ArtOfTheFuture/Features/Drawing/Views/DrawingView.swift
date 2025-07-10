import SwiftUI
import PencilKit

struct DrawingView: View {
    @StateObject private var canvasController = CanvasController()
    @State private var showExportModal = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top bar
                    DrawingTopBar(
                        controller: canvasController,
                        showExportModal: $showExportModal
                    )
                    .padding(.top, 10)
                    
                    // Canvas area
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

// MARK: - Canvas Controller (FIXED COLOR CONVERSION)
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
        // FIXED: Use proper system background
        pkCanvasView.backgroundColor = UIColor.systemBackground
        pkCanvasView.isOpaque = false // FIXED: Allow proper transparency
        pkCanvasView.layer.cornerRadius = 16
        pkCanvasView.clipsToBounds = true
    }
    
    func chooseTool(_ tool: DrawingTool) {
        activeTool = tool
        setActiveTool()
        
        // Haptic feedback
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
        // FIXED: Proper color conversion to prevent inversion
        let uiColor = convertSwiftUIColorToUIColor(selectedColor)
        
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
    
    // FIXED: Proper color conversion method
    private func convertSwiftUIColorToUIColor(_ color: Color) -> UIColor {
        // Handle common colors explicitly to avoid conversion issues
        switch color {
        case .black:
            return UIColor.label // Black in light mode, white in dark mode
        case .white:
            return UIColor.systemBackground // White in light mode, black in dark mode
        case .red:
            return UIColor.systemRed
        case .blue:
            return UIColor.systemBlue
        case .green:
            return UIColor.systemGreen
        case .orange:
            return UIColor.systemOrange
        case .yellow:
            return UIColor.systemYellow
        case .purple:
            return UIColor.systemPurple
        case .pink:
            return UIColor.systemPink
        case .gray:
            return UIColor.systemGray
        default:
            // For custom colors, use UIColor initializer
            return UIColor(color)
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

// MARK: - Drawing Canvas Area (FIXED)
struct DrawingCanvasArea: View {
    @ObservedObject var controller: CanvasController
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground)) // FIXED: Use system background
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            CanvasViewWrapper(controller: controller)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Canvas View Wrapper (FIXED)
struct CanvasViewWrapper: UIViewRepresentable {
    @ObservedObject var controller: CanvasController
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = controller.pkCanvasView
        canvas.delegate = context.coordinator
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Tool updates are handled by the controller
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
            Task { @MainActor in
                controller.updateUndoRedoState()
            }
        }
        
        func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
            Task { @MainActor in
                controller.updateUndoRedoState()
            }
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
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
                TopBarButton(
                    symbolName: "arrow.uturn.backward",
                    isEnabled: controller.undoAvailable
                ) {
                    controller.undoAction()
                }
                
                TopBarButton(
                    symbolName: "arrow.uturn.forward",
                    isEnabled: controller.redoAvailable
                ) {
                    controller.redoAction()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            
            Spacer()
            
            // Export control
            TopBarButton(
                symbolName: "square.and.arrow.up",
                isEnabled: controller.hasContent
            ) {
                showExportModal = true
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Drawing Tool Bar (FIXED)
struct DrawingToolBar: View {
    @ObservedObject var controller: CanvasController
    
    var body: some View {
        VStack(spacing: 16) {
            // Tool selection row
            HStack(spacing: 20) {
                ForEach(DrawingTool.allCases, id: \.self) { tool in
                    DrawingToolButton(
                        tool: tool,
                        isActive: controller.activeTool == tool,
                        action: {
                            controller.chooseTool(tool)
                        }
                    )
                }
                
                Spacer()
                
                // Clear button
                Button {
                    controller.clearAction()
                } label: {
                    Image(systemName: "trash")
                        .font(.title2)
                        .foregroundColor(.red)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .buttonStyle(BounceStyle())
            }
            
            // Tool options (when not eraser)
            if controller.activeTool != .eraser {
                ToolOptionsPanel(controller: controller)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Drawing Tool Button
struct DrawingToolButton: View {
    let tool: DrawingTool
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tool.icon)
                    .font(.title2)
                    .foregroundColor(isActive ? .white : .primary)
                    .frame(width: 44, height: 44)
                    .background {
                        if isActive {
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        } else {
                            Color(.systemGray5)
                        }
                    }
                    .clipShape(Circle())
                
                Text(tool.rawValue)
                    .font(.caption2)
                    .foregroundColor(isActive ? .primary : .secondary)
            }
        }
        .buttonStyle(BounceStyle())
    }
}

// MARK: - Top Bar Button
struct TopBarButton: View {
    let symbolName: String
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: symbolName)
                .font(.title3)
                .foregroundColor(isEnabled ? .primary : .secondary)
        }
        .disabled(!isEnabled)
        .buttonStyle(BounceStyle())
    }
}

// MARK: - Tool Options Panel (FIXED COLORS)
struct ToolOptionsPanel: View {
    @ObservedObject var controller: CanvasController
    
    var body: some View {
        HStack(spacing: 20) {
            // Color selector with visual feedback
            Button {
                controller.colorPickerVisible.toggle()
            } label: {
                ZStack {
                    Circle()
                        .fill(controller.selectedColor)
                        .frame(width: 32, height: 32)
                        .overlay(Circle().stroke(.primary, lineWidth: 2))
                    
                    // Show color name for debugging
                    if controller.selectedColor == .black {
                        Text("B")
                            .font(.caption2)
                            .foregroundColor(.white)
                    } else if controller.selectedColor == .white {
                        Text("W")
                            .font(.caption2)
                            .foregroundColor(.black)
                    }
                }
            }
            .buttonStyle(BounceStyle())
            .popover(isPresented: $controller.colorPickerVisible) {
                FixedColorPickerPanel(
                    selectedColor: $controller.selectedColor,
                    onColorSelected: { color in
                        controller.updateColor(color)
                    }
                )
            }
            
            // Stroke width control
            VStack {
                Text("Width: \(Int(controller.strokeWidth))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Slider(
                    value: Binding(
                        get: { controller.strokeWidth },
                        set: { value in
                            controller.updateStrokeWidth(value)
                        }
                    ),
                    in: 1...50,
                    step: 1
                )
                .accentColor(.blue)
            }
            .frame(width: 120)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Fixed Color Picker Panel
struct FixedColorPickerPanel: View {
    @Binding var selectedColor: Color
    let onColorSelected: (Color) -> Void
    
    private let presetColors: [(Color, String)] = [
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
        VStack(spacing: 16) {
            Text("Choose Color")
                .font(.headline)
                .padding(.top)
            
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(40)), count: 4), spacing: 8) {
                ForEach(presetColors, id: \.1) { color, name in
                    Button(action: {
                        selectedColor = color
                        onColorSelected(color)
                    }) {
                        ZStack {
                            Circle()
                                .fill(color)
                                .frame(width: 35, height: 35)
                                .overlay(Circle().stroke(.primary, lineWidth: selectedColor == color ? 3 : 1))
                            
                            // Debug labels
                            if color == .black {
                                Text("B")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            } else if color == .white {
                                Text("W")
                                    .font(.caption2)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            
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
        .frame(width: 200, height: 320)
    }
}

// MARK: - Export Modal View
struct ExportModalView: View {
    @ObservedObject var controller: CanvasController
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let image = controller.createExportImage() {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 4)
                    
                    VStack(spacing: 12) {
                        Button {
                            // Save to Photos
                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                            dismiss()
                        } label: {
                            Label("Save to Photos", systemImage: "photo")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        Button {
                            // Share
                            shareImage(image)
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                } else {
                    Text("No artwork to export")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationTitle("Export Artwork")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func shareImage(_ image: UIImage) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        // iPad support
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = window
            popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        window.rootViewController?.present(activityVC, animated: true)
    }
}

// MARK: - Bounce Button Style
struct BounceStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    DrawingView()
}
