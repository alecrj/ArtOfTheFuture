// MARK: - Complete OnboardingCards Components
// File: ArtOfTheFuture/Features/Onboarding/Views/OnboardingCards.swift

import SwiftUI

// MARK: - Skill Level Card
struct SkillLevelCard: View {
    let level: SkillLevel
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(level.color.opacity(isSelected ? 0.3 : 0.1))
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
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(level.color)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? level.color : Color(.systemGray5), lineWidth: isSelected ? 2 : 1)
                    )
            )
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
            .scaleEffect(isPressed ? 0.95 : (isSelected ? 1.02 : 1.0))
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        } perform: {}
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Goal Card
struct GoalCard: View {
    let goal: LearningGoal
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon background
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            isSelected ?
                            LinearGradient(
                                colors: [goal.color.opacity(0.3), goal.color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color(.systemGray6), Color(.systemGray5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 80)
                    
                    Image(systemName: goal.icon)
                        .font(.largeTitle)
                        .foregroundColor(isSelected ? goal.color : .secondary)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                        .animation(.spring(response: 0.4), value: isSelected)
                }
                
                // Text
                Text(goal.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // Selection indicator
                Circle()
                    .fill(isSelected ? goal.color : Color(.systemGray5))
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .scaleEffect(isSelected ? 1.0 : 0.5)
                            .opacity(isSelected ? 1 : 0)
                    )
                    .animation(.spring(response: 0.3), value: isSelected)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? goal.color : Color(.systemGray5), lineWidth: isSelected ? 2 : 1)
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
        } perform: {}
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Practice Time Card
struct PracticeTimeCard: View {
    let practiceTime: PracticeTime
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Time icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray6))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "clock")
                        .font(.title3)
                        .foregroundColor(isSelected ? .blue : .secondary)
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(practiceTime.rawValue)
                        .font(.headline)
                        .foregroundColor(isSelected ? .primary : .secondary)
                    
                    Text(practiceTime.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.05) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        } perform: {}
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
                // Image/Icon area
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            isSelected ?
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.6),
                                    Color.purple.opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.2),
                                    Color.purple.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 100)
                    
                    // Main icon
                    Image(systemName: interest.icon)
                        .font(.system(size: 35))
                        .foregroundColor(.white)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                        .animation(.spring(response: 0.4), value: isSelected)
                    
                    // Selection overlay
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white, lineWidth: 3)
                        
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .background(
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 24, height: 24)
                                    )
                            }
                            Spacer()
                        }
                        .padding(8)
                    }
                }
                
                // Title
                Text(interest.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.vertical, 8)
                    .frame(minHeight: 35)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.blue : Color(.systemGray5), lineWidth: isSelected ? 2 : 1)
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
        } perform: {}
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
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Outer rings
            ForEach(0..<3) { i in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.blue.opacity(0.3 - Double(i) * 0.1), .purple.opacity(0.3 - Double(i) * 0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: CGFloat(120 + i * 20), height: CGFloat(120 + i * 20))
                    .rotationEffect(.degrees(rotation + Double(i * 120)))
                    .scaleEffect(scale + Double(i) * 0.1)
            }
            
            // Center circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                )
                .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                scale = 1.1
            }
            isAnimating = true
        }
    }
}

// MARK: - Progress Celebration View
struct ProgressCelebrationView: View {
    let progress: Double
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        VStack(spacing: 16) {
            // Circular progress
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 8)
                    .frame(width: 100, height: 100)
                
                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(animatedProgress * 100))%")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            Text("Setting up your personalized experience...")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Preview Helpers
struct OnboardingCards_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SkillLevelCard(
                level: .beginner,
                isSelected: true,
                action: {}
            )
            
            HStack {
                GoalCard(
                    goal: .hobby,
                    isSelected: false,
                    action: {}
                )
                
                GoalCard(
                    goal: .improvement,
                    isSelected: true,
                    action: {}
                )
            }
            
            PracticeTimeCard(
                practiceTime: .fifteen,
                isSelected: true,
                action: {}
            )
            
            HStack {
                InterestCard(
                    interest: .portraits,
                    isSelected: false,
                    action: {}
                )
                
                InterestCard(
                    interest: .landscapes,
                    isSelected: true,
                    action: {}
                )
            }
        }
        .padding()
    }
}
