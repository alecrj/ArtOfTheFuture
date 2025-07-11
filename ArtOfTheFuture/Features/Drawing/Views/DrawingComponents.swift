import SwiftUI
import PencilKit
import UIKit

// MARK: - Drawing Tool Enum
enum DrawingTool: String, CaseIterable {
    case pen = "Pen"
    case pencil = "Pencil"
    case marker = "Marker"
    case eraser = "Eraser"
    
    var icon: String {
        switch self {
        case .pen:    return "pencil.tip"
        case .pencil: return "pencil"
        case .marker: return "highlighter"
        case .eraser: return "eraser"
        }
    }
    
    func pkTool(color: UIColor, width: CGFloat) -> PKTool {
        switch self {
        case .pen:    return PKInkingTool(.pen, color: color, width: width)
        case .pencil: return PKInkingTool(.pencil, color: color, width: width)
        case .marker: return PKInkingTool(.marker, color: color, width: width)
        case .eraser: return PKEraserTool(.bitmap)
        }
    }
}

// MARK: - Drawing ViewModel
@MainActor
final class DrawingViewModel: ObservableObject {
    // Published state properties
    @Published var selectedTool: DrawingTool = .pen
    @Published var currentColor: Color = .black
    @Published var recentColors: [Color] = []
    @Published var brushSize: CGFloat = 10
    @Published var brushOpacity: Double = 1.0
    @Published var brushSmoothing: Double = 0.0
    @Published var canUndo: Bool = false
    @Published var canRedo: Bool = false
    @Published var canvasTitle: String = "Untitled"
    @Published var currentBlendMode: BlendMode = .normal
    @Published var layers: [DrawingLayer]
    @Published var currentLayerIndex: Int
    
    // The PKCanvasView used for drawing
    let canvasView: PKCanvasView
    
    // Gallery service for saving artworks (dependency injection)
    private let galleryService: GalleryServiceProtocol
    
    init(galleryService: GalleryServiceProtocol? = nil) {
        self.galleryService = galleryService ?? ArtOfTheFuture.Container.shared.galleryService
        self.canvasView = PKCanvasView()
        // Initialize with a single layer
        self.layers = [DrawingLayer(name: "Layer 1")]
        self.currentLayerIndex = 0
    }
    
    // Computed current layer (based on index)
    var currentLayer: DrawingLayer? {
        layers.indices.contains(currentLayerIndex) ? layers[currentLayerIndex] : nil
    }
    
    // Current PKTool reflecting selected tool, color, width, and opacity
    var currentPKTool: PKTool {
        let uiColor = UIColor(currentColor).withAlphaComponent(brushOpacity)
        // Use the DrawingTool helper to get a PKTool
        return selectedTool.pkTool(color: uiColor, width: brushSize)
    }
    
    // MARK: - Canvas Actions
    
    func newCanvas() {
        // Reset to a new canvas with one blank layer
        layers = [DrawingLayer(name: "Layer 1")]
        currentLayerIndex = 0
        canvasTitle = "Untitled"
        canvasView.drawing = PKDrawing()
        updateUndoRedoState()
    }
    
    func clearCanvas() {
        // Clear current layer's drawing
        canvasView.drawing = PKDrawing()
        if currentLayerIndex < layers.count {
            layers[currentLayerIndex].drawing = PKDrawing()
        }
        updateUndoRedoState()
    }
    
    func undo() {
        if canvasView.undoManager?.canUndo == true {
            canvasView.undoManager?.undo()
        }
        updateUndoRedoState()
    }
    
    func redo() {
        if canvasView.undoManager?.canRedo == true {
            canvasView.undoManager?.redo()
        }
        updateUndoRedoState()
    }
    
    func updateUndoRedoState() {
        // Refresh undo/redo availability
        canUndo = canvasView.undoManager?.canUndo ?? false
        canRedo = canvasView.undoManager?.canRedo ?? false
    }
    
    func toggleTransformMode() {
        // Toggle a "transform mode" (selection tool) – not fully implemented in UI
        // This could activate a PKLassoTool if needed. For now, just a placeholder.
        if selectedTool == .eraser {
            selectedTool = .pen  // ensure a drawing tool is selected for selection mode
        }
        // In a real app, one could set selectedTool to a custom 'selection' tool and handle accordingly.
    }
    
    func toggleReference() {
        // Placeholder for toggling a reference image overlay
        // Implementation depends on how reference images are handled
    }
    
    // MARK: - Layer Management
    
    func addLayer() {
        // Save current layer's drawing before switching
        if currentLayerIndex < layers.count {
            layers[currentLayerIndex].drawing = canvasView.drawing
        }
        // Create new layer
        let newLayer = DrawingLayer(name: "Layer \(layers.count + 1)")
        layers.append(newLayer)
        currentLayerIndex = layers.count - 1
        // Use a fresh drawing for the new layer
        canvasView.drawing = PKDrawing()
    }
    
