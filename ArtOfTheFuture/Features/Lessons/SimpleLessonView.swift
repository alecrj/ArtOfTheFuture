import SwiftUI

struct SimpleLessonView: View {
    let lessonTitle: String
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    
    private let steps = [
        "Welcome! Let's start learning.",
        "Follow along with this lesson.",
        "Practice what you've learned.",
        "Amazing! You completed the lesson!"
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            // Close button
            HStack {
                Button("✕") {
                    dismiss()
                }
                .font(.title2)
                .padding()
                
                Spacer()
            }
            
            // Lesson title
            Text(lessonTitle)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Progress dots
            HStack(spacing: 12) {
                ForEach(0..<steps.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                }
            }
            
            Spacer()
            
            // Current step
            VStack(spacing: 20) {
                Image(systemName: stepIcon)
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text(steps[currentStep])
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Spacer()
            
            // Continue button
            Button(action: nextStep) {
                Text(currentStep == steps.count - 1 ? "Complete!" : "Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var stepIcon: String {
        switch currentStep {
        case 0: return "hand.wave.fill"
        case 1: return "book.fill"
        case 2: return "pencil"
        default: return "checkmark.circle.fill"
        }
    }
    
    private func nextStep() {
        if currentStep < steps.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep += 1
            }
        } else {
            dismiss()
        }
    }
}
