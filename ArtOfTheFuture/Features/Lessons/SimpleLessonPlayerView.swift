// MARK: - Simple Working Lesson Player
// File: ArtOfTheFuture/Features/Lessons/SimpleLessonPlayerView.swift

import SwiftUI
import PencilKit

struct SimpleLessonPlayerView: View {
    let lessonTitle: String
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    @State private var showSuccess = false
    
    // Simple lesson steps
    private let steps = [
        "Welcome! Let's learn to draw a circle.",
        "Watch this demonstration.",
        "Now try drawing your own circle.",
        "Great job! Lesson complete!"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Text(lessonTitle)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        // Progress
                        ProgressView(value: Double(currentStep), total: Double(steps.count - 1))
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .frame(height: 8)
                            .padding(.horizontal)
                        
                        Text("Step \(currentStep + 1) of \(steps.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    
                    Spacer()
                    
                    // Main content area
                    VStack(spacing: 30) {
                        // Step content
                        stepContent
                        
                        // Canvas area (for practice steps)
                        if currentStep == 2 {
                            drawingCanvas
                        }
                    }
                    
                    Spacer()
                    
                    // Controls
                    controlButtons
                }
                .padding()
                
                // Success overlay
                if showSuccess {
                    successOverlay
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Prevents iPad issues
    }
    
    // MARK: - Step Content
    @ViewBuilder
    private var stepContent: some View {
        VStack(spacing: 20) {
            // Step icon
            Image(systemName: stepIcon)
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .frame(height: 80)
            
            // Step text
            Text(steps[currentStep])
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }
    
    private var stepIcon: String {
        switch currentStep {
        case 0: return "hand.wave.fill"
        case 1: return "play.circle.fill"
        case 2: return "pencil.circle.fill"
        case 3: return "checkmark.circle.fill"
        default: return "circle"
        }
    }
    
    // MARK: - Drawing Canvas
    private var drawingCanvas: some View {
        VStack(spacing: 16) {
            Text("Draw a circle here:")
                .font(.headline)
            
            ZStack {
                // Canvas background
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .frame(height: 300)
                    .shadow(radius: 4)
                
                // Simple drawing area placeholder
                VStack {
                    Image(systemName: "circle.dashed")
                        .font(.system(size: 100))
                        .foregroundColor(.blue.opacity(0.3))
                    
                    Text("Tap and drag to draw")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .onTapGesture {
                // Simulate drawing completion
                withAnimation(.spring()) {
                    showSuccess = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showSuccess = false
                    nextStep()
                }
            }
        }
    }
    
    // MARK: - Controls
    private var controlButtons: some View {
        HStack(spacing: 16) {
            // Back button
            if currentStep > 0 {
                Button(action: previousStep) {
                    Label("Previous", systemImage: "chevron.left")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(12)
                }
            }
            
            // Next/Complete button
            Button(action: {
                if currentStep == steps.count - 1 {
                    // Complete lesson
                    dismiss()
                } else {
                    nextStep()
                }
            }) {
                HStack {
                    Text(currentStep == steps.count - 1 ? "Complete" : "Continue")
                    Image(systemName: currentStep == steps.count - 1 ? "checkmark" : "chevron.right")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Success Overlay
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Text("Great job!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("You drew a perfect circle!")
                    .foregroundColor(.white)
            }
            .scaleEffect(showSuccess ? 1.0 : 0.8)
            .opacity(showSuccess ? 1.0 : 0.0)
            .animation(.spring(response: 0.6), value: showSuccess)
        }
    }
    
    // MARK: - Navigation
    private func nextStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if currentStep < steps.count - 1 {
                currentStep += 1
            }
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func previousStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if currentStep > 0 {
                currentStep -= 1
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SimpleLessonPlayerView(lessonTitle: "Drawing Circles")
}