    func duplicateLayer() {
        guard let layer = currentLayer else { return }
        // Save current layer drawing
        layers[currentLayerIndex].drawing = canvasView.drawing
        // Duplicate layer properties and content
        let copyLayer = DrawingLayer(
            name: layer.name + " Copy",
            opacity: layer.opacity,
            isVisible: layer.isVisible,
            isLocked: layer.isLocked,
            blendMode: layer.blendMode,
            drawing: layer.drawing
        )
        layers.insert(copyLayer, at: currentLayerIndex + 1)
        currentLayerIndex += 1
        // Switch canvas to the duplicated layer's drawing
        canvasView.drawing = copyLayer.drawing
    }
    
    func deleteLayer() {
        // Require at least one layer to remain
        guard layers.count > 1 else { return }
        // Remove current layer
        layers.remove(at: currentLayerIndex)
        // Adjust current index
        if currentLayerIndex >= layers.count {
            currentLayerIndex = layers.count - 1
        }
        // Load the new current layer's drawing into the canvas
        canvasView.drawing = layers[currentLayerIndex].drawing
    }
    
    func selectLayer(_ layer: DrawingLayer) {
        // Save current layer drawing
        if currentLayerIndex < layers.count {
            layers[currentLayerIndex].drawing = canvasView.drawing
        }
        // Find selected layer index and switch to it
        if let idx = layers.firstIndex(where: { $0.id == layer.id }) {
            currentLayerIndex = idx
            canvasView.drawing = layers[idx].drawing
        }
    }
    
    func toggleLayerVisibility(_ layer: DrawingLayer) {
        if let idx = layers.firstIndex(where: { $0.id == layer.id }) {
            layers[idx].isVisible.toggle()
            // Note: The canvas only displays the current layer's drawing,
            // so hiding the current layer will not immediately change the canvas.
            // (Combining layers for display happens on export.)
        }
    }
    
    // MARK: - Export Functionality
    
    func export(format: ExportOptionsSheet.ExportFormat, includeBackground: Bool, quality: Double, to destination: ExportDestination) {
        // Merge visible layers into one PKDrawing
        // Ensure current layer's latest strokes are saved
        if currentLayerIndex < layers.count {
            layers[currentLayerIndex].drawing = canvasView.drawing
        }
        var combinedDrawing = PKDrawing()
        for layer in layers where layer.isVisible {
            if combinedDrawing.strokes.isEmpty {
                combinedDrawing = layer.drawing
            } else {
                // Append strokes of this layer to combined drawing
                combinedDrawing = combinedDrawing.appending(layer.drawing)
            }
        }
        // Determine rendering bounds (use canvas view size)
        let bounds = canvasView.bounds
        // Render combined drawing to UIImage
        var outputImage = combinedDrawing.image(from: bounds, scale: 1.0)
        if includeBackground || format == .jpeg {
            // Composite on a white background if needed
            UIGraphicsBeginImageContextWithOptions(bounds.size, true, 1.0)
            UIColor.white.setFill()
            UIRectFill(CGRect(origin: .zero, size: bounds.size))
            outputImage.draw(at: .zero)
            outputImage = UIGraphicsGetImageFromCurrentImageContext() ?? outputImage
            UIGraphicsEndImageContext()
        }
        // Prepare data according to format
        let imageData: Data?
        var fileExtension = ""
        switch format {
        case .png:
            imageData = outputImage.pngData()
            fileExtension = "png"
        case .jpeg:
            imageData = outputImage.jpegData(compressionQuality: quality)
            fileExtension = "jpg"
        case .pdf:
            fileExtension = "pdf"
            // Draw image into PDF context
            let pdfData = NSMutableData()
            UIGraphicsBeginPDFContextToData(pdfData, bounds, nil)
            UIGraphicsBeginPDFPage()
            if let ctx = UIGraphicsGetCurrentContext() {
                if includeBackground {
                    ctx.setFillColor(UIColor.white.cgColor)
                    ctx.fill(bounds)
                }
                outputImage.draw(in: bounds)
            }
            UIGraphicsEndPDFContext()
            imageData = pdfData as Data
        case .psd:
            fileExtension = "psd"
            // For simplicity, export a flattened PNG (real PSD export not implemented)
            imageData = outputImage.pngData()
        }
        guard let data = imageData else { return }
        
        switch destination {
        case .photos:
            if let uiImage = UIImage(data: data) {
                UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
            }
        case .files:
            // Save data to a temporary file and present a document picker for export
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("DrawingExport.\(fileExtension)")
            do { try data.write(to: tempURL, options: [.atomic]) } catch {
                print("Failed to write export file: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                let picker = UIDocumentPickerViewController(forExporting: [tempURL], asCopy: true)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    rootVC.present(picker, animated: true)
                }
            }
        case .share:
            // Present a share sheet with the exported file
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("DrawingExport.\(fileExtension)")
            do { try data.write(to: tempURL, options: [.atomic]) } catch {
                print("Failed to write export file: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    if let popover = activityVC.popoverPresentationController {
                        // Present centered on iPad
                        popover.sourceView = window
                        popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                    }
                    rootVC.present(activityVC, animated: true)
                }
            }
        }
    }
}
