// MARK: - Professional Drawing View
// **REPLACE:** ArtOfTheFuture/Features/Drawing/Views/DrawingView.swift

import SwiftUI
import PencilKit

struct DrawingView: View {
    @StateObject private var viewModel = DrawingViewModel()
    @State private var showTools = true
    @State private var showLayers = false
    @State private var showColorPicker = false
    @State private var showBrushSettings = false
    @State private var showExportOptions = false
    @State private var currentGesture: DragGesture.Value?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        ZStack {
            // Canvas background
            Color.white
                .ignoresSafeArea()
            
            // Main drawing canvas
            DrawingCanvas(viewModel: viewModel)
                .ignoresSafeArea()
            
            // UI Overlay
            drawingInterface
        }
        .preferredColorScheme(.light) // Keep canvas always light
        .statusBar(hidden: !showTools)
        .sheet(isPresented: $showExportOptions) {
            ExportOptionsSheet(viewModel: viewModel)
        }
    }
    
    // MARK: - Drawing Interface
    @ViewBuilder
    private var drawingInterface: some View {
        // Top toolbar
        VStack {
            if showTools {
                topToolbar
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Spacer()
            
            // Bottom tools
            HStack(alignment: .bottom) {
                if showTools {
                    // Left side tools (iPad)
                    if DeviceType.current.isIPad {
                        leftSideTools
                            .transition(.move(edge: .leading).combined(with: .opacity))
                    }
                    
                    Spacer()
                    
                    // Right side tools (iPad)
                    if DeviceType.current.isIPad {
                        rightSideTools
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
            }
            
            // Bottom toolbar (iPhone)
            if showTools && !DeviceType.current.isIPad {
                bottomToolbar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(AnimationPresets.smooth, value: showTools)
        
        // Floating panels
        floatingPanels
        
        // Touch indicator for tool preview
        if let gesture = currentGesture {
            touchIndicator(at: gesture.location)
        }
    }
    
    // MARK: - Top Toolbar
    private var topToolbar: some View {
        HStack(spacing: Dimensions.paddingMedium) {
            // File menu
            Menu {
                Button(action: viewModel.newCanvas) {
                    Label("New Canvas", systemImage: "doc.badge.plus")
                }
                
                Button(action: { showExportOptions = true }) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                
                Divider()
                
                Button(action: viewModel.clearCanvas) {
                    Label("Clear Canvas", systemImage: "trash")
                }
                .foregroundColor(.red)
            } label: {
                Image(systemName: "doc.text")
                    .font(.title3)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Canvas title
            Text(viewModel.canvasTitle)
                .font(Typography.headline)
                .foregroundColor(ColorPalette.textPrimary)
            
            Spacer()
            
            // Undo/Redo
            HStack(spacing: 8) {
                IconButton(
                    icon: "arrow.uturn.backward",
                    size: .medium,
                    style: .ghost,
                    action: viewModel.undo
                )
                .disabled(!viewModel.canUndo)
                
                IconButton(
                    icon: "arrow.uturn.forward",
                    size: .medium,
                    style: .ghost,
                    action: viewModel.redo
                )
                .disabled(!viewModel.canRedo)
            }
            
            // Toggle UI
            IconButton(
                icon: showTools ? "eye.slash" : "eye",
                size: .medium,
                style: .ghost,
                action: { showTools.toggle() }
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Left Side Tools (iPad)
    private var leftSideTools: some View {
        VStack(spacing: Dimensions.paddingSmall) {
            // Tool selector
            ToolPalette(
                selectedTool: $viewModel.selectedTool,
                onToolSelected: { tool in
                    HapticManager.shared.selection()
                    showBrushSettings = true
                }
            )
            
            Divider()
                .frame(width: 60)
            
            // Quick colors
            VStack(spacing: 8) {
                ForEach(viewModel.recentColors, id: \.self) { color in
                    ColorSwatch(
                        color: color,
                        isSelected: viewModel.currentColor == color,
                        action: {
                            viewModel.currentColor = color
                            HapticManager.shared.selection()
                        }
                    )
                }
                
                // Color picker button
                Button(action: { showColorPicker = true }) {
                    ZStack {
                        Circle()
                            .fill(
                                AngularGradient(
                                    colors: [.red, .yellow, .green, .cyan, .blue, .purple, .red],
                                    center: .center
                                )
                            )
                            .frame(width: 44, height: 44)
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 20, height: 20)
                        
                        Circle()
                            .fill(viewModel.currentColor)
                            .frame(width: 16, height: 16)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(Dimensions.cornerRadiusMedium)
        .shadow(color: ShadowStyle.medium.color, radius: ShadowStyle.medium.radius)
        .padding()
    }
    
    // MARK: - Right Side Tools (iPad)
    private var rightSideTools: some View {
        VStack(spacing: Dimensions.paddingMedium) {
            // Layers
            IconButton(
                icon: "square.3.stack.3d",
                size: .large,
                style: .secondary,
                action: { showLayers.toggle() }
            )
            
            // Brush settings
            IconButton(
                icon: "slider.horizontal.3",
                size: .large,
                style: .secondary,
                action: { showBrushSettings.toggle() }
            )
            
            // Transform
            IconButton(
                icon: "arrow.up.left.and.arrow.down.right",
                size: .large,
                style: .secondary,
                action: viewModel.toggleTransformMode
            )
            
            // Reference
            IconButton(
                icon: "photo",
                size: .large,
                style: .secondary,
                action: viewModel.toggleReference
            )
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(Dimensions.cornerRadiusMedium)
        .shadow(color: ShadowStyle.medium.color, radius: ShadowStyle.medium.radius)
        .padding()
    }
    
    // MARK: - Bottom Toolbar (iPhone)
    private var bottomToolbar: some View {
        VStack(spacing: 0) {
            // Brush size slider
            HStack(spacing: Dimensions.paddingMedium) {
                Image(systemName: "circle.fill")
                    .font(.system(size: 8))
                    .foregroundColor(viewModel.currentColor)
                
                Slider(
                    value: $viewModel.brushSize,
                    in: 1...100,
                    step: 1
                )
                .accentColor(viewModel.currentColor)
                
                Image(systemName: "circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(viewModel.currentColor)
                
                Text("\(Int(viewModel.brushSize))px")
                    .font(Typography.caption)
                    .foregroundColor(ColorPalette.textSecondary)
                    .frame(width: 40)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            Divider()
            
            // Tools
            HStack(spacing: 0) {
                ForEach(DrawingTool.allCases, id: \.self) { tool in
                    ToolButton(
                        tool: tool,
                        isSelected: viewModel.selectedTool == tool,
                        action: {
                            viewModel.selectedTool = tool
                            HapticManager.shared.selection()
                        }
                    )
                }
                
                Spacer()
                
                // Color button
                Button(action: { showColorPicker = true }) {
                    Circle()
                        .fill(viewModel.currentColor)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .shadow(radius: 2)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
        }
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Floating Panels
    @ViewBuilder
    private var floatingPanels: some View {
        // Color Picker
        if showColorPicker {
            FloatingPanel(
                title: "Color",
                isPresented: $showColorPicker,
                position: .center
            ) {
                ModernColorPicker(
                    selectedColor: $viewModel.currentColor,
                    recentColors: $viewModel.recentColors
                )
            }
        }
        
        // Brush Settings
        if showBrushSettings {
            FloatingPanel(
                title: "Brush Settings",
                isPresented: $showBrushSettings,
                position: DeviceType.current.isIPad ? .topTrailing : .bottom
            ) {
                BrushSettingsPanel(viewModel: viewModel)
            }
        }
        
        // Layers
        if showLayers {
            FloatingPanel(
                title: "Layers",
                isPresented: $showLayers,
                position: .trailing
            ) {
                LayersPanel(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Touch Indicator
    private func touchIndicator(at location: CGPoint) -> some View {
        Circle()
            .stroke(viewModel.currentColor, lineWidth: 2)
            .frame(width: viewModel.brushSize * 2, height: viewModel.brushSize * 2)
            .position(location)
            .allowsHitTesting(false)
            .animation(.none)
    }
}

// MARK: - Drawing Canvas
struct DrawingCanvas: UIViewRepresentable {
    @ObservedObject var viewModel: DrawingViewModel
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = viewModel.canvasView
        canvasView.delegate = context.coordinator
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .white
        canvasView.isOpaque = false
        
        // Setup for pressure sensitivity
        canvasView.drawingGestureRecognizer.maximumPossibleForce = 4.0
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update tool
        uiView.tool = viewModel.currentPKTool
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        let viewModel: DrawingViewModel
        
        init(viewModel: DrawingViewModel) {
            self.viewModel = viewModel
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            viewModel.updateUndoRedoState()
        }
    }
}

// MARK: - Tool Palette
struct ToolPalette: View {
    @Binding var selectedTool: DrawingTool
    let onToolSelected: (DrawingTool) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(DrawingTool.allCases, id: \.self) { tool in
                ToolPaletteButton(
                    tool: tool,
                    isSelected: selectedTool == tool,
                    action: {
                        selectedTool = tool
                        onToolSelected(tool)
                    }
                )
            }
        }
    }
}

// MARK: - Tool Palette Button
struct ToolPaletteButton: View {
    let tool: DrawingTool
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? ColorPalette.primaryGradient : LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 60, height: 60)
                
                VStack(spacing: 4) {
                    Image(systemName: tool.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : ColorPalette.textPrimary)
                    
                    Text(tool.rawValue)
                        .font(.caption2)
                        .foregroundColor(isSelected ? .white : ColorPalette.textSecondary)
                }
            }
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(AnimationPresets.quick, value: isSelected)
    }
}

// MARK: - Tool Button (iPhone)
struct ToolButton: View {
    let tool: DrawingTool
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tool.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? ColorPalette.primaryBlue : ColorPalette.textSecondary)
                
                Text(tool.rawValue)
                    .font(.caption2)
                    .foregroundColor(isSelected ? ColorPalette.primaryBlue : ColorPalette.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                isSelected ?
                ColorPalette.primaryBlue.opacity(0.1) : Color.clear
            )
        }
    }
}

// MARK: - Color Swatch
struct ColorSwatch: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 44, height: 44)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: isSelected ? 3 : 1)
                )
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.2), lineWidth: 1)
                        .padding(1)
                )
                .shadow(color: color.opacity(0.4), radius: isSelected ? 8 : 2)
                .scaleEffect(isSelected ? 1.1 : 1.0)
        }
        .animation(AnimationPresets.quick, value: isSelected)
    }
}

// MARK: - Modern Color Picker
struct ModernColorPicker: View {
    @Binding var selectedColor: Color
    @Binding var recentColors: [Color]
    @State private var hue: Double = 0
    @State private var saturation: Double = 1
    @State private var brightness: Double = 1
    
    var body: some View {
        VStack(spacing: Dimensions.paddingMedium) {
            // Color wheel
            ColorWheel(
                hue: $hue,
                saturation: $saturation,
                brightness: $brightness,
                color: $selectedColor
            )
            .frame(width: 250, height: 250)
            
            // Recent colors
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent")
                    .font(Typography.caption)
                    .foregroundColor(ColorPalette.textSecondary)
                
                HStack(spacing: 8) {
                    ForEach(recentColors, id: \.self) { color in
                        ColorSwatch(
                            color: color,
                            isSelected: false,
                            action: {
                                selectedColor = color
                            }
                        )
                        .scaleEffect(0.8)
                    }
                }
            }
            
            // RGB Sliders
            VStack(spacing: 12) {
                ColorSlider(value: $hue, gradient: hueGradient, label: "H")
                ColorSlider(value: $saturation, gradient: saturationGradient, label: "S")
                ColorSlider(value: $brightness, gradient: brightnessGradient, label: "B")
            }
        }
        .padding()
        .onChange(of: selectedColor) { _, newColor in
            if !recentColors.contains(newColor) {
                recentColors.insert(newColor, at: 0)
                if recentColors.count > 8 {
                    recentColors.removeLast()
                }
            }
        }
    }
    
    private var hueGradient: LinearGradient {
        LinearGradient(
            colors: (0...10).map { Color(hue: Double($0) / 10, saturation: 1, brightness: 1) },
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var saturationGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hue: hue, saturation: 0, brightness: brightness),
                    Color(hue: hue, saturation: 1, brightness: brightness)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var brightnessGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hue: hue, saturation: saturation, brightness: 0),
                    Color(hue: hue, saturation: saturation, brightness: 1)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Color Wheel
struct ColorWheel: View {
    @Binding var hue: Double
    @Binding var saturation: Double
    @Binding var brightness: Double
    @Binding var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Hue wheel
                AngularGradient(
                    colors: (0...360).map { Color(hue: Double($0) / 360, saturation: 1, brightness: 1) },
                    center: .center
                )
                .clipShape(Circle())
                
                // Saturation/Brightness overlay
                RadialGradient(
                    colors: [Color.white.opacity(1 - saturation), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: geometry.size.width / 2
                )
                
                // Brightness overlay
                Circle()
                    .fill(Color.black.opacity(1 - brightness))
                
                // Selection indicator
                Circle()
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.3), lineWidth: 1)
                            .padding(1)
                    )
                    .position(selectionPosition(in: geometry.size))
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        updateSelection(at: value.location, in: geometry.size)
                    }
            )
        }
    }
    
    private func selectionPosition(in size: CGSize) -> CGPoint {
        let angle = hue * 2 * .pi
        let radius = (size.width / 2) * saturation
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        
        return CGPoint(
            x: center.x + radius * cos(angle),
            y: center.y + radius * sin(angle)
        )
    }
    
    private func updateSelection(at location: CGPoint, in size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let vector = CGPoint(x: location.x - center.x, y: location.y - center.y)
        
        let angle = atan2(vector.y, vector.x)
        hue = (angle < 0 ? angle + 2 * .pi : angle) / (2 * .pi)
        
        let distance = sqrt(vector.x * vector.x + vector.y * vector.y)
        saturation = min(distance / (size.width / 2), 1)
        
        color = Color(hue: hue, saturation: saturation, brightness: brightness)
        HapticManager.shared.selection()
    }
}

