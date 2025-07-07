import SwiftUI

struct DrawingView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Canvas placeholder
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack {
                    // Top toolbar
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.title2)
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title2)
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Placeholder text
                    Text("🎨 Drawing Canvas")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    
                    Text("PencilKit coming next session!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Bottom toolbar placeholder
                    HStack(spacing: 20) {
                        ForEach(["pencil", "pencil.tip", "paintbrush", "eraser"], id: \.self) { tool in
                            Button(action: {}) {
                                Image(systemName: tool)
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(8)
                                    .shadow(radius: 2)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    DrawingView()
}
