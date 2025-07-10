// MARK: - Onboarding Models (Fixed)
// File: ArtOfTheFuture/Features/Onboarding/Models/OnboardingModels.swift

import Foundation
import SwiftUI

// MARK: - Onboarding Models
struct OnboardingData: Codable {
    var userName: String = ""
    var skillLevel: SkillLevel = .beginner
    var learningGoals: Set<LearningGoal> = []
    var preferredPracticeTime: PracticeTime = .fifteen
    var interests: Set<ArtInterest> = []
    var hasCompletedOnboarding: Bool = false
    var onboardingDate: Date = Date()
}

// MARK: - Skill Level
enum SkillLevel: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var description: String {
        switch self {
        case .beginner:
            return "I'm new to drawing"
        case .intermediate:
            return "I have some experience"
        case .advanced:
            return "I'm experienced"
        }
    }
    
    var icon: String {
        switch self {
        case .beginner: return "sparkles"
        case .intermediate: return "star.fill"
        case .advanced: return "crown.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .blue
        case .advanced: return .purple
        }
    }
}

// MARK: - Learning Goals
enum LearningGoal: String, CaseIterable, Codable {
    case hobby = "Draw for Fun"
    case improvement = "Improve My Skills"
    case professional = "Professional Development"
    case relaxation = "Stress Relief"
    case social = "Share with Friends"
    case portfolio = "Build Portfolio"
    
    var icon: String {
        switch self {
        case .hobby: return "face.smiling"
        case .improvement: return "chart.line.uptrend.xyaxis"
        case .professional: return "briefcase.fill"
        case .relaxation: return "leaf.fill"
        case .social: return "person.3.fill"
        case .portfolio: return "photo.stack"
        }
    }
    
    var color: Color {
        switch self {
        case .hobby: return .orange
        case .improvement: return .blue
        case .professional: return .purple
        case .relaxation: return .green
        case .social: return .pink
        case .portfolio: return .indigo
        }
    }
}

// MARK: - Practice Time
enum PracticeTime: String, CaseIterable, Codable {
    case five = "5 min/day"
    case fifteen = "15 min/day"
    case thirty = "30 min/day"
    case sixty = "1 hour/day"
    case flexible = "Flexible"
    
    var minutes: Int? {
        switch self {
        case .five: return 5
        case .fifteen: return 15
        case .thirty: return 30
        case .sixty: return 60
        case .flexible: return nil
        }
    }
    
    var description: String {
        switch self {
        case .five: return "Quick daily practice"
        case .fifteen: return "Short focused sessions"
        case .thirty: return "Dedicated practice time"
        case .sixty: return "Serious commitment"
        case .flexible: return "Practice when I can"
        }
    }
}

// MARK: - Art Interests
enum ArtInterest: String, CaseIterable, Codable {
    case portraits = "Portraits"
    case landscapes = "Landscapes"
    case animals = "Animals"
    case manga = "Manga/Anime"
    case abstract = "Abstract"
    case stillLife = "Still Life"
    case characters = "Characters"
    case nature = "Nature"
    case architecture = "Architecture"
    case fantasy = "Fantasy"
    
    var icon: String {
        switch self {
        case .portraits: return "person.crop.circle"
        case .landscapes: return "photo"
        case .animals: return "pawprint.fill"
        case .manga: return "sparkles"
        case .abstract: return "scribble.variable"
        case .stillLife: return "camera.macro"
        case .characters: return "figure.stand"
        case .nature: return "leaf"
        case .architecture: return "building.2"
        case .fantasy: return "sparkle"
        }
    }
    
    var sampleImage: String {
        // These would be actual image assets in the app
        return "sample_\(self.rawValue.lowercased())"
    }
}

// MARK: - Onboarding Step
enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case name = 1
    case skillLevel = 2
    case goals = 3
    case practiceTime = 4
    case interests = 5
    case complete = 6
    
    var title: String {
        switch self {
        case .welcome: return "Welcome to Art of the Future"
        case .name: return "What should we call you?"
        case .skillLevel: return "What's your experience level?"
        case .goals: return "What are your goals?"
        case .practiceTime: return "How much time can you practice?"
        case .interests: return "What interests you?"
        case .complete: return "You're all set!"
        }
    }
    
    var subtitle: String? {
        switch self {
        case .welcome: return "Learn to draw with AI-powered lessons"
        case .name: return "Let's personalize your experience"
        case .skillLevel: return "We'll customize your learning path"
        case .goals: return "Select all that apply"
        case .practiceTime: return "We'll adjust lesson lengths"
        case .interests: return "We'll recommend relevant content"
        case .complete: return "Let's start your art journey!"
        }
    }
    
    var progress: Double {
        Double(self.rawValue) / Double(OnboardingStep.allCases.count - 1)
    }
}

// MARK: - Home Dashboard Models (Fixed)
struct DashboardData: Codable {
    let user: User
    let currentStreak: Int
    let todayProgress: DailyProgress
    let recentArtworks: [String] // Store IDs instead of full objects for simplicity
    let weeklyStats: WeeklyStats // Fixed naming
}

struct DailyProgress: Codable {
    let targetMinutes: Int
    let completedMinutes: Int
    let lessonsCompleted: Int
    let xpEarned: Int
    
    var progressPercentage: Double {
        guard targetMinutes > 0 else { return 0 }
        return min(Double(completedMinutes) / Double(targetMinutes), 1.0)
    }
    
    var isComplete: Bool {
        completedMinutes >= targetMinutes
    }
}

// MARK: - Achievement Model
struct Achievement: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let unlockedDate: Date?
    let progress: Double // 0.0 to 1.0
    let xpReward: Int
    
    var isUnlocked: Bool {
        unlockedDate != nil
    }
}

// MARK: - User Profile Model (Minimal for compilation)
struct UserProfile: Codable {
    let id: String
    var displayName: String
    var email: String?
    var level: Int = 1
    var totalXP: Int = 0
    var currentStreak: Int = 0
    var completedLessons: Set<String> = []
    var unlockedLessons: Set<String> = ["lesson_001"]
    
    // Computed properties
    var levelProgress: Double {
        let xpInCurrentLevel = totalXP % ((level + 1) * 100)
        let xpNeededForLevel = (level + 1) * 100
        return Double(xpInCurrentLevel) / Double(xpNeededForLevel)
    }
}