// MARK: - Color Slider
struct ColorSlider: View {
    @Binding var value: Double
    let gradient: LinearGradient
    let label: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .font(Typography.caption)
                .foregroundColor(ColorPalette.textSecondary)
                .frame(width: 20)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(gradient)
                        .frame(height: 24)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(radius: 2)
                        .offset(x: geometry.size.width * value - 14)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            value = max(0, min(1, gesture.location.x / geometry.size.width))
                            HapticManager.shared.selection()
                        }
                )
            }
            .frame(height: 28)
            
            Text("\(Int(value * 100))")
                .font(Typography.caption)
                .foregroundColor(ColorPalette.textSecondary)
                .frame(width: 30)
        }
    }
}

// MARK: - Brush Settings Panel
struct BrushSettingsPanel: View {
    @ObservedObject var viewModel: DrawingViewModel
    
    var body: some View {
        VStack(spacing: Dimensions.paddingMedium) {
            // Size
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Size")
                        .font(Typography.subheadline)
                    Spacer()
                    Text("\(Int(viewModel.brushSize))px")
                        .font(Typography.caption)
                        .foregroundColor(ColorPalette.textSecondary)
                }
                
                Slider(value: $viewModel.brushSize, in: 1...100)
                    .accentColor(viewModel.currentColor)
            }
            
