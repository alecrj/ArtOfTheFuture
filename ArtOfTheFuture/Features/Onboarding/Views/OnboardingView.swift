// MARK: - Enhanced Duolingo-style OnboardingView
// File: ArtOfTheFuture/Features/Onboarding/Views/OnboardingView.swift

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject private var authService: FirebaseAuthService
    @State private var dragOffset: CGSize = .zero
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background gradient
            backgroundGradient
            
            // Main content
            VStack(spacing: 0) {
                // Progress indicator
                if viewModel.currentStep != .welcome {
                    progressHeader
                }
                
                // Step content with page transitions
                stepContentView
                
                // Navigation controls
                navigationFooter
            }
            
            // Celebration overlay
            if viewModel.showCelebration {
                celebrationOverlay
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            // Set the auth service reference
            viewModel.setAuthService(authService)
            
            withAnimation(.spring(response: 0.8)) {
                isAnimating = true
            }
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.1),
                Color.purple.opacity(0.1),
                Color.pink.opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
    }
    
    // MARK: - Progress Header
    private var progressHeader: some View {
        VStack(spacing: 12) {
            HStack {
                // Back button
                Button(action: {
                    viewModel.previousStep()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                }
                .opacity(viewModel.currentStep == .welcome ? 0 : 1)
                
                Spacer()
                
                // Step indicator
                Text("\(viewModel.currentStep.rawValue + 1) of \(OnboardingStep.allCases.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Skip button (on early steps only)
                if viewModel.currentStep.rawValue < 4 {
                    Button("Skip") {
                        // Jump to complete step
                        withAnimation(.spring(response: 0.6)) {
                            viewModel.currentStep = .complete
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 44)
                } else {
                    Spacer()
                        .frame(width: 44)
                }
            }
            .padding(.horizontal)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * viewModel.currentStep.progress, height: 6)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.currentStep.progress)
                }
            }
            .frame(height: 6)
            .padding(.horizontal)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Step Content
    private var stepContentView: some View {
        TabView(selection: $viewModel.currentStep) {
            ForEach(OnboardingStep.allCases, id: \.self) { step in
                stepContent(for: step)
                    .tag(step)
                    .clipped()
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.currentStep)
    }
    
    @ViewBuilder
    private func stepContent(for step: OnboardingStep) -> some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 20)
                
                // Icon/Animation area
                stepIcon(for: step)
                
                // Title and subtitle
                VStack(spacing: 16) {
                    Text(step.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    if let subtitle = step.subtitle {
                        Text(subtitle)
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal)
                
                // Step-specific content
                stepSpecificContent(for: step)
                
                Spacer(minLength: 100) // Space for navigation
            }
        }
    }
    
    @ViewBuilder
    private func stepIcon(for step: OnboardingStep) -> some View {
        ZStack {
            // Background circle with gradient
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
            
            // Icon
            Image(systemName: step.iconName)
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(
                    .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
    }
    
    @ViewBuilder
    private func stepSpecificContent(for step: OnboardingStep) -> some View {
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
    
    // MARK: - Step Contents
    private var welcomeContent: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text("🎨 AI-Powered Drawing Lessons")
                Text("📚 Structured Learning Path")
                Text("🏆 Track Your Progress")
                Text("🎯 Personalized Goals")
            }
            .font(.headline)
            .foregroundColor(.primary)
            
            Text("Join thousands of artists improving their skills every day!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
        }
        .padding(.horizontal)
    }
    
    private var nameContent: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                TextField("Enter your name", text: $viewModel.onboardingData.userName)
                    .textFieldStyle(OnboardingTextFieldStyle())
                    .submitLabel(.continue)
                    .onSubmit {
                        if viewModel.canProceedFromCurrentStep {
                            viewModel.nextStep()
                        }
                    }
                
                // Validation feedback
                if let errorMessage = viewModel.nameValidation.errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                } else if viewModel.nameValidation.isValid {
                    Label("Looks great!", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Text("We'll use this to personalize your learning experience")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
    }
    
    private var skillLevelContent: some View {
        VStack(spacing: 16) {
            ForEach(SkillLevel.allCases, id: \.self) { level in
                SkillLevelCard(
                    level: level,
                    isSelected: viewModel.onboardingData.skillLevel == level,
                    action: {
                        withAnimation(.spring(response: 0.4)) {
                            viewModel.onboardingData.skillLevel = level
                            HapticManager.shared.impact(.light)
                        }
                    }
                )
            }
        }
        .padding(.horizontal)
    }
    
    private var goalsContent: some View {
        VStack(spacing: 20) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(LearningGoal.allCases, id: \.self) { goal in
                    GoalCard(
                        goal: goal,
                        isSelected: viewModel.onboardingData.learningGoals.contains(goal),
                        action: {
                            withAnimation(.spring(response: 0.3)) {
                                if viewModel.onboardingData.learningGoals.contains(goal) {
                                    viewModel.onboardingData.learningGoals.remove(goal)
                                } else if viewModel.onboardingData.learningGoals.count < 4 {
                                    viewModel.onboardingData.learningGoals.insert(goal)
                                    HapticManager.shared.impact(.light)
                                }
                            }
                        }
                    )
                }
            }
            
            // Validation feedback
            if let errorMessage = viewModel.goalsValidation.errorMessage {
                Label(errorMessage, systemImage: "info.circle.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal)
    }
    
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
        .padding(.horizontal)
    }
    
    private var interestsContent: some View {
        VStack(spacing: 20) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(ArtInterest.allCases, id: \.self) { interest in
                    InterestCard(
                        interest: interest,
                        isSelected: viewModel.onboardingData.interests.contains(interest),
                        action: {
                            withAnimation(.spring(response: 0.3)) {
                                if viewModel.onboardingData.interests.contains(interest) {
                                    viewModel.onboardingData.interests.remove(interest)
                                } else if viewModel.onboardingData.interests.count < 6 {
                                    viewModel.onboardingData.interests.insert(interest)
                                    HapticManager.shared.impact(.light)
                                }
                            }
                        }
                    )
                }
            }
            
            // Validation feedback
            if let errorMessage = viewModel.interestsValidation.errorMessage {
                Label(errorMessage, systemImage: "info.circle.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal)
    }
    
    private var completeContent: some View {
        VStack(spacing: 24) {
            // Success animation would go here
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(.spring(response: 0.6).repeatForever(autoreverses: true), value: isAnimating)
            
            VStack(spacing: 16) {
                Text("Perfect! Here's your personalized plan:")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                // Summary of selections
                VStack(spacing: 12) {
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
                    
                    SummaryRow(
                        icon: "heart",
                        label: "Interests",
                        value: "\(viewModel.onboardingData.interests.count) selected"
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Navigation Footer
    private var navigationFooter: some View {
        VStack(spacing: 16) {
            // Error message
            if let errorMessage = viewModel.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            // Continue button
            Button(action: {
                viewModel.nextStep()
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.white)
                    } else {
                        Text(buttonTitle)
                        if viewModel.currentStep != .complete {
                            Image(systemName: "chevron.right")
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    viewModel.canProceedFromCurrentStep ?
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    ) :
                    LinearGradient(
                        colors: [Color(.systemGray5), Color(.systemGray5)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(viewModel.canProceedFromCurrentStep ? .white : .secondary)
                .cornerRadius(16)
                .shadow(
                    color: viewModel.canProceedFromCurrentStep ? .blue.opacity(0.3) : .clear,
                    radius: 8,
                    y: 4
                )
            }
            .disabled(!viewModel.canProceedFromCurrentStep || viewModel.isLoading)
            .scaleEffect(viewModel.canProceedFromCurrentStep ? 1.0 : 0.95)
            .animation(.spring(response: 0.3), value: viewModel.canProceedFromCurrentStep)
        }
        .padding()
    }
    
    private var buttonTitle: String {
        switch viewModel.currentStep {
        case .complete:
            return "Start Your Art Journey! 🎨"
        default:
            return "Continue"
        }
    }
    
    // MARK: - Celebration Overlay
    private var celebrationOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Celebration animation
                ZStack {
                    ForEach(0..<6) { i in
                        Image(systemName: "star.fill")
                            .font(.title)
                            .foregroundColor(.yellow)
                            .offset(
                                x: cos(Double(i) * .pi / 3) * 50,
                                y: sin(Double(i) * .pi / 3) * 50
                            )
                            .scaleEffect(isAnimating ? 1.5 : 0.5)
                            .animation(
                                .spring(response: 0.6)
                                .delay(Double(i) * 0.1)
                                .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                    }
                    
                    Text("🎉")
                        .font(.system(size: 60))
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .animation(.spring(response: 0.8).repeatForever(autoreverses: true), value: isAnimating)
                }
                
                VStack(spacing: 16) {
                    Text("Welcome to Art of the Future!")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Your personalized learning journey starts now")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [.green, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * viewModel.completionProgress, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(radius: 10)
            }
            .padding()
        }
    }
}

// MARK: - Custom Text Field Style
struct OnboardingTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - OnboardingStep Extension
extension OnboardingStep {
    var iconName: String {
        switch self {
        case .welcome: return "sparkles"
        case .name: return "person.circle"
        case .skillLevel: return "chart.bar"
        case .goals: return "target"
        case .practiceTime: return "clock"
        case .interests: return "heart"
        case .complete: return "checkmark.seal"
        }
    }
}

// MARK: - Summary Row Component
struct SummaryRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(FirebaseAuthService())
    }
}
