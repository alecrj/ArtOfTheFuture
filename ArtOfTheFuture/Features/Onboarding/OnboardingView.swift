import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var currentStep: OnboardingStep = .welcome
    @State private var isAnimating = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar
                if currentStep != .welcome {
                    ProgressBar(progress: currentStep.progress)
                        .padding(.horizontal)
                        .padding(.top, 8)
                }
                
                // Content
                TabView(selection: $currentStep) {
                    ForEach(OnboardingStep.allCases, id: \.self) { step in
                        stepContent(for: step)
                            .tag(step)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5), value: currentStep)
                
                // Navigation buttons
                navigationButtons
                    .padding(.horizontal)
                    .padding(.bottom)
            }
        }
        .preferredColorScheme(.light)
    }
    
    // MARK: - Step Content
    @ViewBuilder
    private func stepContent(for step: OnboardingStep) -> some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Title and subtitle
            VStack(spacing: 16) {
                Text(step.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                if let subtitle = step.subtitle {
                    Text(subtitle)
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal)
            
            // Step specific content
            Group {
                switch step {
                case .welcome:
                    welcomeContent
                case .name:
                    nameContent
                case .skillLevel:
                    skillLevelContent
                case .goals:
                    goalsContent
                case .practiceTime:
                    practiceTimeContent
                case .interests:
                    interestsContent
                case .complete:
                    completeContent
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }
    
    // MARK: - Welcome Content
    private var welcomeContent: some View {
        VStack(spacing: 40) {
            // Animated icon
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 200, height: 200)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.6)
                
                Image(systemName: "paintbrush.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isAnimating ? 0 : -10))
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
            
            // Feature highlights
            VStack(spacing: 24) {
                FeatureRow(
                    icon: "sparkles",
                    title: "AI-Powered Learning",
                    description: "Personalized lessons that adapt to you"
                )
                
                FeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Track Progress",
                    description: "See your improvement over time"
                )
                
                FeatureRow(
                    icon: "person.3.fill",
                    title: "Join Community",
                    description: "Learn with artists worldwide"
                )
            }
        }
    }
    
    // MARK: - Name Content
    private var nameContent: some View {
        VStack(spacing: 40) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 100))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 20) {
                TextField("Enter your name", text: $viewModel.onboardingData.userName)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                
                Text("You can always change this later")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Skill Level Content
    private var skillLevelContent: some View {
        VStack(spacing: 20) {
            ForEach(SkillLevel.allCases, id: \.self) { level in
                SkillLevelCard(
                    level: level,
                    isSelected: viewModel.onboardingData.skillLevel == level,
                    action: {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.onboardingData.skillLevel = level
                            HapticManager.shared.impact(.light)
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - Goals Content
    private var goalsContent: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(LearningGoal.allCases, id: \.self) { goal in
                    GoalCard(
                        goal: goal,
                        isSelected: viewModel.onboardingData.learningGoals.contains(goal),
                        action: {
                            withAnimation(.spring(response: 0.3)) {
                                if viewModel.onboardingData.learningGoals.contains(goal) {
                                    viewModel.onboardingData.learningGoals.remove(goal)
                                } else {
                                    viewModel.onboardingData.learningGoals.insert(goal)
                                }
                                HapticManager.shared.impact(.light)
                            }
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Practice Time Content
    private var practiceTimeContent: some View {
        VStack(spacing: 16) {
            ForEach(PracticeTime.allCases, id: \.self) { time in
                PracticeTimeCard(
                    practiceTime: time,
                    isSelected: viewModel.onboardingData.preferredPracticeTime == time,
                    action: {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.onboardingData.preferredPracticeTime = time
                            HapticManager.shared.impact(.light)
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - Interests Content
    private var interestsContent: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(ArtInterest.allCases, id: \.self) { interest in
                    InterestCard(
                        interest: interest,
                        isSelected: viewModel.onboardingData.interests.contains(interest),
                        action: {
                            withAnimation(.spring(response: 0.3)) {
                                if viewModel.onboardingData.interests.contains(interest) {
                                    viewModel.onboardingData.interests.remove(interest)
                                } else {
                                    viewModel.onboardingData.interests.insert(interest)
                                }
                                HapticManager.shared.impact(.light)
                            }
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Complete Content
    private var completeContent: some View {
        VStack(spacing: 40) {
            // Success animation
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 150, height: 150)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.green)
                    .transition(.scale.combined(with: .opacity))
            }
            
            VStack(spacing: 24) {
                Text("Welcome, \(viewModel.onboardingData.userName)!")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(spacing: 16) {
                    SummaryRow(
                        icon: viewModel.onboardingData.skillLevel.icon,
                        label: "Level",
                        value: viewModel.onboardingData.skillLevel.rawValue
                    )
                    
                    SummaryRow(
                        icon: "target",
                        label: "Goals",
                        value: "\(viewModel.onboardingData.learningGoals.count) selected"
                    )
                    
                    SummaryRow(
                        icon: "clock",
                        label: "Daily Practice",
                        value: viewModel.onboardingData.preferredPracticeTime.rawValue
                    )
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
            }
        }
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            // Back button
            if currentStep != .welcome {
                Button(action: previousStep) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(12)
                }
            }
            
            // Continue/Complete button
            Button(action: nextStep) {
                HStack {
                    Text(currentStep == .complete ? "Start Learning" : "Continue")
                    if currentStep != .complete {
                        Image(systemName: "chevron.right")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(canProceed ? Color.accentColor : Color(.systemGray5))
                .foregroundColor(canProceed ? .white : .secondary)
                .cornerRadius(12)
            }
            .disabled(!canProceed)
        }
    }
    
    // MARK: - Helper Methods
    private var canProceed: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .name:
            return !viewModel.onboardingData.userName.isEmpty
        case .skillLevel:
            return true
        case .goals:
            return !viewModel.onboardingData.learningGoals.isEmpty
        case .practiceTime:
            return true
        case .interests:
            return !viewModel.onboardingData.interests.isEmpty
        case .complete:
            return true
        }
    }
    
    private func nextStep() {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep) else { return }
        
        if currentIndex < OnboardingStep.allCases.count - 1 {
            withAnimation {
                currentStep = OnboardingStep.allCases[currentIndex + 1]
            }
            HapticManager.shared.impact(.light)
        } else {
            // Complete onboarding
            completeOnboarding()
        }
    }
    
    private func previousStep() {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
              currentIndex > 0 else { return }
        
        withAnimation {
            currentStep = OnboardingStep.allCases[currentIndex - 1]
        }
        HapticManager.shared.impact(.light)
    }
    
    private func completeOnboarding() {
        Task {
            await viewModel.completeOnboarding()
            HapticManager.shared.notification(.success)
            dismiss()
        }
    }
}

// MARK: - Supporting Views
struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: 8)
                    .animation(.spring(response: 0.5), value: progress)
            }
        }
        .frame(height: 8)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct SummaryRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    OnboardingView()
}