            // Opacity
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Opacity")
                        .font(Typography.subheadline)
                    Spacer()
                    Text("\(Int(viewModel.brushOpacity * 100))%")
                        .font(Typography.caption)
                        .foregroundColor(ColorPalette.textSecondary)
                }
                
                Slider(value: $viewModel.brushOpacity)
                    .accentColor(viewModel.currentColor)
            }
            
            // Smoothing
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Smoothing")
                        .font(Typography.subheadline)
                    Spacer()
                    Text("\(Int(viewModel.brushSmoothing * 100))%")
                        .font(Typography.caption)
                        .foregroundColor(ColorPalette.textSecondary)
                }
                
                Slider(value: $viewModel.brushSmoothing)
                    .accentColor(viewModel.currentColor)
            }
            
            Divider()
            
            // Pressure settings
            Toggle("Pressure Sensitivity", isOn: $viewModel.pressureSensitive)
                .font(Typography.subheadline)
            
            Toggle("Tilt Support", isOn: $viewModel.tiltSupport)
                .font(Typography.subheadline)
        }
        .padding()
        .frame(width: DeviceType.current.isIPad ? 300 : nil)
    }
}

// MARK: - Layers Panel
struct LayersPanel: View {
    @ObservedObject var viewModel: DrawingViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Layer controls
            HStack {
                Button(action: viewModel.addLayer) {
                    Image(systemName: "plus")
                }
                
                Button(action: viewModel.duplicateLayer) {
                    Image(systemName: "doc.on.doc")
                }
                .disabled(viewModel.layers.isEmpty)
                
                Button(action: viewModel.deleteLayer) {
                    Image(systemName: "trash")
                }
                .disabled(viewModel.layers.count <= 1)
                
                Spacer()
                
                Menu {
                    ForEach(BlendMode.allCases, id: \.self) { mode in
                        Button(mode.rawValue) {
                            viewModel.currentBlendMode = mode
                        }
                    }
                } label: {
                    Text(viewModel.currentBlendMode.rawValue)
                        .font(Typography.caption)
                }
            }
            .padding()
            
