// File 5: ArtOfTheFuture/Core/Debug/DebugFloatingButton.swift

import SwiftUI

struct DebugFloatingButton: View {
    @StateObject private var debugService = DebugService.shared
    @State private var showingControls = false
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                if debugService.isDebugMode {
                    Button(action: {
                        showingControls = true
                    }) {
                        Image(systemName: "bug.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.red)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showingControls) {
            NavigationView {
                DebugControlPanel()
                    .navigationTitle("Debug Controls")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingControls = false
                            }
                        }
                    }
            }
        }
    }
}
