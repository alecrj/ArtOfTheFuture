// MARK: - Fixed OnboardingViewModel
// File: ArtOfTheFuture/Features/Onboarding/ViewModels/OnboardingViewModel.swift

import Foundation
import SwiftUI
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var onboardingData = OnboardingData()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userService: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(userService: UserServiceProtocol? = nil) {
        self.userService = userService ?? UserService()
    }
    
    func completeOnboarding() async {
        isLoading = true
        
        do {
            // Create or update user profile
            let user = User(
                id: UUID().uuidString,
                displayName: onboardingData.userName,
                email: nil,
                totalXP: 0,
                currentLevel: 1,
                currentStreak: 0
            )
            
            // Save user data
            try await userService.createUser(user)
            
            // Save onboarding preferences
            try await userService.saveOnboardingData(onboardingData)
            
            // Mark onboarding as complete
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            UserDefaults.standard.set(user.id, forKey: "currentUserId")
            
            // Generate initial learning path
            await generateLearningPath()
            
        } catch {
            errorMessage = "Failed to complete onboarding: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func generateLearningPath() async {
        // This would generate a personalized learning path based on:
        // - Skill level
        // - Goals
        // - Interests
        // - Available practice time
        
        print("Generating learning path for:")
        print("- Skill Level: \(onboardingData.skillLevel)")
        print("- Goals: \(onboardingData.learningGoals)")
        print("- Practice Time: \(onboardingData.preferredPracticeTime)")
        print("- Interests: \(onboardingData.interests)")
    }
}

// MARK: - User Service Protocol
protocol UserServiceProtocol {
    func createUser(_ user: User) async throws
    func updateUser(_ user: User) async throws
    func getUser(id: String) async throws -> User
    func saveOnboardingData(_ data: OnboardingData) async throws
    func getOnboardingData() async throws -> OnboardingData?
    func updateDailyProgress(_ progress: DailyProgress) async throws
    func getWeeklyStats() async throws -> WeeklyStats
}

// MARK: - User Service Implementation
final class UserService: UserServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func createUser(_ user: User) async throws {
        let userData = try encoder.encode(user)
        userDefaults.set(userData, forKey: "user_\(user.id)")
    }
    
    func updateUser(_ user: User) async throws {
        try await createUser(user) // Same implementation for now
    }
    
    func getUser(id: String) async throws -> User {
        guard let userData = userDefaults.data(forKey: "user_\(id)") else {
            throw UserServiceError.userNotFound
        }
        return try decoder.decode(User.self, from: userData)
    }
    
    func saveOnboardingData(_ data: OnboardingData) async throws {
        let encoded = try encoder.encode(data)
        userDefaults.set(encoded, forKey: "onboardingData")
    }
    
    func getOnboardingData() async throws -> OnboardingData? {
        guard let data = userDefaults.data(forKey: "onboardingData") else {
            return nil
        }
        return try decoder.decode(OnboardingData.self, from: data)
    }
    
    func updateDailyProgress(_ progress: DailyProgress) async throws {
        let encoded = try encoder.encode(progress)
        let key = "dailyProgress_\(Date().formatted(date: .numeric, time: .omitted))"
        userDefaults.set(encoded, forKey: key)
    }
    
    func getWeeklyStats() async throws -> WeeklyStats {
        var dayStats: [WeeklyStats.DayStats] = []
        let calendar = Calendar.current
        let today = Date()
        
        // Get stats for the last 7 days
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            let key = "dailyProgress_\(date.formatted(date: .numeric, time: .omitted))"
            
            if let data = userDefaults.data(forKey: key),
               let progress = try? decoder.decode(DailyProgress.self, from: data) {
                dayStats.append(WeeklyStats.DayStats(
                    date: date,
                    minutes: progress.completedMinutes,
                    xp: progress.xpEarned,
                    completed: progress.isComplete
                ))
            } else {
                // No data for this day
                dayStats.append(WeeklyStats.DayStats(
                    date: date,
                    minutes: 0,
                    xp: 0,
                    completed: false
                ))
            }
        }
        
        let totalMinutes = dayStats.reduce(0) { $0 + $1.minutes }
        let totalXP = dayStats.reduce(0) { $0 + $1.xp }
        let daysWithData = dayStats.filter { $0.minutes > 0 }.count
        let averageMinutes = daysWithData > 0 ? Double(totalMinutes) / Double(daysWithData) : 0
        
        return WeeklyStats(
            days: dayStats.reversed(), // Oldest to newest
            totalMinutes: totalMinutes,
            totalXP: totalXP,
            averageMinutesPerDay: averageMinutes
        )
    }
}

// MARK: - User Service Errors
enum UserServiceError: LocalizedError {
    case userNotFound
    case invalidData
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found"
        case .invalidData:
            return "Invalid user data"
        case .saveFailed:
            return "Failed to save user data"
        }
    }
}

// MARK: - Extended User Model
extension User {
    // Add properties for onboarding
    var skillLevel: SkillLevel? {
        get {
            guard let data = UserDefaults.standard.data(forKey: "onboardingData"),
                  let onboarding = try? JSONDecoder().decode(OnboardingData.self, from: data) else {
                return nil
            }
            return onboarding.skillLevel
        }
    }
    
    var dailyGoalMinutes: Int {
        guard let data = UserDefaults.standard.data(forKey: "onboardingData"),
              let onboarding = try? JSONDecoder().decode(OnboardingData.self, from: data) else {
            return 15 // Default
        }
        
        return calculateDailyGoal(
            practiceTime: onboarding.preferredPracticeTime,
            skillLevel: onboarding.skillLevel
        )
    }
    
    private func calculateDailyGoal(
        practiceTime: PracticeTime,
        skillLevel: SkillLevel
    ) -> Int {
        switch practiceTime {
        case .five: return 5
        case .fifteen: return 15
        case .thirty: return 30
        case .sixty: return 60
        case .flexible:
            // Adaptive based on skill level
            switch skillLevel {
            case .beginner: return 10
            case .intermediate: return 20
            case .advanced: return 30
            }
        }
    }
}