            Divider()
            
            // Layers list
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(viewModel.layers.reversed()) { layer in
                        LayerRow(
                            layer: layer,
                            isSelected: viewModel.currentLayer?.id == layer.id,
                            onTap: {
                                viewModel.selectLayer(layer)
                            },
                            onVisibilityToggle: {
                                viewModel.toggleLayerVisibility(layer)
                            }
                        )
                    }
                }
                .padding()
            }
        }
        .frame(width: DeviceType.current.isIPad ? 280 : nil)
    }
}

// MARK: - Layer Row
struct LayerRow: View {
    let layer: DrawingLayer
    let isSelected: Bool
    let onTap: () -> Void
    let onVisibilityToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                )
            
            // Layer info
            VStack(alignment: .leading, spacing: 2) {
                Text(layer.name)
                    .font(Typography.subheadline)
                    .foregroundColor(ColorPalette.textPrimary)
                
                Text("\(Int(layer.opacity * 100))% • \(layer.blendMode.rawValue)")
                    .font(Typography.caption)
                    .foregroundColor(ColorPalette.textSecondary)
            }
            
            Spacer()
            
            // Visibility toggle
            Button(action: onVisibilityToggle) {
                Image(systemName: layer.isVisible ? "eye" : "eye.slash")
                    .foregroundColor(ColorPalette.textSecondary)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? ColorPalette.primaryBlue.opacity(0.1) : Color.clear)
        )
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Floating Panel
struct FloatingPanel<Content: View>: View {
    let title: String
    @Binding var isPresented: Bool
    let position: PanelPosition
    let content: () -> Content
    
