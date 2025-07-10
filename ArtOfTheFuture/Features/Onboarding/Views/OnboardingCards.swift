import SwiftUI

// MARK: - Skill Level Card
struct SkillLevelCard: View {
    let level: SkillLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(level.color.opacity(isSelected ? 0.2 : 0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: level.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? level.color : .secondary)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.rawValue)
                        .font(.headline)
                        .foregroundColor(isSelected ? .primary : .secondary)
                    
                    Text(level.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(level.color)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? level.color : Color.clear, lineWidth: 2)
                    )
            )
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Goal Card
struct GoalCard: View {
    let goal: LearningGoal
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(goal.color.opacity(isSelected ? 0.2 : 0.1))
                        .frame(height: 80)
                    
                    Image(systemName: goal.icon)
                        .font(.largeTitle)
                        .foregroundColor(isSelected ? goal.color : .secondary)
                }
                
                // Text
                Text(goal.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .multilineTextAlignment(.center)
                
                // Selection indicator
                Circle()
                    .fill(isSelected ? goal.color : Color(.systemGray5))
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .opacity(isSelected ? 1 : 0)
                    )
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? goal.color : Color.clear, lineWidth: 2)
                    )
            )
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Practice Time Card
struct PracticeTimeCard: View {
    let practiceTime: PracticeTime
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(practiceTime.rawValue)
                        .font(.headline)
                        .foregroundColor(isSelected ? .primary : .secondary)
                    
                    Text(practiceTime.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Interest Card
struct InterestCard: View {
    let interest: ArtInterest
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Image placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.3),
                                    Color.purple.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 120)
                    
                    Image(systemName: interest.icon)
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    
                    // Selection overlay
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.3))
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                
                // Title
                Text(interest.rawValue)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .padding(.vertical, 8)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                    )
            )
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
            .scaleEffect(isPressed ? 0.95 : (isSelected ? 1.05 : 1.0))
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        } perform: {
            // Long press action if needed
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Onboarding Skip Button
struct OnboardingSkipButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Skip")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(20)
        }
    }
}

// MARK: - Animated Welcome Icon
struct AnimatedWelcomeIcon: View {
    @State private var rotation = 0.0
    @State private var scale = 1.0
    
    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4
                )
                .frame(width: 180, height: 180)
                .rotationEffect(.degrees(rotation))
            
            // Inner circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.8), .purple.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 160, height: 160)
                .scaleEffect(scale)
            
            // Icon
            Image(systemName: "paintbrush.fill")
                .font(.system(size: 70))
                .foregroundColor(.white)
                .rotationEffect(.degrees(-rotation * 0.5))
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                scale = 1.1
            }
        }
    }
}

// MARK: - Celebration Confetti View (Renamed to avoid conflicts)
struct OnboardingCelebrationView: View {
    @State private var confettiScale = 0.0
    @State private var confettiOpacity = 0.0
    
    var body: some View {
        ZStack {
            ForEach(0..<20, id: \.self) { index in
                OnboardingConfettiPiece()
                    .scaleEffect(confettiScale)
                    .opacity(confettiOpacity)
                    .animation(
                        .spring(response: 0.5)
                        .delay(Double(index) * 0.05),
                        value: confettiScale
                    )
            }
        }
        .onAppear {
            confettiScale = 1.0
            confettiOpacity = 1.0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeOut(duration: 1)) {
                    confettiOpacity = 0
                }
            }
        }
    }
}

struct OnboardingConfettiPiece: View {
    @State private var position = CGPoint(x: 0, y: 0)
    @State private var rotation = 0.0
    
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    let size = CGFloat.random(in: 10...20)
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(colors.randomElement()!)
            .frame(width: size, height: size * 0.6)
            .rotationEffect(.degrees(rotation))
            .position(position)
            .onAppear {
                let angle = Double.random(in: 0...(2 * .pi))
                let distance = CGFloat.random(in: 100...200)
                
                withAnimation(.easeOut(duration: 2)) {
                    position = CGPoint(
                        x: cos(angle) * distance,
                        y: sin(angle) * distance - 50
                    )
                    rotation = Double.random(in: -360...360)
                }
            }
    }
}
