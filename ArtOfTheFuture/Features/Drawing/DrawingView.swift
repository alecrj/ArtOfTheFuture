import SwiftUI
import PencilKit

struct DrawingView: View {
    @State private var canvasView = PKCanvasView()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("🎨 Drawing Canvas")
                    .font(.largeTitle)
                    .padding()
                
                ZStack {
                    Color(.systemGray6)
                    
                    SimpleCanvasView(canvasView: $canvasView)
                        .cornerRadius(12)
                }
                .padding()
                
                HStack(spacing: 20) {
                    Button("Pen") {
                        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("Eraser") {
                        canvasView.tool = PKEraserTool(.bitmap)
                    }
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("Clear") {
                        canvasView.drawing = PKDrawing()
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Draw")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SimpleCanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
        canvasView.backgroundColor = UIColor.systemBackground
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // No updates needed
    }
}

#Preview {
    DrawingView()
}