    enum PanelPosition {
        case center, topTrailing, trailing, bottom
    }
    
    @State private var dragOffset = CGSize.zero
    
    var body: some View {
        ZStack {
            // Dimmed background for center position
            if position == .center {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isPresented = false
                    }
            }
            
            VStack(spacing: 0) {
                // Handle
                SheetHandle()
                
                // Title bar
                HStack {
                    Text(title)
                        .font(Typography.headline)
                    
                    Spacer()
                    
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(ColorPalette.textSecondary)
                    }
                }
                .padding()
                
                Divider()
                
                // Content
                content()
            }
            .background(ColorPalette.surface)
            .cornerRadius(Dimensions.cornerRadiusLarge)
            .shadow(
                color: ShadowStyle.elevated.color,
                radius: ShadowStyle.elevated.radius
            )
            .offset(dragOffset)
            .frame(maxWidth: panelMaxWidth, maxHeight: panelMaxHeight)
            .padding(panelPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: panelAlignment)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { _ in
                        withAnimation(AnimationPresets.smooth) {
                            dragOffset = .zero
                        }
                    }
            )
        }
        .transition(panelTransition)
        .animation(AnimationPresets.smooth, value: isPresented)
    }
    
    private var panelMaxWidth: CGFloat? {
        switch position {
        case .center: return 400
        case .topTrailing, .trailing: return 320
        case .bottom: return .infinity
        }
    }
    
    private var panelMaxHeight: CGFloat? {
        switch position {
        case .center, .topTrailing, .trailing: return 600
        case .bottom: return 400
        }
    }
    
    private var panelPadding: EdgeInsets {
        switch position {
        case .center: return EdgeInsets()
        case .topTrailing: return EdgeInsets(top: 100, leading: 0, bottom: 0, trailing: 20)
        case .trailing: return EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20)
        case .bottom: return EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        }
    }
    
    private var panelAlignment: Alignment {
        switch position {
        case .center: return .center
        case .topTrailing: return .topTrailing
        case .trailing: return .trailing
        case .bottom: return .bottom
        }
    }
    
    private var panelTransition: AnyTransition {
        switch position {
        case .center: return .scale.combined(with: .opacity)
        case .topTrailing, .trailing: return .move(edge: .trailing).combined(with: .opacity)
        case .bottom: return .move(edge: .bottom).combined(with: .opacity)
        }
    }
}

