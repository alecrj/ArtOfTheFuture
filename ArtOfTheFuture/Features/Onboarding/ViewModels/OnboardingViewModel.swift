// MARK: - Enhanced OnboardingViewModel with Duolingo-style Features
// File: ArtOfTheFuture/Features/Onboarding/ViewModels/OnboardingViewModel.swift

import Foundation
import SwiftUI
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var onboardingData = OnboardingData()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentStep: OnboardingStep = .welcome
    @Published var showCelebration = false
    @Published var completionProgress: Double = 0
    
    // Validation states for each step
    @Published var nameValidation: ValidationState = .pending
    @Published var goalsValidation: ValidationState = .pending
    @Published var interestsValidation: ValidationState = .pending
    
    private let hapticManager = HapticManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Reference to auth service for backend integration
    private var authService: FirebaseAuthService?
    
    init() {
        setupValidationObservers()
    }
    
    // Set auth service reference
    func setAuthService(_ authService: FirebaseAuthService) {
        self.authService = authService
    }
    
    // MARK: - Validation Setup
    private func setupValidationObservers() {
        // Name validation
        $onboardingData
            .map { $0.userName }
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] name in
                self?.validateName(name)
            }
            .store(in: &cancellables)
        
        // Goals validation
        $onboardingData
            .map { $0.learningGoals }
            .removeDuplicates()
            .sink { [weak self] goals in
                self?.validateGoals(goals)
            }
            .store(in: &cancellables)
        
        // Interests validation
        $onboardingData
            .map { $0.interests }
            .removeDuplicates()
            .sink { [weak self] interests in
                self?.validateInterests(interests)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Step Navigation
    func nextStep() {
        guard canProceedFromCurrentStep else { return }
        
        let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep) ?? 0
        
        if currentIndex < OnboardingStep.allCases.count - 1 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentStep = OnboardingStep.allCases[currentIndex + 1]
            }
            hapticManager.impact(.light)
        } else {
            // Complete onboarding
            completeOnboarding()
        }
    }
    
    func previousStep() {
        let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep) ?? 0
        guard currentIndex > 0 else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentStep = OnboardingStep.allCases[currentIndex - 1]
        }
        hapticManager.impact(.light)
    }
    
    // MARK: - Step Validation
    var canProceedFromCurrentStep: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .name:
            return nameValidation == .valid
        case .skillLevel:
            return true
        case .goals:
            return goalsValidation == .valid
        case .practiceTime:
            return true
        case .interests:
            return interestsValidation == .valid
        case .complete:
            return true
        }
    }
    
    private func validateName(_ name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            nameValidation = .pending
        } else if trimmedName.count < 2 {
            nameValidation = .invalid("Name must be at least 2 characters")
        } else if trimmedName.count > 30 {
            nameValidation = .invalid("Name must be less than 30 characters")
        } else {
            nameValidation = .valid
        }
    }
    
    private func validateGoals(_ goals: Set<LearningGoal>) {
        if goals.isEmpty {
            goalsValidation = .pending
        } else if goals.count > 4 {
            goalsValidation = .invalid("Please select up to 4 goals")
        } else {
            goalsValidation = .valid
        }
    }
    
    private func validateInterests(_ interests: Set<ArtInterest>) {
        if interests.isEmpty {
            interestsValidation = .pending
        } else if interests.count > 6 {
            interestsValidation = .invalid("Please select up to 6 interests")
        } else {
            interestsValidation = .valid
        }
    }
    
    // MARK: - Onboarding Completion
    func completeOnboarding() {
        guard !isLoading else { return }
        guard let authService = authService else {
            errorMessage = "Authentication service not available"
            return
        }
        
        isLoading = true
        
        Task {
            do {
                // Show completion animation
                await animateCompletion()
                
                // Save onboarding data to Firebase
                try await authService.markOnboardingCompleted(with: onboardingData)
                
                // Also save to UserDefaults as backup
                onboardingData.hasCompletedOnboarding = true
                onboardingData.onboardingDate = Date()
                
                if let encoded = try? JSONEncoder().encode(onboardingData) {
                    UserDefaults.standard.set(encoded, forKey: "onboardingData")
                }
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                
                // Generate initial learning path
                await generatePersonalizedLearningPath()
                
                // Award initial XP for completing onboarding
                await awardOnboardingXP()
                
                // Success haptics
                hapticManager.notification(.success)
                
                print("🎉 Onboarding completed successfully!")
                
            } catch {
                errorMessage = "Failed to complete onboarding: \(error.localizedDescription)"
                hapticManager.notification(.error)
                print("❌ Onboarding completion failed: \(error)")
            }
            
            isLoading = false
        }
    }
    
    // MARK: - Completion Animation
    private func animateCompletion() async {
        await MainActor.run {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.6)) {
                showCelebration = true
            }
        }
        
        // Animate progress to completion
        for progress in stride(from: 0.0, through: 1.0, by: 0.1) {
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.1)) {
                    completionProgress = progress
                }
            }
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
        // Hold the celebration for a moment
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
    }
    
    // MARK: - Personalized Learning Path Generation
    private func generatePersonalizedLearningPath() async {
        print("🎨 Generating personalized learning path...")
        print("📊 User Profile Summary:")
        print("   • Name: \(onboardingData.userName)")
        print("   • Skill Level: \(onboardingData.skillLevel.rawValue)")
        print("   • Goals: \(onboardingData.learningGoals.map(\.rawValue).joined(separator: ", "))")
        print("   • Practice Time: \(onboardingData.preferredPracticeTime.rawValue)")
        print("   • Interests: \(onboardingData.interests.map(\.rawValue).joined(separator: ", "))")
        
        // Generate recommended first lessons based on preferences
        let recommendedLessons = generateInitialLessons()
        
        // Save recommendations
        let recommendations = RecommendationData(
            recommendedLessons: recommendedLessons,
            personalizedGoals: generatePersonalizedGoals(),
            estimatedLearningPath: generateLearningPathEstimate()
        )
        
        // Store recommendations
        if let encoded = try? JSONEncoder().encode(recommendations) {
            UserDefaults.standard.set(encoded, forKey: "initialRecommendations")
        }
    }
    
    private func generateInitialLessons() -> [String] {
        var lessons: [String] = []
        
        // Start with fundamentals based on skill level
        switch onboardingData.skillLevel {
        case .beginner:
            lessons = ["Basic Shapes", "Line Quality", "Simple Forms"]
        case .intermediate:
            lessons = ["Advanced Shading", "Perspective Basics", "Proportion"]
        case .advanced:
            lessons = ["Complex Lighting", "Advanced Anatomy", "Composition"]
        }
        
        // Add interest-specific lessons
        if onboardingData.interests.contains(.portraits) {
            lessons.append("Face Proportions")
        }
        if onboardingData.interests.contains(.landscapes) {
            lessons.append("Atmospheric Perspective")
        }
        if onboardingData.interests.contains(.animals) {
            lessons.append("Animal Anatomy Basics")
        }
        
        return Array(lessons.prefix(5)) // Limit to 5 initial lessons
    }
    
    private func generatePersonalizedGoals() -> [String] {
        return onboardingData.learningGoals.map { goal in
            switch goal {
            case .hobby:
                return "Complete 3 fun drawing exercises this week"
            case .improvement:
                return "Master 1 new technique each week"
            case .professional:
                return "Build portfolio with 10 professional pieces"
            case .relaxation:
                return "Practice mindful drawing for 10 minutes daily"
            case .social:
                return "Share your artwork and get feedback"
            case .portfolio:
                return "Create 5 portfolio-worthy pieces this month"
            }
        }
    }
    
    private func generateLearningPathEstimate() -> LearningPathEstimate {
        let dailyMinutes = onboardingData.preferredPracticeTime.minutes ?? 15
        let weeklyMinutes = dailyMinutes * 7
        
        let estimatedWeeksToIntermediate: Int
        let estimatedWeeksToAdvanced: Int
        
        switch onboardingData.skillLevel {
        case .beginner:
            estimatedWeeksToIntermediate = max(12, 180 / weeklyMinutes) // At least 12 weeks
            estimatedWeeksToAdvanced = max(24, 360 / weeklyMinutes)
        case .intermediate:
            estimatedWeeksToIntermediate = 0
            estimatedWeeksToAdvanced = max(12, 180 / weeklyMinutes)
        case .advanced:
            estimatedWeeksToIntermediate = 0
            estimatedWeeksToAdvanced = 0
        }
        
        return LearningPathEstimate(
            currentLevel: onboardingData.skillLevel,
            weeksToNextLevel: estimatedWeeksToIntermediate,
            weeksToAdvanced: estimatedWeeksToAdvanced,
            dailyCommitment: dailyMinutes
        )
    }
    
    private func awardOnboardingXP() async {
        // Award XP for completing onboarding
        let xpAmount = 50
        
        // Store initial XP
        UserDefaults.standard.set(xpAmount, forKey: "totalXP")
        
        // Post XP gained notification for UI updates (using existing notification)
        NotificationCenter.default.post(
            name: .xpGained,
            object: nil,
            userInfo: ["amount": xpAmount, "source": "onboarding"]
        )
    }
}

// MARK: - Supporting Data Models
struct RecommendationData: Codable {
    let recommendedLessons: [String]
    let personalizedGoals: [String]
    let estimatedLearningPath: LearningPathEstimate
}

struct LearningPathEstimate: Codable {
    let currentLevel: SkillLevel
    let weeksToNextLevel: Int
    let weeksToAdvanced: Int
    let dailyCommitment: Int
}

// MARK: - Validation State
enum ValidationState: Equatable {
    case pending
    case valid
    case invalid(String)
    
    var isValid: Bool {
        if case .valid = self { return true }
        return false
    }
    
    var errorMessage: String? {
        if case .invalid(let message) = self { return message }
        return nil
    }
}
