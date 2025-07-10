import SwiftUI
import PencilKit
import Combine

// MARK: - Drawing Tool Enum (Consolidated)
enum DrawingTool: String, CaseIterable {
    case pen = "Pen"
    case pencil = "Pencil"
    case marker = "Marker"
    case eraser = "Eraser"
    
    var icon: String {
        switch self {
        case .pen: return "pencil.tip"
        case .pencil: return "pencil"
        case .marker: return "highlighter"
        case .eraser: return "eraser"
        }
    }
    
    func pkTool(color: UIColor, width: CGFloat) -> PKTool {
        switch self {
        case .pen:
            return PKInkingTool(.pen, color: color, width: width)
        case .pencil:
            return PKInkingTool(.pencil, color: color, width: width)
        case .marker:
            return PKInkingTool(.marker, color: color, width: width)
        case .eraser:
            return PKEraserTool(.bitmap)
        }
    }
}

// MARK: - Canvas View
struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var currentTool: DrawingTool
    @Binding var currentColor: Color
    @Binding var currentWidth: CGFloat
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.delegate = context.coordinator
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
        let uiColor = UIColor(currentColor)
        canvasView.tool = currentTool.pkTool(color: uiColor, width: currentWidth)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        let parent: CanvasView
        
        init(_ parent: CanvasView) {
            self.parent = parent
        }
        
        func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
            // Tool usage began
        }
        
        func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
            // Tool usage ended
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // Drawing changed - this will trigger the onChange in the parent view
        }
    }
}

// MARK: - Drawing ViewModel
@MainActor
final class DrawingViewModel: ObservableObject {
    let galleryService: GalleryServiceProtocol
    
    @Published var isSaving = false
    @Published var errorMessage: String?
    
    init(galleryService: GalleryServiceProtocol? = nil) {
        self.galleryService = galleryService ?? Container.shared.galleryService
    }
    
    func saveArtwork(title: String, drawing: PKDrawing, duration: TimeInterval) async {
        isSaving = true
        
        do {
            let thumbnailData = await galleryService.generateThumbnail(
                for: drawing,
                size: CGSize(width: 200, height: 200)
            )
            
            let artwork = Artwork(
                title: title,
                drawing: drawing.dataRepresentation(),
                thumbnailData: thumbnailData,
                duration: duration,
                strokeCount: drawing.strokes.count,
                width: drawing.bounds.width,
                height: drawing.bounds.height
            )
            
            try await galleryService.saveArtwork(artwork)
            
        } catch {
            errorMessage = "Failed to save artwork: \(error.localizedDescription)"
        }
        
        isSaving = false
    }
}

// MARK: - Tool Button (Renamed for clarity)
struct ToolSelectorButton: View {
    let tool: DrawingTool
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tool.icon)
                    .font(.title2)
                Text(tool.rawValue)
                    .font(.caption2)
            }
            .frame(width: 60, height: 60)
            .background(isSelected ? Color.accentColor : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 1)
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Color Button
struct ColorButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                )
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.2), lineWidth: 1)
                )
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Color Picker Sheet
struct ColorPickerSheet: View {
    @Binding var selectedColor: Color
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                ColorPicker("Choose Color", selection: $selectedColor)
                    .padding()
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("Custom Color")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Save Artwork Sheet
struct SaveArtworkSheet: View {
    @Binding var title: String
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Artwork Title", text: $title)
                        .focused($isFocused)
                } header: {
                    Text("Give your artwork a name")
                } footer: {
                    Text("You can always change this later")
                }
                
                Section {
                    Button(action: {
                        onSave()
                        dismiss()
                    }) {
                        HStack {
                            Spacer()
                            Label("Save to Gallery", systemImage: "square.and.arrow.down")
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Save Artwork")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                isFocused = true
            }
        }
    }
}

// MARK: - Edit Artwork View (for continuing drawing)
struct EditArtworkView: View {
    @State private var canvasView = PKCanvasView()
    @State private var currentTool: DrawingTool = .pen
    @State private var currentColor = Color.black
    @State private var currentWidth: CGFloat = 5
    @State private var drawingStartTime = Date()
    @StateObject private var viewModel = DrawingViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var artwork: Artwork
    
    var body: some View {
        NavigationView {
            VStack {
                // Canvas
                CanvasView(
                    canvasView: $canvasView,
                    currentTool: $currentTool,
                    currentColor: $currentColor,
                    currentWidth: $currentWidth
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                .padding()
                
                // Tool Bar
                HStack(spacing: 16) {
                    ForEach(DrawingTool.allCases, id: \.self) { tool in
                        ToolSelectorButton(
                            tool: tool,
                            isSelected: currentTool == tool,
                            action: {
                                currentTool = tool
                                Task {
                                    await HapticManager.shared.impact(.light)
                                }
                            }
                        )
                    }
                }
                .padding()
            }
            .onAppear {
                // Load existing drawing
                if let drawing = try? PKDrawing(data: artwork.drawing) {
                    canvasView.drawing = drawing
                }
                drawingStartTime = Date()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func saveChanges() {
        let additionalDuration = Date().timeIntervalSince(drawingStartTime)
        Task {
            var updatedArtwork = artwork
            updatedArtwork.drawing = canvasView.drawing.dataRepresentation()
            updatedArtwork.modifiedAt = Date()
            updatedArtwork.duration += additionalDuration
            updatedArtwork.strokeCount = canvasView.drawing.strokes.count
            // Generate new thumbnail
            if let thumbnailData = await viewModel.galleryService.generateThumbnail(
                for: canvasView.drawing,
                size: CGSize(width: 200, height: 200)
            ) {
                updatedArtwork.thumbnailData = thumbnailData
            }
            try? await viewModel.galleryService.updateArtwork(updatedArtwork)
            dismiss()
        }
    }
}