// MARK: - Export Options Sheet
struct ExportOptionsSheet: View {
    @ObservedObject var viewModel: DrawingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var exportFormat: ExportFormat = .png
    @State private var includeBackground = true
    @State private var exportQuality: Double = 1.0
    
    enum ExportFormat: String, CaseIterable {
        case png = "PNG"
        case jpeg = "JPEG"
        case pdf = "PDF"
        case psd = "PSD"
        
        var icon: String {
            switch self {
            case .png: return "doc.richtext"
            case .jpeg: return "photo"
            case .pdf: return "doc.text"
            case .psd: return "square.stack.3d.up"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Format") {
                    Picker("Export Format", selection: $exportFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Label(format.rawValue, systemImage: format.icon)
                                .tag(format)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Options") {
                    Toggle("Include Background", isOn: $includeBackground)
                    
                    if exportFormat == .jpeg {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Quality")
                                Spacer()
                                Text("\(Int(exportQuality * 100))%")
                                    .foregroundColor(ColorPalette.textSecondary)
                            }
                            
                            Slider(value: $exportQuality, in: 0.1...1.0)
                        }
                    }
                }
                
                Section("Actions") {
                    Button(action: { exportTo(.photos) }) {
                        Label("Save to Photos", systemImage: "photo.on.rectangle")
                    }
                    
                    Button(action: { exportTo(.files) }) {
                        Label("Save to Files", systemImage: "folder")
                    }
                    
                    Button(action: { exportTo(.share) }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func exportTo(_ destination: ExportDestination) {
        viewModel.export(
            format: exportFormat,
            includeBackground: includeBackground,
            quality: exportQuality,
            to: destination
        )
        dismiss()
    }
}

enum ExportDestination {
    case photos, files, share
}

// MARK: - Drawing Models
enum BlendMode: String, CaseIterable {
    case normal = "Normal"
    case multiply = "Multiply"
    case screen = "Screen"
    case overlay = "Overlay"
}

struct DrawingLayer: Identifiable {
    let id = UUID()
    var name: String
    var opacity: Double = 1.0
    var isVisible = true
    var isLocked = false
    var blendMode: BlendMode = .normal
    var drawing: PKDrawing = PKDrawing()
}
